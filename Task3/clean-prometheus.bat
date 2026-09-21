@echo off
setlocal EnableExtensions

REM ============================================================
REM  clean-prometheus.bat
REM
REM  Removes the Prometheus stack (kube-prometheus-stack, the
REM  CustomResourceDefinitions, prometheus-adapter and the monitoring
REM  namespace) plus the HPA and ServiceMonitor applied in the default
REM  namespace.
REM ============================================================

cd /d "%~dp0"

echo Removing ServiceMonitor ...
kubectl delete servicemonitor scaletestapp-mon -n default --ignore-not-found=true

echo Removing HPA ...
kubectl delete hpa scaletestapp-hpa-rps --ignore-not-found=true

echo Uninstalling prometheus-adapter ...
helm uninstall prometheus-adapter --namespace monitoring --ignore-not-found

echo Uninstalling kube-prometheus-stack ...
helm uninstall prometheus --namespace monitoring --ignore-not-found

echo Removing monitoring namespace (deletes CRDs) ...
kubectl delete namespace monitoring --ignore-not-found=true

echo.
echo Cleanup complete.
kubectl get servicemonitor --all-namespaces 2>nul
kubectl get hpa --all-namespaces
exit /b 0