@echo off
setlocal EnableExtensions

REM ============================================================
REM  deploy-common.bat - shared deploy/redeploy logic
REM
REM  Usage: call deploy-common.bat ENV_LABEL HPA_CONF_FILE CONTAINER TEST_PORT
REM    %1 HPA_CONF_FILE e.g. ./hpa-by-mem.yaml
REM    %2 HPA_TEST_NAME metadata->name from HPA_CONF_FILE. E.g. "scaletestapp-hpa-mem".
REM    %3 CONTAINER   smoke-test container name
REM    %4 TEST_PORT   smoke-test local port
REM
REM  Optional env: IMAGE_TAG = fixed image tag (default: timestamp)
REM
REM  Flow: build -> smoke test /ping -> minikube image load
REM        -> helm upgrade --install -> kubectl rollout status
REM ============================================================

if "%~1"=="" (
    echo [ERROR] Usage: deploy-common.bat HPA_CONF_FILE HPA_TEST_NAME CONTAINER TEST_PORT
    exit /b 1
)

REM --- Ensure relative paths resolve relative to this script's dir ---
cd /d "%~dp0"

set "HPA_CONF_FILE=%~1"
set "HPA_TEST_NAME=%~2"
set "CONTAINER=%~3"
set "TEST_PORT=%~4"
set "IMAGE_NAME=scaletestapp"
set "DEPLOYMENT_NAME=scaletestapp"
set "CHART_DIR=./helm/scaletestapp"

REM --- Use 'latest' image unless IMAGE_TAG is provided ---
if defined IMAGE_TAG (
    set "FINAL_TAG=%IMAGE_TAG%"
) else (
    @REM  for /f "delims=" %%i in ('powershell -NoProfile -Command "Get-Date -Format yyyyMMddHHmmss"') do set "FINAL_TAG=local-%%i"
    set "FINAL_TAG=latest"
)

echo ============================================================
echo  Deploying %DEPLOYMENT_NAME% [%ENV_LABEL%]
echo  Image : %IMAGE_NAME%:%FINAL_TAG%
echo  HPA config: %HPA_CONF_FILE%
echo ============================================================

@REM  REM ---------- [1/5] Build the image ----------
@REM  echo.
@REM  echo [1/5] Building image %IMAGE_NAME%:%FINAL_TAG% ...
@REM  docker build -t %IMAGE_NAME%:%FINAL_TAG% ./booking-service
@REM  if errorlevel 1 goto :error

REM ---------- [2/5] Smoke-test /ping ----------
@REM  echo.
@REM  echo [2/5] Smoke-testing /ping ...
@REM  docker rm -f %CONTAINER% >nul 2>&1
@REM  docker run -d --name %CONTAINER% -p %TEST_PORT%:8080 %IMAGE_NAME%:%FINAL_TAG%
@REM  if errorlevel 1 goto :error
@REM  timeout /t 2 /nobreak >nul
@REM  curl -f http://localhost:%TEST_PORT%/ping >nul 2>&1
@REM  if errorlevel 1 goto :error_smoke
@REM  echo       OK: /ping returned pong
@REM  docker rm -f %CONTAINER% >nul 2>&1

REM ---------- [2/5] Ensure MiniKube is running with metrics-server ----------
echo.
minikube status >nul 2>&1
if errorlevel 1 (
    echo [2/5] MiniKube is NOT running. Starting it ...
    minikube start --addons=metrics-server
    if errorlevel 1 goto :error
) else (
    echo [2/5] MiniKube is already running. Enabling metrics-server addon ...
    minikube addons enable metrics-server
    if errorlevel 1 goto :error
)
REM Verify the metrics-server addon deployment is actually up
kubectl get deployment metrics-server -n kube-system >nul 2>&1
if errorlevel 1 goto :error_smoke
echo OK: metrics-server is checked

REM ---------- [3/5] Load image into Minikube ----------
echo.
echo [3/5] Loading image into Minikube ...
minikube image load %IMAGE_NAME%:%FINAL_TAG%
if errorlevel 1 goto :error

REM ---------- [4/5] Helm deploy / redeploy ----------
echo.
echo [4/5] helm upgrade --install (%ENV_LABEL% values) ...
helm upgrade --install %DEPLOYMENT_NAME% %CHART_DIR% ^
    --set image.tag=%FINAL_TAG% ^
    --set image.pullPolicy=IfNotPresent
if errorlevel 1 goto :error

REM ---------- [5/5] Wait for rollout ----------
echo.
echo [5/5] Waiting for rollout ...
kubectl rollout status deployment/%DEPLOYMENT_NAME%
if errorlevel 1 goto :error

echo.
echo [OK] %ENV_LABEL% deployment successful.
kubectl get pods -l app=%DEPLOYMENT_NAME%

echo.
echo Preparing for load testing

echo.
echo Delete all HPAs
kubectl -n scaletest delete hpa

echo.
echo Appling HPA config: %HPA_CONF_FILE%
kubectl apply -f %HPA_CONF_FILE%

@REM TODO: move to another bat file
@REM  echo. 
@REM  echo Monitoring: %HPA_TEST_NAME%
@REM  kubectl get hpa %HPA_TEST_NAME% -w

echo.
echo Ready to running loading test. Press any key to start loading.

@REM locust -f locustfile.py --host http://localhost:8080 --headless -u 200 -r 20 -t 3m

exit /b 0

:error_smoke
echo.
echo [ERROR] Smoke test failed: could not test metrics-server -n <наименование namespace>
@REM  docker rm -f %CONTAINER% >nul 2>&1
goto :error

:error
echo.
echo [ERROR] Deployment failed. See output above.
exit /b 1
