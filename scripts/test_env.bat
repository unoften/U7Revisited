IF "%SHOW_WARNINGS%"=="true" echo --- Warnings will be shown (output not filtered) ---

REM --- Clean ---
IF "%SHOULD_CLEAN%"=="true" (
    IF EXIST "%BUILD_DIR%\" (
        echo [Clean] Removing build directory: %BUILD_DIR%...
        rmdir /S /Q "%BUILD_DIR%"
        IF !ERRORLEVEL! NEQ 0 (
            echo [Clean] Error: Failed to remove directory %BUILD_DIR% >&2
            PAUSE
            exit /b 1
        )
        echo [Clean] Directory removed.
        SET "SHOULD_CONFIGURE=true"
    ) ELSE (
        echo [Clean] Build directory %BUILD_DIR% not found. Skipping removal.
    )
)

REM --- Configure ---
SET "DO_SETUP=false"
IF "%SHOULD_CONFIGURE%"=="true" (
    SET "DO_SETUP=true"
) ELSE (
    IF NOT EXIST "%BUILD_DIR%\meson-private\coredata.dat" (
        SET "DO_SETUP=true"
    )
)