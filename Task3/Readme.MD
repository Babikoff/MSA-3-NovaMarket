# Описание задачи

В данном каталоге приводится решение задачи автоматического маштабирования приложения в кластере Kubernetes по стандартным параметрам Kubernetes (в данном случае памяти) и произвольным параметрам (в данном случае RPS).

# Запуск теста HPA by memory usage #

**Запуск мониторинга** 
Task3\monitor-hpa-by-mem.bat

**Запуск теста**
Task3\deploy-hpa-by-mem.bat

**Запуск Locust UI**
python -m locust -f locustfile.py --host http://localhost:8080
http://localhost:8089/

**Очистка кластера после теста**
Task3\clean-minikube.bat

# Запуск теста HPA by RPS #

**Установка и конфигурирование Prometeus**
Task3\deploy-prometheus.bat

**Открытие порта**
kubectl --namespace monitoring port-forward svc/prometheus-kube-prometheus-prometheus 9090:9090
 
**Простмотр в UI** 
Task3\monitor-prometheus.bat
http://localhost:9090 -> Status -> Target health

**Запуск мониторинга** 
Task3\monitor-hpa-by-mem.bat

**Запуск теста**
Task3\deploy-hpa-by-rps.bat

**Запуск Locust UI**
`python -m locust -f locustfile.py --host http://localhost:8080`
http://localhost:8089/

**Очистка кластера после теста**
Task3\clean-prometheus.bat
