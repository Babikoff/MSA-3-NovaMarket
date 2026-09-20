@REM Full clean
@REM  minikube stop
@REM  minikube delete --force

kubectl delete hpa scaletestapp-hpa-mem
kubectl delete hpa --all --all-namespaces

helm delete scaletestapp

kubectl get pods --all-namespaces
kubectl get deployments --all-namespaces
kubectl get hpa --all-namespaces