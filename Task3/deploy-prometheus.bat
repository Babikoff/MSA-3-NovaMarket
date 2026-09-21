@echo off
setlocal EnableExtensions

REM ============================================================
REM  deploy-prometheus.bat
REM
REM  Setup of Prometheus monitoring for the "scaletestapp" into Minikube:
REM   - kube-prometheus-stack (Prometheus Operator + CRDs + Prometheus)
REM   - prometheus-adapter (custom.metrics.k8s.io -> Prometheus query)
REM  Applying configs:
REM   - service-monitor.yaml  (target discovery for scaletestapp)
REM   - hpa-by-rps.yaml       (HPA autoscaling on the per-pod RPS metric)
REM
REM  Result:
REM   - Prometheus UI available at http://localhost:9090 (after port-forward)
REM   - HPA "scaletestapp-hpa-rps" autoscale on "http_requests_per_second" adapter config rule
REM ============================================================

cd /d "%~dp0"

set "PROM_REPO=prometheus-community"
set "PROM_REPO_URL=https://prometheus-community.github.io/helm-charts"
set "NS=monitoring"
set "ADAPTER_CONFIG_FILE=%~dp0prometheus-adapter-config.yaml"
set "ADAPTER_CONFIG_NAME=scaletestapp-adapter-config"
set "SERVICE_MONITOR_FILE=%~dp0service-monitor.yaml"
set "HPA_FILE=%~dp0hpa-by-rps.yaml"
set "PROM_KUBE_URL=http://prometheus-kube-prometheus-prometheus.monitoring.svc"

echo ============================================================
echo  Deploying Prometheus stack into Minikube
echo ============================================================

REM ---------- [1/6] Ensure Minikube is running with metrics-server ----------
echo.
echo [1/6] Checking Minikube ...
minikube status >nul 2>&1
if errorlevel 1 (
    echo Minikube is NOT running. Starting it ...
    minikube start --cpus=4 --memory=5120 --addons=metrics-server
    if errorlevel 1 goto :error
) else (
    echo Minikube is running. Enabling metrics-server addon ...
    minikube addons enable metrics-server
)
kubectl get deployment metrics-server -n kube-system >nul 2>&1
if errorlevel 1 goto :error_smoke

REM ---------- [2/6] Add / update Helm repo ----------
echo.
echo [2/6] Ensuring Helm repo %PROM_REPO% ...
helm repo add %PROM_REPO% %PROM_REPO_URL% >nul 2>&1
if errorlevel 1 goto :error
helm repo update
if errorlevel 1 goto :error

REM ---------- [3/6] Install kube-prometheus-stack ----------
echo.
echo [3/6] Installing kube-prometheus-stack (release: prometheus) ...
helm upgrade --install prometheus %PROM_REPO%/kube-prometheus-stack ^
    --namespace %NS% --create-namespace ^
    --set grafana.enabled=false
if errorlevel 1 goto :error

REM ---------- [4/6] Create adapter config + install prometheus-adapter ----------
echo.
echo [4/6] Applying prometheus-adapter config: %ADAPTER_CONFIG_NAME% ...
kubectl apply -f %ADAPTER_CONFIG_FILE%
if errorlevel 1 goto :error

echo [4/6] Installing prometheus-adapter ...
echo   Prometheus URL: %PROM_KUBE_URL%
echo   Adapter ConfigMap: %ADAPTER_CONFIG_NAME%
helm upgrade --install prometheus-adapter %PROM_REPO%/prometheus-adapter ^
    --namespace %NS% ^
    --set prometheus.url=%PROM_KUBE_URL% ^
    --set rules.existing=%ADAPTER_CONFIG_NAME%
if errorlevel 1 goto :error

REM ---------- [5/6] Apply ServiceMonitor + HPA ----------
echo.
echo [5/6] Applying ServiceMonitor and HPA ...
REM Only ONE HPA may control a Deployment (else it shows AmbiguousSelector):
kubectl delete hpa --all --all-namespaces --ignore-not-found=true >nul 2>&1
kubectl apply -f %SERVICE_MONITOR_FILE%
if errorlevel 1 goto :error
kubectl apply -f %HPA_FILE%
if errorlevel 1 goto :error

REM ---------- [6/6] Verify + expose Prometheus UI ----------
echo.
echo [6/6] Verifying registration ...
kubectl --namespace %NS% get prometheus,servicemonitor,pods
kubectl get servicemonitor scaletestapp-mon -n default
kubectl get hpa scaletestapp-hpa-rps

echo.
echo Checking the per-pod custom metric is served by prometheus-adapter ...
kubectl get --raw "/apis/custom.metrics.k8s.io/v1beta1/namespaces/default/pods/*/http_requests_per_second"

echo.
echo ============================================================
echo Script finished. 
echo To see Prometheus UI:
echo   - start port-forwarding:
echo    kubectl --namespace %NS% port-forward svc/prometheus-kube-prometheus-prometheus 9090:9090
echo   - open the URL: http://localhost:9090  and then go to Status -> Targets
echo ============================================================
exit /b 0

:error_smoke
echo.
echo [ERROR] Smoke test failed: metrics-server is not available.
goto :error

:error
echo.
echo [ERROR] Prometheus deployment failed. See output above.
exit /b 1