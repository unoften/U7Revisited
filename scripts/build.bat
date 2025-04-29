@echo off
REM Simple build script for U7Revisited using Meson (Windows)
setlocal enabledelayedexpansion

SET "SCRIPT_DIR=%~dp0"
REM Ensure SCRIPT_DIR ends with a backslash for reliable path joining
IF "%SCRIPT_DIR:~-1%" NEQ "\" SET "SCRIPT_DIR=%SCRIPT_DIR%\"
SET "PROJECT_ROOT=%SCRIPT_DIR%..\"

SET "BUILD_TYPE=release"
SET "BUILD_DIR=%PROJECT_ROOT%build-release"
SET "SHOULD_CONFIGURE=false"
SET "SHOULD_CLEAN=false"
SET "SHOULD_RUN=false"
SET "SHOW_WARNINGS=false"
SET "RUN_ARGS="
SET "EXTRA_MESON_ARGS="

REM --- Argument Parsing ---
:ArgLoop
IF "%~1"=="" GOTO ArgsDone

IF /I "%~1"=="--debug" (
    SET "BUILD_TYPE=debug"
    SET "BUILD_DIR=%PROJECT_ROOT%build-debug"
    SHIFT
    GOTO ArgLoop
)
IF /I "%~1"=="--configure" (
    SET "SHOULD_CONFIGURE=true"
    SHIFT
    GOTO ArgLoop
)
IF /I "%~1"=="--clean" (
    SET "SHOULD_CLEAN=true"
    SHIFT
    GOTO ArgLoop
)
IF /I "%~1"=="--warnings" (
    SET "SHOW_WARNINGS=true"
    SHIFT
    GOTO ArgLoop
)
IF /I "%~1"=="--run" (
    SET "SHOULD_RUN=true"
    SHIFT
    SET RUN_ARGS=!cmdcmdline:*--run =!
    GOTO ArgsDone
)
IF /I "%~1"=="-h" GOTO Help
IF /I "%~1"=="--help" GOTO Help

echo "%~1" | findstr /B /C:"-D" > nul
IF !ERRORLEVEL! == 0 (
    SET "EXTRA_MESON_ARGS=!EXTRA_MESON_ARGS! %1"
    SHIFT
    GOTO ArgLoop
)
echo "%~1" | findstr /B /C:"-C" > nul
IF !ERRORLEVEL! == 0 (
    SET "EXTRA_MESON_ARGS=!EXTRA_MESON_ARGS! %1"
    SHIFT
    GOTO ArgLoop
)

echo Warning: Unknown or misplaced argument: %1
SHIFT
GOTO ArgLoop

:Help
echo Usage: %~nx0 [--debug] [--configure] [--clean] [--warnings] [--run] [-Doption=value...] [run_script_args...]
echo   --debug      : Build the debug version (default: release)
echo   --configure  : Force run 'meson setup' even if build dir exists
echo   --clean      : Remove the build directory before building
echo   --warnings   : Display compiler warnings (output may not be filtered)
echo   --run        : Run the project using run_u7.bat after building
echo   -D.../-C...  : Pass arguments directly to 'meson setup'
echo   run_script_args: Arguments passed to run_u7.bat when using --run
exit /b 0

:ArgsDone

echo --- Building U7Revisited (%BUILD_TYPE%) ---

IF "%SHOW_WARNINGS%"=="true" echo --- Warnings will be shown (output not filtered) ---

REM --- Using simplified IF for Clean logic ---
IF "%SHOULD_CLEAN%"=="true" echo [Clean] Will attempt to remove %BUILD_DIR%...
IF "%SHOULD_CLEAN%"=="true" IF EXIST "%BUILD_DIR%\" rmdir /S /Q "%BUILD_DIR%" && (echo [Clean] Directory removed. && SET "SHOULD_CONFIGURE=true") || (echo [Clean] Error: Failed to remove directory %BUILD_DIR% >&2 && exit /b 1)
IF "%SHOULD_CLEAN%"=="true" IF NOT EXIST "%BUILD_DIR%\" echo [Clean] Build directory %BUILD_DIR% not found or already removed.

REM --- Determine if Setup/Configure is needed ---
SET "DO_SETUP=false"
IF "%SHOULD_CONFIGURE%"=="true" SET "DO_SETUP=true"
IF NOT "%SHOULD_CONFIGURE%"=="true" IF NOT EXIST "%BUILD_DIR%\meson-private\coredata.dat" SET "DO_SETUP=true"

REM --- Configure Block (using GOTO logic) ---
IF NOT "%DO_SETUP%"=="true" GOTO :SkipSetup

:PerformSetup
    echo [Configure] Configuring (%BUILD_TYPE%) in %BUILD_DIR%...
    where meson > nul 2> nul
    IF !ERRORLEVEL! NEQ 0 GOTO :WhereMeson_Fail
    :WhereMeson_OK
    meson setup "%BUILD_DIR%" --buildtype="%BUILD_TYPE%"
    IF !ERRORLEVEL! NEQ 0 GOTO :MesonSetup_Fail
    :MesonSetup_OK
    echo [Configure] Meson setup complete.
    GOTO :SetupDone

:WhereMeson_Fail
    echo [Configure] Error: 'meson' command not found in PATH. >&2
    exit /b 1

:MesonSetup_Fail
    echo [Configure] Error: Meson setup failed! >&2
    exit /b 1

:SkipSetup
     IF "%EXTRA_MESON_ARGS%"=="" GOTO :SkipReconfigure
         echo [Configure] Reconfiguring (%BUILD_TYPE%) in %BUILD_DIR% due to extra args...
     meson configure "%BUILD_DIR%" %EXTRA_MESON_ARGS%
     IF !ERRORLEVEL! NEQ 0 GOTO :MesonConfigure_Fail
     :MesonConfigure_OK
     GOTO :ReconfigureDone
     :MesonConfigure_Fail
            echo [Configure] Error: Meson configure failed! >&2
            exit /b 1
     :SkipReconfigure
        echo [Configure] Build directory %BUILD_DIR% already configured. Skipping setup.
     :ReconfigureDone
     REM Fall through to SetupDone

:SetupDone

REM --- Compile Block (using GOTO logic) ---
echo [Compile] Compiling (%BUILD_TYPE%) in %BUILD_DIR%...
meson compile -C "%BUILD_DIR%"
SET COMPILE_EXIT_CODE=!ERRORLEVEL!
IF !COMPILE_EXIT_CODE! EQU 0 GOTO :Compile_OK
    echo [Compile] Error: Meson compile failed! (Exit Code: !COMPILE_EXIT_CODE!) >&2
    exit /b 1
:Compile_OK
echo [Compile] Meson compile successful.

IF NOT "%SHOW_WARNINGS%"=="true" GOTO :SkipWarningNote
    echo [Compile] Note: Warnings requested; check full Meson output above.
:SkipWarningNote

echo --- Build successful (%BUILD_TYPE%) ---

REM --- Run Block (using GOTO logic) ---
IF NOT "%SHOULD_RUN%"=="true" GOTO :SkipRunBlock
    echo.
    echo --- Running (%BUILD_TYPE%) ---
    SET "RUN_CMD=run_u7.bat"
    SET "RUN_SCRIPT_PATH=%SCRIPT_DIR%%RUN_CMD%"
    SET "FINAL_RUN_ARGS="
    IF NOT "%BUILD_TYPE%"=="debug" GOTO :Run_ReleaseArgs
        SET "FINAL_RUN_ARGS=--debug %RUN_ARGS%"
    GOTO :Run_ArgsSet
    :Run_ReleaseArgs
        SET "FINAL_RUN_ARGS=%RUN_ARGS%"
    :Run_ArgsSet
    IF EXIST "%RUN_SCRIPT_PATH%" GOTO :RunScript_Exists
        echo [Run] Error: %RUN_CMD% not found in %SCRIPT_DIR%. >&2
        exit /b 1
    :RunScript_Exists
    echo [Run] Executing: %RUN_SCRIPT_PATH% %FINAL_RUN_ARGS%
    call "%RUN_SCRIPT_PATH%" %FINAL_RUN_ARGS%
    SET RUN_EXIT_CODE=!ERRORLEVEL!
    IF !RUN_EXIT_CODE! EQU 0 GOTO :Run_OK
        echo [Run] Process exited with code !RUN_EXIT_CODE!. >&2
        echo --- Run failed ---
        exit /b 1
    :Run_OK
    echo --- Run finished ---
:SkipRunBlock

echo [Build Script] Finished.
exit /b 0 