@echo off

REM ============================================================
REM  deploy-hpa-by-mem.bat
REM  Deploy/redeploy scaletestapp into Minikube using hpa-by-rps.yaml Horizontal Pod Autoscaler (HPA) config.
REM ============================================================

call "%~dp0deploy-common.bat" ./hpa-by-mem.yaml
exit /b %errorlevel%