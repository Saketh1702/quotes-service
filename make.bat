@echo off

if "%1"=="setup" (
    if not exist "build" mkdir build
    python -m venv venv
    call .\venv\Scripts\activate
    python -m pip install -r requirements.txt
    goto :eof
)

if "%1"=="test" (
    pytest tests/ -v
    goto :eof
)

if "%1"=="package" (
    if not exist "build" mkdir build
    cd src\functions\get_quote && powershell Compress-Archive -Path * -DestinationPath ..\..\..\build\get_quote.zip -Force
    cd ..\put_quote && powershell Compress-Archive -Path * -DestinationPath ..\..\..\build\put_quote.zip -Force
    cd ..\..\..
    goto :eof
)

if "%1"=="deploy" (
    call :package
    cd infrastructure && terraform init && terraform apply -auto-approve
    cd ..
    goto :eof
)

if "%1"=="clean" (
    if exist "build" rd /s /q build
    if exist ".pytest_cache" rd /s /q .pytest_cache
    for /d /r . %%d in (__pycache__) do @if exist "%%d" rd /s /q "%%d"
    goto :eof
)

:eof