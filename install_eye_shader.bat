@echo off
setlocal

:: --- Configuration ---
set "SHADER_DEST=C:\Users\steve_y696t0m\OneDrive\VRChatProjects\TRANCE\Assets\TRANCE_New\Shaders"
set "EDITOR_DEST=C:\Users\steve_y696t0m\OneDrive\VRChatProjects\TRANCE\Assets\TRANCE_New\Shaders\Editor"

set "SHADER_SOURCE=eye_shader\eye-shader.shader"
set "EDITOR_SCRIPT_SOURCE=eye_shader\RainbowHeartburstIrisGUI.cs"

:: --- Execution ---
echo Installing Rainbow Heartburst Iris shader...
echo Target Shader Path: %SHADER_DEST%
echo Target Editor Script Path: %EDITOR_DEST%
echo.

:: Check if source files exist
if not exist "%SHADER_SOURCE%" (
    echo ERROR: Source shader file not found: %SHADER_SOURCE%
    goto End
)
if not exist "%EDITOR_SCRIPT_SOURCE%" (
    echo ERROR: Source editor script file not found: %EDITOR_SCRIPT_SOURCE%
    goto End
)

:: Check if main destination directory exists
if not exist "%SHADER_DEST%\" (
    echo ERROR: Destination directory not found: %SHADER_DEST%
    echo Please ensure the path is correct and the directory exists.
    goto End
)

:: Create Editor subdirectory if it doesn't exist
if not exist "%EDITOR_DEST%\" (
    echo Creating Editor directory: %EDITOR_DEST%
    mkdir "%EDITOR_DEST%"
    if errorlevel 1 (
        echo ERROR: Failed to create Editor directory. Check permissions.
        goto End
    )
)

:: Copy files
echo Copying shader file...
copy /Y "%SHADER_SOURCE%" "%SHADER_DEST%\"
if errorlevel 1 (
    echo ERROR: Failed to copy shader file.
    goto End
)

echo Copying editor script...
copy /Y "%EDITOR_SCRIPT_SOURCE%" "%EDITOR_DEST%\"
if errorlevel 1 (
    echo ERROR: Failed to copy editor script file.
    goto End
)

echo.
echo Installation successful!

:End
echo.
pause
endlocal