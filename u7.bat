@echo off
echo [u7 Debug] Script Start.
setlocal enabledelayedexpansion
echo [u7 Debug] setlocal done.

SET "SCRIPT_DIR=%~dp0"
REM Ensure SCRIPT_DIR ends with a backslash
REM Breaking down the IF...SET for clarity
SET NeedsSlash=0
IF "%SCRIPT_DIR:~-1%" NEQ "\" SET NeedsSlash=1
IF %NeedsSlash% EQU 1 SET "SCRIPT_DIR=%SCRIPT_DIR%\"
SET "GO_APP_DIR=%SCRIPT_DIR%u7go"
SET "GO_APP_NAME=u7go.exe"
REM Path where the binary will be BUILT and EXECUTED (inside the go app dir)
SET "GO_BINARY_EXE_PATH=%GO_APP_DIR%\%GO_APP_NAME%"
echo [u7 Debug] Variables set. Before error handler definition.

REM --- Argument Parsing for Special Wrapper Commands ---
SET DO_REBUILD=0
IF /I "%~1" EQU "update" SET DO_REBUILD=1

IF %DO_REBUILD% EQU 1 (
    echo [u7 Wrapper] 'update' command detected: Rebuilding u7go...
    IF NOT EXIST "%GO_APP_DIR%\" (
        echo [u7 Wrapper ERROR] Cannot update u7go: Go application directory not found: %GO_APP_DIR% >&2
        exit /b 1
    )
    
    REM Verify Go exists before trying to build
    where go > nul 2> nul
    IF ERRORLEVEL 1 (
         echo [u7 Wrapper ERROR] Cannot update u7go: 'go' command not found in PATH. >&2
         exit /b 1
    )
    go version > nul 2> nul
    IF ERRORLEVEL 1 (
         echo [u7 Wrapper ERROR] Cannot update u7go: 'go version' failed. Check Go installation. >&2
         exit /b 1
    )

    pushd "%GO_APP_DIR%"
    IF ERRORLEVEL 1 (
        echo [u7 Wrapper ERROR] u7go update failed: Could not change directory to %GO_APP_DIR%. >&2
        exit /b 1
    )
    echo [u7 Wrapper] Running: go build -o %GO_APP_NAME% .
    del /Q /F "%GO_APP_NAME%" > nul 2> nul
    REM Run go mod tidy first
    echo [u7 Wrapper] Running go mod tidy...
    go mod tidy
    IF ERRORLEVEL 1 (
        echo [u7 Wrapper ERROR] 'go mod tidy' failed during update in %GO_APP_DIR%. >&2
        popd
        exit /b 1
    )
    REM Now build
    go build -o "%GO_APP_NAME%" .
    IF ERRORLEVEL 1 (
        echo [u7 Wrapper ERROR] u7go update failed during 'go build' in %GO_APP_DIR%. >&2
        popd
        exit /b 1
    )
    echo [u7 Wrapper] u7go update successful: %GO_BINARY_EXE_PATH%
    dir "%GO_BINARY_EXE_PATH%" | findstr /B /C:" " /C:"." 
    popd
    exit /b 0
)

REM ==============================================
REM SCRIPT EXECUTION LOGIC ENDS HERE
REM Any code below this point should only be reached via CALL or GOTO
REM ==============================================

REM --- Check Go Installation --- 
echo [u7 Debug] Reached Go check section...
REM 1. Check for Go command
echo [u7 Debug] About to run 'where go'...
where go > nul 2> nul
echo [u7 Debug] Finished 'where go'. Checking ERRORLEVEL %ERRORLEVEL%...
IF ERRORLEVEL 1 GOTO GoNotFound

REM 1b. Verify Go command works
echo [u7 Debug] About to run 'go version'...
go version > nul 2> nul
echo [u7 Debug] Finished 'go version'. Checking ERRORLEVEL %ERRORLEVEL%...
IF ERRORLEVEL 1 GOTO GoCommandFailed

REM --- Go seems OK, continue script ---
echo [u7 Wrapper] Found functional Go command.
GOTO ContinueScript

:GoNotFound
    echo [u7 Wrapper ERROR] 'go' command not found in PATH. >&2
    echo. >&2
    echo   Please install Go (version 1.18 or newer recommended) from: >&2
    echo     https://golang.org/dl/ >&2
    echo. >&2
    echo   Ensure the Go installation directory (e.g., C:\Go\bin) is added to your system PATH environment variable. >&2
    exit /b 1

:GoCommandFailed
    echo [u7 Wrapper ERROR] 'go' command was found, but 'go version' failed to execute. >&2
    echo   This might indicate a corrupted Go installation or PATH issues. >&2
    echo. >&2
    echo   Please ensure Go is correctly installed and accessible. >&2
    echo   Download: https://golang.org/dl/ >&2
    exit /b 1

:ContinueScript
REM 2. Check if u7go directory exists
IF NOT EXIST "%GO_APP_DIR%\" (
    echo [u7 Wrapper ERROR] Go application source directory not found: %GO_APP_DIR% >&2
    exit /b 1
)

REM 3. Check if u7go.exe binary exists inside u7go/, build if not
IF NOT EXIST "%GO_BINARY_EXE_PATH%" (
    echo [u7 Wrapper] Go application binary '%GO_APP_NAME%' not found. Building...
    
    REM Store current dir and cd, then restore
    pushd "%GO_APP_DIR%"
    IF ERRORLEVEL 1 (
        call :HandleWrapperError "Failed to change directory to %GO_APP_DIR%."
    )

    REM Run go mod tidy first
    echo [u7 Wrapper] Running go mod tidy...
    go mod tidy
    IF ERRORLEVEL 1 (
        popd
        call :HandleWrapperError "'go mod tidy' failed in %GO_APP_DIR%."
    )
    
    REM Build the application inside the current directory (u7go)
    echo [u7 Wrapper] Running go build... (Output: %GO_APP_NAME%)
    REM Clear any old local binary first
    del /Q /F "%GO_APP_NAME%" > nul 2> nul 
    go build -o "%GO_APP_NAME%" .
    IF ERRORLEVEL 1 (
        popd
        call :HandleWrapperError "'go build' failed to create %GO_APP_NAME% in %GO_APP_DIR%."
    )
    
    REM Check if build succeeded and created the file
    IF NOT EXIST "%GO_BINARY_EXE_PATH%" (
        popd
        call :HandleWrapperError "Target binary check failed after build. %GO_BINARY_EXE_PATH% not found."
    )
    echo [u7 Wrapper] Go application built successfully.
    popd
)

REM 4. Execute the Go application from its location inside u7go/, passing all arguments
REM %* passes all arguments as they were received by this script
echo [u7 Wrapper] Preparing to execute: %GO_BINARY_EXE_PATH% %*
echo [u7 Wrapper] --- Executing Go application ---
echo.

REM Execute and branch based on success (ERRORLEVEL 0) or failure (ERRORLEVEL non-zero)
"%GO_BINARY_EXE_PATH%" %* && (
    REM Success Path
    REM Don't echo success here, let Go app handle its output
    endlocal
    exit /b 0
) || (
    REM Failure Path
    REM Capture the non-zero exit code immediately
    SET U7GO_EXIT_CODE=%ERRORLEVEL%
    echo [u7 Wrapper ERROR] Go application exited with error code: %U7GO_EXIT_CODE%. >&2
    endlocal
    exit /b %U7GO_EXIT_CODE%
)

REM ==============================================
REM SCRIPT EXECUTION LOGIC ENDS HERE
REM Any code below this point should only be reached via CALL or GOTO
REM ==============================================

REM --- Subroutines ---

REM Simple Error Print Subroutine
:HandleWrapperError
    REM echo [u7 Wrapper ERROR] Inside HandleWrapperError subroutine... >&2
    echo [u7 Wrapper ERROR] Raw argument received: %1 >&2
    echo [u7 Wrapper ERROR] Argument after ~ processing: %~1 >&2
    REM Use EQU for safer string comparison
    IF "%~1" EQU "" (
      echo [u7 Wrapper ERROR] MESSAGE WAS BLANK OR MISSING! Check calling line. >&2
    ) ELSE (
      echo [u7 Wrapper ERROR] Message: %~1 >&2
    )
    exit /b 1
REM --- End of error handler ---

REM --- End of File --- 