echo.
echo Use http://localhost:9090 in the browser to see the Prometheus UI
kubectl --namespace monitoring port-forward svc/prometheus-kube-prometheus-prometheus 9090:9090
