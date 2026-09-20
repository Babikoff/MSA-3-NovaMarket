@echo off

REM ============================================================
REM  deploy-hpa-by-mem.bat
REM  Deploy/redeploy scaletestapp into Minikube using hpa-by-mem.yaml Horizontal Pod Autoscaler (HPA) config.
REM ============================================================

call "%~dp0deploy-common.bat" ./hpa-by-mem.yaml scaletestapp-hpa-mem test-booking-staging 8081
exit /b %errorlevel%