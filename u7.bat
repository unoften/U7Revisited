@echo off
setlocal enabledelayedexpansion

REM --- Config --- 
SET "SCRIPT_DIR=%~dp0"
IF "%SCRIPT_DIR:~-1%" NEQ "\" SET "SCRIPT_DIR=%SCRIPT_DIR%\"
SET "GO_APP_DIR=%SCRIPT_DIR%u7go"
SET "GO_APP_NAME=u7go.exe"
SET "GO_BINARY_EXE_PATH=%GO_APP_DIR%\%GO_APP_NAME%"

REM --- Default Settings & Action Flags ---
SET BUILD_TYPE=release
SET SHOW_WARNINGS=0
SET DO_CLEAN=0
SET DO_BUILD=0
SET DO_RUN=0
SET DO_HEALTHCHECK=0
SET DO_CONFIGURE=0
SET DO_SETUP=0
SET DO_SCRIPTS=0
SET DO_UPDATE=0
SET FIX_REQUIRES=0
SET GAME_ARGS_STR=
SET PASS_THROUGH=0

REM --- Argument Parsing ---
REM Use a loop with SHIFT (less clean than FOR but more traditional for complex batch args)
:ArgLoop
IF "%~1"=="" GOTO EndArgLoop

IF %PASS_THROUGH% EQU 1 (
    REM Append to GAME_ARGS_STR, handle spaces carefully
    IF defined GAME_ARGS_STR (
        SET "GAME_ARGS_STR=!GAME_ARGS_STR! "%~1""
    ) ELSE (
        SET "GAME_ARGS_STR="%~1""
    )
    SHIFT
    GOTO ArgLoop
)

REM Check arguments case-insensitively
IF /I "%~1" EQU "clean"       (SET DO_CLEAN=1       & SHIFT & GOTO ArgLoop)
IF /I "%~1" EQU "build"       (SET DO_BUILD=1       & SHIFT & GOTO ArgLoop)
IF /I "%~1" EQU "rebuild"     (SET DO_CLEAN=1       & SET DO_BUILD=1)
IF /I "%~1" EQU "run"         (SET DO_RUN=1         & SHIFT & GOTO ArgLoop)
IF /I "%~1" EQU "healthcheck" (SET DO_HEALTHCHECK=1 & SHIFT & GOTO ArgLoop)
IF /I "%~1" EQU "configure"   (SET DO_CONFIGURE=1   & SHIFT & GOTO ArgLoop)
IF /I "%~1" EQU "setup"       (SET DO_SETUP=1       & SHIFT & GOTO ArgLoop)
IF /I "%~1" EQU "scripts"     (SET DO_SCRIPTS=1     & SHIFT & GOTO ArgLoop)
IF /I "%~1" EQU "update"      (SET DO_UPDATE=1      & SHIFT & GOTO ArgLoop)
IF /I "%~1" EQU "debug"       (SET BUILD_TYPE=debug & SHIFT & GOTO ArgLoop)
IF /I "%~1" EQU "--debug"     (SET BUILD_TYPE=debug & SHIFT & GOTO ArgLoop)
IF /I "%~1" EQU "release"     (SET BUILD_TYPE=release & SHIFT & GOTO ArgLoop)
IF /I "%~1" EQU "--release"   (SET BUILD_TYPE=release & SHIFT & GOTO ArgLoop)
IF /I "%~1" EQU "warnings"    (SET SHOW_WARNINGS=1  & SHIFT & GOTO ArgLoop)
IF /I "%~1" EQU "--warnings"  (SET SHOW_WARNINGS=1  & SHIFT & GOTO ArgLoop)
IF /I "%~1" EQU "--fix-requires" (SET FIX_REQUIRES=1 & SHIFT & GOTO ArgLoop)
IF /I "%~1" EQU "--"          (SET PASS_THROUGH=1   & SHIFT & GOTO ArgLoop)

REM If we matched rebuild above, the flags are set, now shift and loop
IF /I "%~1" EQU "rebuild"     (SHIFT & GOTO ArgLoop)

REM If argument is not recognized, assume it's for run or pass along?
REM For simplicity, let's ignore unknown args for now unless PASS_THROUGH is on
echo [u7 Wrapper WARNING] Ignoring unknown argument: %~1 >&2
SHIFT
GOTO ArgLoop

:EndArgLoop

REM --- Action Execution ---

REM 0. Handle Update First (Exclusive Action)
IF %DO_UPDATE% EQU 1 (
    echo [u7 Wrapper] 'update' command detected: Rebuilding u7go...
    REM -- Go Check within Update --
    where go > nul 2> nul || (call :HandleWrapperError "Cannot update: 'go' command not found." && exit /b 1)
    go version > nul 2> nul || (call :HandleWrapperError "Cannot update: 'go version' failed." && exit /b 1)
    REM -- End Go Check --
    IF NOT EXIST "%GO_APP_DIR%\" (call :HandleWrapperError "Cannot update: Go application directory not found: %GO_APP_DIR%" && exit /b 1)

    pushd "%GO_APP_DIR%"
    IF ERRORLEVEL 1 (call :HandleWrapperError "Cannot update: Failed pushd %GO_APP_DIR%" && exit /b 1)
    echo [u7 Wrapper] Running go mod tidy...
    go mod tidy || (popd && call :HandleWrapperError "'go mod tidy' failed during update." && exit /b 1)
    echo [u7 Wrapper] Running go build...
    del /Q /F "%GO_APP_NAME%" > nul 2> nul
    go build -o "%GO_APP_NAME%" . || (popd && call :HandleWrapperError "'go build' failed during update." && exit /b 1)
    echo [u7 Wrapper] u7go update successful: %GO_BINARY_EXE_PATH%
    dir "%GO_BINARY_EXE_PATH%" | findstr /B /C:" " /C:"."
    popd
    exit /b 0
)

REM 1. Check Go exists and initial u7go build if any other command is run
SET HAS_COMMAND=0
IF %DO_CLEAN% EQU 1 SET HAS_COMMAND=1
IF %DO_BUILD% EQU 1 SET HAS_COMMAND=1
IF %DO_RUN% EQU 1 SET HAS_COMMAND=1
IF %DO_HEALTHCHECK% EQU 1 SET HAS_COMMAND=1
IF %DO_CONFIGURE% EQU 1 SET HAS_COMMAND=1
IF %DO_SETUP% EQU 1 SET HAS_COMMAND=1
IF %DO_SCRIPTS% EQU 1 SET HAS_COMMAND=1

IF %HAS_COMMAND% EQU 1 (
    where go > nul 2> nul || (
        echo [u7 Wrapper ERROR] Go command not found in PATH. >&2
        echo   Please install Go (e.g., from https://golang.org/dl/) and add it to PATH. >&2
        exit /b 1
    )
    go version > nul 2> nul || (
        echo [u7 Wrapper ERROR] 'go version' failed. Check Go installation/PATH. >&2
        exit /b 1
    )
    IF NOT EXIST "%GO_BINARY_EXE_PATH%" (
        echo [u7 Wrapper] Go application binary not found. Performing initial build...
        pushd "%GO_APP_DIR%"
        IF ERRORLEVEL 1 (call :HandleWrapperError "Initial build failed: Could not change directory." && exit /b 1)
        echo [u7 Wrapper] Running go mod tidy...
        go mod tidy
        SET BUILD_ERRORLEVEL=%ERRORLEVEL%
        IF %BUILD_ERRORLEVEL% NEQ 0 (
            popd
            call :HandleWrapperError "Initial 'go mod tidy' failed."
            exit /b %BUILD_ERRORLEVEL%
        )
        echo [u7 Wrapper] Running go build...
        go build -o "%GO_APP_NAME%" .
        SET BUILD_ERRORLEVEL=%ERRORLEVEL%
        IF %BUILD_ERRORLEVEL% NEQ 0 (
             popd
             call :HandleWrapperError "Initial 'go build' failed."
             exit /b %BUILD_ERRORLEVEL%
        )
        echo [u7 Wrapper] Initial build successful.
        popd
    )
)

REM 2. Prepare Base u7go Command Args
SET U7GO_ARGS=--buildtype=%BUILD_TYPE%
IF %SHOW_WARNINGS% EQU 1 SET "U7GO_ARGS=%U7GO_ARGS% --warnings"

REM --- Execute Actions Sequentially ---
SET LAST_EXIT_CODE=0

REM Execute Setup (Exclusive Action)
IF %DO_SETUP% EQU 1 (
    echo [u7 Wrapper] --- Executing Setup ---
    call "%GO_BINARY_EXE_PATH%" setup %U7GO_ARGS%
    SET LAST_EXIT_CODE=%ERRORLEVEL%
    IF %LAST_EXIT_CODE% NEQ 0 (call :HandleWrapperError "Setup command failed (Code: %LAST_EXIT_CODE%)")
    exit /b %LAST_EXIT_CODE%
)

REM Execute Scripts (Currently Exclusive Action)
IF %DO_SCRIPTS% EQU 1 (
    echo [u7 Wrapper] --- Executing Scripts ---
    SET SCRIPT_FLAGS=
    IF %FIX_REQUIRES% EQU 1 SET "SCRIPT_FLAGS=--fix-requires"
    call "%GO_BINARY_EXE_PATH%" scripts %SCRIPT_FLAGS% %U7GO_ARGS%
    SET LAST_EXIT_CODE=%ERRORLEVEL%
    IF %LAST_EXIT_CODE% NEQ 0 (call :HandleWrapperError "Scripts command failed (Code: %LAST_EXIT_CODE%)")
    exit /b %LAST_EXIT_CODE%
)

REM Execute Configure
IF %DO_CONFIGURE% EQU 1 (
    echo [u7 Wrapper] --- Executing Configure (%BUILD_TYPE%) ---
    call "%GO_BINARY_EXE_PATH%" configure "%U7GO_ARGS%"
    SET LAST_EXIT_CODE=%ERRORLEVEL%
    IF %LAST_EXIT_CODE% NEQ 0 (call :HandleWrapperError "Configure command failed (Code: %LAST_EXIT_CODE%)" && exit /b %LAST_EXIT_CODE%)
)

REM Execute Clean
IF %DO_CLEAN% EQU 1 (
    echo [u7 Wrapper] --- Executing Clean (%BUILD_TYPE%) ---
    call "%GO_BINARY_EXE_PATH%" clean "%U7GO_ARGS%"
    SET LAST_EXIT_CODE=%ERRORLEVEL%
    IF %LAST_EXIT_CODE% NEQ 0 (call :HandleWrapperError "Clean command failed (Code: %LAST_EXIT_CODE%)" && exit /b %LAST_EXIT_CODE%)
)

REM Execute Build
IF %DO_BUILD% EQU 1 (
    echo [u7 Wrapper] --- Executing Build (%BUILD_TYPE%) ---
    call "%GO_BINARY_EXE_PATH%" build "%U7GO_ARGS%"
    SET LAST_EXIT_CODE=%ERRORLEVEL%
    IF %LAST_EXIT_CODE% NEQ 0 (call :HandleWrapperError "Build command failed (Code: %LAST_EXIT_CODE%)" && exit /b %LAST_EXIT_CODE%)
)

REM Execute Run or Healthcheck (Mutually Exclusive)
IF %DO_RUN% EQU 1 (
    echo [u7 Wrapper] --- Executing Run (%BUILD_TYPE%) ---
    call "%GO_BINARY_EXE_PATH%" run %U7GO_ARGS% -- %GAME_ARGS_STR%
    SET LAST_EXIT_CODE=%ERRORLEVEL%
    REM Error message printed by Go app itself
) ELSE IF %DO_HEALTHCHECK% EQU 1 (
    echo [u7 Wrapper] --- Executing Healthcheck ---
    call "%GO_BINARY_EXE_PATH%" healthcheck
    SET LAST_EXIT_CODE=%ERRORLEVEL%
    REM Error message printed by Go app itself
)

REM Handle case where only flags were given (or no recognized command)
IF %HAS_COMMAND% EQU 0 IF %DO_UPDATE% EQU 0 (
    echo [u7 Wrapper] No specific command given, executing u7go with flags/args...
    call "%GO_BINARY_EXE_PATH%" %U7GO_ARGS% %*
    SET LAST_EXIT_CODE=%ERRORLEVEL%
)

endlocal
exit /b %LAST_EXIT_CODE%


REM ==============================================
REM Subroutines Below
REM ==============================================

REM Simple Error Print Subroutine
:HandleWrapperError
    echo [u7 Wrapper ERROR] %~1 >&2
    exit /b 1

REM --- End of File --- 