@echo off
setlocal enabledelayedexpansion

:: DEBUG - Set to 0 to disable debug output
SET "DEBUG=1"

:: Basic configuration
SET "SCRIPT_DIR=%~dp0"
SET "GO_APP_DIR=%SCRIPT_DIR%u7go"
SET "GO_APP_NAME=u7go.exe"
SET "GO_BINARY_EXE_PATH=%GO_APP_DIR%\%GO_APP_NAME%"

:: Initialize all action flags
SET "BUILD_TYPE=release"
SET "SHOW_WARNINGS=0"
SET "DO_CLEAN=0"
SET "DO_BUILD=0"
SET "DO_RUN=0"
SET "DO_HEALTHCHECK=0"
SET "DO_CONFIGURE=0"
SET "DO_SETUP=0"
SET "DO_SCRIPTS=0"
SET "DO_UPDATE=0"
SET "FIX_REQUIRES=0"
SET "GAME_ARGS_STR="
SET "PASS_THROUGH=0"

:: Debug startup
IF "%DEBUG%"=="1" (
    echo [DEBUG] Script started with arguments: %*
    echo [DEBUG] Working directory: %CD%
)

:: Argument parsing
:parse_args
IF "%~1"=="" GOTO execute_actions

IF "%DEBUG%"=="1" echo [DEBUG] Processing argument: "%~1"

:: Handle pass-through mode first
IF "!PASS_THROUGH!"=="1" (
    IF defined GAME_ARGS_STR (
        SET "GAME_ARGS_STR=!GAME_ARGS_STR! %~1"
    ) ELSE (
        SET "GAME_ARGS_STR=%~1"
    )
    SHIFT
    GOTO parse_args
)

:: Handle all commands
IF /I "%~1"=="clean" SET "DO_CLEAN=1" & SHIFT & GOTO parse_args
IF /I "%~1"=="build" SET "DO_BUILD=1" & SHIFT & GOTO parse_args
IF /I "%~1"=="rebuild" SET "DO_CLEAN=1" & SET "DO_BUILD=1" & SHIFT & GOTO parse_args
IF /I "%~1"=="run" SET "DO_RUN=1" & SHIFT & GOTO parse_args
IF /I "%~1"=="healthcheck" SET "DO_HEALTHCHECK=1" & SHIFT & GOTO parse_args
IF /I "%~1"=="configure" SET "DO_CONFIGURE=1" & SHIFT & GOTO parse_args
IF /I "%~1"=="setup" SET "DO_SETUP=1" & SHIFT & GOTO parse_args
IF /I "%~1"=="scripts" SET "DO_SCRIPTS=1" & SHIFT & GOTO parse_args
IF /I "%~1"=="update" SET "DO_UPDATE=1" & SHIFT & GOTO parse_args
IF /I "%~1"=="debug" SET "BUILD_TYPE=debug" & SHIFT & GOTO parse_args
IF /I "%~1"=="--debug" SET "BUILD_TYPE=debug" & SHIFT & GOTO parse_args
IF /I "%~1"=="release" SET "BUILD_TYPE=release" & SHIFT & GOTO parse_args
IF /I "%~1"=="--release" SET "BUILD_TYPE=release" & SHIFT & GOTO parse_args
IF /I "%~1"=="warnings" SET "SHOW_WARNINGS=1" & SHIFT & GOTO parse_args
IF /I "%~1"=="--warnings" SET "SHOW_WARNINGS=1" & SHIFT & GOTO parse_args
IF /I "%~1"=="--fix-requires" SET "FIX_REQUIRES=1" & SHIFT & GOTO parse_args
IF /I "%~1"=="--" SET "PASS_THROUGH=1" & SHIFT & GOTO parse_args

:: Unknown argument
IF "%DEBUG%"=="1" echo [DEBUG] Ignoring unknown argument: "%~1"
echo [WARNING] Ignoring unknown argument: "%~1" 1>&2
SHIFT
GOTO parse_args

:execute_actions
IF "%DEBUG%"=="1" (
    echo [DEBUG] Actions to execute:
    echo   DO_UPDATE=!DO_UPDATE!
    echo   DO_BUILD=!DO_BUILD!
    echo   DO_RUN=!DO_RUN!
    echo   DO_HEALTHCHECK=!DO_HEALTHCHECK!
)

:: Update action (exclusive)
IF "!DO_UPDATE!"=="1" (
    IF "%DEBUG%"=="1" echo [DEBUG] Executing update action
    
    IF NOT EXIST "!GO_APP_DIR!\" (
        echo [ERROR] Go app directory not found
        exit /b 1
    )
    
    pushd "!GO_APP_DIR!"
    call go mod tidy
    call go build -o "!GO_APP_NAME!" .
    popd
    
    echo [SUCCESS] Update completed
    exit /b 0
)

:: Check Go exists if any action is requested
SET "HAS_COMMAND=0"
IF "!DO_CLEAN!"=="1" SET "HAS_COMMAND=1"
IF "!DO_BUILD!"=="1" SET "HAS_COMMAND=1"
IF "!DO_RUN!"=="1" SET "HAS_COMMAND=1"
IF "!DO_HEALTHCHECK!"=="1" SET "HAS_COMMAND=1"
IF "!DO_CONFIGURE!"=="1" SET "HAS_COMMAND=1"
IF "!DO_SETUP!"=="1" SET "HAS_COMMAND=1"
IF "!DO_SCRIPTS!"=="1" SET "HAS_COMMAND=1"

IF "!HAS_COMMAND!"=="1" (
    WHERE go >NUL 2>NUL
    IF ERRORLEVEL 1 (
        echo [ERROR] Go command not found in PATH
        exit /b 1
    )
    
    IF NOT EXIST "!GO_APP_DIR!\" (
        echo [INFO] Performing initial build
        pushd "!GO_APP_DIR!"
        call go mod tidy
        call go build -o "!GO_APP_NAME!" .
        popd
    )
)

:: Prepare base arguments
SET "U7GO_ARGS=--buildtype=!BUILD_TYPE!"
IF "!SHOW_WARNINGS!"=="1" SET "U7GO_ARGS=!U7GO_ARGS! --warnings"

:: Execute actions
SET "LAST_EXIT_CODE=0"

:: Setup action
IF "!DO_SETUP!"=="1" (
    echo [INFO] Running setup
    call "!GO_BINARY_EXE_PATH!" setup !U7GO_ARGS!
    SET "LAST_EXIT_CODE=!ERRORLEVEL!"
    IF !LAST_EXIT_CODE! NEQ 0 (
        echo [ERROR] Setup failed
        exit /b !LAST_EXIT_CODE!
    )
)

:: Scripts action
IF "!DO_SCRIPTS!"=="1" (
    echo [INFO] Running scripts
    SET "SCRIPT_FLAGS="
    IF "!FIX_REQUIRES!"=="1" SET "SCRIPT_FLAGS=--fix-requires"
    call "!GO_BINARY_EXE_PATH!" scripts !SCRIPT_FLAGS! !U7GO_ARGS!
    SET "LAST_EXIT_CODE=!ERRORLEVEL!"
    IF !LAST_EXIT_CODE! NEQ 0 (
        echo [ERROR] Scripts failed
        exit /b !LAST_EXIT_CODE!
    )
)

:: Configure action
IF "!DO_CONFIGURE!"=="1" (
    echo [INFO] Running configure
    call "!GO_BINARY_EXE_PATH!" configure !U7GO_ARGS!
    SET "LAST_EXIT_CODE=!ERRORLEVEL!"
    IF !LAST_EXIT_CODE! NEQ 0 (
        echo [ERROR] Configure failed
        exit /b !LAST_EXIT_CODE!
    )
)

:: Clean action
IF "!DO_CLEAN!"=="1" (
    echo [INFO] Running clean
    call "!GO_BINARY_EXE_PATH!" clean !U7GO_ARGS!
    SET "LAST_EXIT_CODE=!ERRORLEVEL!"
    IF !LAST_EXIT_CODE! NEQ 0 (
        echo [ERROR] Clean failed
        exit /b !LAST_EXIT_CODE!
    )
)

:: Build action
IF "!DO_BUILD!"=="1" (
    echo [INFO] Running build
    call "!GO_BINARY_EXE_PATH!" build !U7GO_ARGS!
    SET "LAST_EXIT_CODE=!ERRORLEVEL!"
    IF !LAST_EXIT_CODE! NEQ 0 (
        echo [ERROR] Build failed
        exit /b !LAST_EXIT_CODE!
    )
)

:: Run/Healthcheck actions
IF "!DO_RUN!"=="1" (
    echo [INFO] Running game
    SET "RUN_CMD="!GO_BINARY_EXE_PATH!" run !U7GO_ARGS!"
    IF DEFINED GAME_ARGS_STR SET "RUN_CMD=!RUN_CMD! -- !GAME_ARGS_STR!"
    call !RUN_CMD!
    SET "LAST_EXIT_CODE=!ERRORLEVEL!"
) ELSE IF "!DO_HEALTHCHECK!"=="1" (
    echo [INFO] Running healthcheck
    call "!GO_BINARY_EXE_PATH!" healthcheck
    SET "LAST_EXIT_CODE=!ERRORLEVEL!"
)

:: Default action if no commands specified
IF "!HAS_COMMAND!"=="0" (
    echo [INFO] No command specified, running with default args
    call "!GO_BINARY_EXE_PATH!" !U7GO_ARGS! %*
    SET "LAST_EXIT_CODE=!ERRORLEVEL!"
)

exit /b !LAST_EXIT_CODE!
