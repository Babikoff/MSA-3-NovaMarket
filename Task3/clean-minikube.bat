@REM Full clean
@REM  minikube stop
@REM  minikube delete --force

echo.
echo 1) Remove HPAs
@REM Remove known HPAs
kubectl delete hpa scaletestapp-hpa-mem
kubectl delete hpa scaletestapp-hpa-rps
@REM Remove all other unknown HPAs
kubectl delete hpa --all --all-namespaces

echo.
echo 2) Delete the Helm-tracked Deployment "scaletestapp"
helm delete scaletestapp

kubectl get pods --all-namespaces
kubectl get deployments --all-namespaces
kubectl get hpa --all-namespaces