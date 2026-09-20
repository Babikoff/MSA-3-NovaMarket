@echo off
setlocal EnableExtensions

REM ============================================================
REM  deploy-common.bat - shared deploy/redeploy logic
REM
REM  Usage: call deploy-common.bat HPA_CONF_FILE
REM    %1 HPA_CONF_FILE e.g. ./hpa-by-mem.yaml
REM    %2 HPA_TEST_NAME metadata->name from HPA_CONF_FILE. E.g. "scaletestapp-hpa-mem".
REM
REM  Flow: build -> smoke test /ping -> minikube image load
REM        -> helm upgrade --install -> kubectl rollout status
REM ============================================================

if "%~1"=="" (
    echo [ERROR] Usage: deploy-common.bat HPA_CONF_FILE HPA_TEST_NAME
    exit /b 1
)

REM --- Ensure relative paths resolve relative to this script's dir ---
cd /d "%~dp0"

set "HPA_CONF_FILE=%~1"
set "HPA_TEST_NAME=%~2"
set "DEPLOYMENT_NAME=scaletestapp"
set "CHART_DIR=./helm/scaletestapp"

set "FINAL_TAG=latest"

echo ============================================================
echo  Deploying %DEPLOYMENT_NAME%
echo  HPA config: %HPA_CONF_FILE%
echo ============================================================

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

REM ---------- [4/5] Helm deploy / redeploy ----------
echo.
echo [4/5] helm upgrade --install ...
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
echo [OK] deployment successful.
kubectl get pods -l app=%DEPLOYMENT_NAME%

echo.
echo Preparing for load testing

echo.
echo Delete all HPAs
@REM  kubectl -n scaletest delete hpa --all
REM 1) Remove all HPA definitions (all namespaces, to catch strays)
kubectl get hpa --all-namespaces
kubectl delete hpa --all --all-namespaces

REM 2) Delete the Helm-tracked Deployment "scaletestapp"
helm delete scaletestapp

REM 3) Delete leftover HPA replica Deployments (label app=scaletestapp)
kubectl get deployments -o name
kubectl delete deployment scaletestapp-7984b5ffb6 scaletestapp-87fc668f8 scaletestapp-7bfbc65d66 scaletestapp-58fcc59c7d scaletestapp-6475f44c55



echo.
echo Appling HPA config: %HPA_CONF_FILE%
kubectl apply -f %HPA_CONF_FILE%

@REM TODO: move to another bat file
@REM  echo. 
@REM  echo Monitoring: %HPA_TEST_NAME%
@REM  kubectl get hpa %HPA_TEST_NAME% -w

REM ---------- Ensure Locust is installed for load testing ----------
echo.
echo Checking and installing locust (if it is not installed)

python -c "import locust" >nul 2>&1
if errorlevel 1 (
    echo Locust module not found. Installing locust via pip user install ...
    python -m pip install --user locust
    if errorlevel 1 (
        echo [ERROR] Failed to install locust. Ensure Python and pip are installed and on PATH.
        exit /b 1
    )
)
echo OK: locust is available.
if not exist "%~dp0locustfile.py" (
    echo [ERROR] locustfile.py not found in %~dp0
    exit /b 1
)

echo.
echo Ready to running loading test. 
echo.
echo Press any key to run loading test.
pause >nul

echo Starting loading test on forwarded port 8080.

echo Starting load test on forwarded port 8080.
start "port-forward" /b cmd /c "kubectl port-forward svc/scaletestapp 8080:80"
REM Give the tunnel a few seconds to establish
timeout /t 5 /nobreak >nul
python -m locust -f locustfile.py --host http://localhost:8080 --headless -u 100 -r 20 -t 2m
REM Stop the background tunnel now that the test is done
taskkill /fi "WINDOWTITLE eq port-forward" >nul 2>&1

exit /b 0

:error_smoke
echo.
echo [ERROR] Smoke test failed: could not test metrics-server -n <наименование namespace>
goto :error

:error
echo.
echo [ERROR] Deployment failed. See output above.
exit /b 1
