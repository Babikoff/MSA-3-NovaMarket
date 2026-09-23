@echo off
setlocal EnableExtensions

REM ============================================================
REM  deploy-nginx.bat - deploy Nginx into local Docker
REM ============================================================

cd /d "%~dp0"

set "NGINX_IMAGE=nginx@sha256:62ff2089abf5a9ed33bd232895bef5e22f7bb4b200675cec49a5ebc48e3d4ac8"
set "CONTAINER_NAME=nginx"
set "NGINX_CONF=%~1"
set "PY_TEST_FILE=%~2"

if not exist "%NGINX_CONF%" (
    echo [ERROR] %NGINX_CONF% not found.
    exit /b 1
)
if not exist "%PY_TEST_FILE%" (
    echo [ERROR] %PY_TEST_FILE% not found.
    exit /b 1
)

echo [1/5] Cleaning port-forwards
taskkill /fi "WINDOWTITLE eq port-forward" >nul 2>&1

REM ---------- [2/5] Remove any previous container ----------
echo [2/5] Removing previous container (if any) ...
docker rm -f %CONTAINER_NAME% >nul 2>&1

REM ---------- [3/5] Pull the pinned image by digest ----------
echo [3/5] Pulling pinned Nginx Alpine image ...
docker pull %NGINX_IMAGE%
if errorlevel 1 (
    echo [ERROR] docker pull failed.
    exit /b 1
)

REM ---------- [4/5] Run Nginx, mounting the rate-limiter config ----------
echo [4/5] Running Nginx container ...
docker run -d --name %CONTAINER_NAME% --restart unless-stopped ^
    -p 8080:8080 ^
    -p 9090:9090 ^
    -p 8081:8081 ^
    -v "%NGINX_CONF%:/etc/nginx/conf.d/default.conf:ro" ^
    %NGINX_IMAGE%
if errorlevel 1 (
    echo [ERROR] docker run failed.
    exit /b 1
)

REM ---------- Confirm ----------
echo [5/5] Deployment confirmed:
docker ps --filter name=%CONTAINER_NAME%

echo.
echo [OK] Nginx deployed.

echo.
echo Ready to run loading test. 
echo.
@REM  echo Press any key to run loading test.
@REM  pause >nul

@REM  python -m locust -f %PY_TEST_FILE% --host http://localhost:8080/ --headless -u 10 -r 50 -t 1m

exit /b 0