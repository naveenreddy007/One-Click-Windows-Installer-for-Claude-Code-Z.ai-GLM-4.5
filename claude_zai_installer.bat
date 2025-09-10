@echo off
:: Claude-Code installer for Z.ai reverse-proxy
:: Windows 7-11  |  no admin  |  no BOM  |  no emojis
setlocal EnableDelayedExpansion

:: ---------- 1.  Node.js (portable if missing) ----------
node -v >nul 2>&1
if %errorlevel% equ 0 goto :haveNode
echo [INFO] Node.js not found – fetching portable x64 build...
set "ND=%USERPROFILE%\claude-node"
if not exist "!ND!" mkdir "!ND!"
powershell -NoProfile -Command "iwr -uri https://nodejs.org/dist/latest/win-x64/node.exe -outfile '!ND!\node.exe'" >nul 2>&1
if not exist "!ND!\node.exe" (
    echo [ERROR] Could not download Node.js. Install manually from nodejs.org then run this script again.
    pause & exit /b 1
)
set "PATH=!ND!;!PATH!"

:haveNode
:: ---------- 2.  npm global bin in PATH -----------------
for /f "delims=" %%P in ('npm config get prefix 2^>nul') do set "NPM=%%P"
echo !PATH! | find /i "!NPM!" >nul || set "PATH=!NPM!;!PATH!"

:: ---------- 3.  Ask for Z.ai API key -------------------
set "API_KEY="
set /p "API_KEY=Enter your Z.ai API key: "
if "!API_KEY!"=="" (
    echo [ERROR] Key cannot be empty.
    pause & exit /b 1
)

:: ---------- 4.  Fresh Claude-Code install --------------
echo [INFO] Installing @anthropic-ai/claude-code ...
call npm uninstall -g @anthropic-ai/claude-code >nul 2>&1
call npm install    -g @anthropic-ai/claude-code --loglevel=error
if %errorlevel% neq 0 (
    echo [ERROR] npm install failed.
    pause & exit /b 1
)

:: ---------- 5.  Clean slate ----------------------------
del /f /q "%USERPROFILE%\.claude.json" 2>nul
rmdir /s /q "%USERPROFILE%\.claude"   2>nul

:: ---------- 6.  Write Z.ai config (BOM-free) -----------
mkdir "%USERPROFILE%\.claude" 2>nul
> "%USERPROFILE%\.claude\settings.json" (
    echo {
    echo   "env": {
    echo     "ANTHROPIC_API_KEY": "!API_KEY!",
    echo     "ANTHROPIC_BASE_URL": "https://api.z.ai/api/anthropic",
    echo     "API_TIMEOUT_MS": 300000
    echo   }
    echo }
)
> "%USERPROFILE%\.claude.json" (
    echo {
    echo   "primaryApiKey": "!API_KEY!",
    echo   "hasCompletedOnboarding": true
    echo }
)

:: ---------- 7.  Verify ---------------------------------
claude --version >nul 2>&1
if %errorlevel% equ 0 (
    echo [SUCCESS] Claude-Code installed for Z.ai proxy.
    echo         Run  claude  in a new command window.
) else (
    echo [ERROR] Claude-Code still not runnable. Check npm / PATH.
)
pause
endlocal
exit /b 0