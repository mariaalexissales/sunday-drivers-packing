@echo off
echo Simple Packing Mod - Test Validation
echo ===================================
echo.

python validate_tests.py

if %ERRORLEVEL% EQU 0 (
    echo.
    echo Test setup is ready!
    echo Create a test branch and push to GitHub to trigger automated tests.
) else (
    echo.
    echo Please fix the validation issues before proceeding.
)

pause