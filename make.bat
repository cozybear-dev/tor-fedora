@echo off

call :main %1
goto :EOF

:processArgs
    if /I "%~1"=="build" (
        call :buildImage
    ) else if /I "%~1"=="run" (
        call :authCheck
        call :runImage
    ) else if "%~1"=="" (
        call :buildImage
        call :authCheck
        call :runImage
    ) else (
        echo Unknown argument: %~1
    )
    goto :EOF

:authCheck
    echo Checking for valid gcloud authentication...
    gcloud auth print-access-token >nul 2>&1 && gcloud auth application-default print-access-token >nul 2>&1 (
        goto :EOF
    ) || (
        echo Either gcloud user authentication or ADC credentials are not set, logging in...
        start /wait cmd /c "gcloud auth login --update-adc"
        goto :EOF
    )

:buildImage
    echo Building Docker image...
    docker build -t tf-tor-fedora:latest .
    goto :EOF

:runImage
    echo Running Docker container...
    docker run -it -v "%USERPROFILE%\AppData\Roaming\gcloud:/root/.config/gcloud:rw" --env-file ./.env -v "%CD%:/workdir" --workdir=/workdir/tf tf-tor-fedora:latest
    goto :EOF

:main
    call :processArgs %1
    goto :EOF