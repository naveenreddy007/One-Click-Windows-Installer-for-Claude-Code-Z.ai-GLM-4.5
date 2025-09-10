@echo off
echo [INFO] Uninstalling Claude-Code ...
call npm uninstall -g @anthropic-ai/claude-code >nul 2>&1
echo [INFO] Deleting configuration ...
del /f /q "%USERPROFILE%\.claude.json" 2>nul
rmdir /s /q "%USERPROFILE%\.claude"   2>nul
echo [SUCCESS] Claude-Code completely removed.
pause