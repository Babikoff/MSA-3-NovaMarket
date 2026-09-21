# Описание задачи

В данном каталоге приводится решение задачи автоматического маштабирования приложения в кластере Kubernetes по стандартным параметрам Kubernetes (в данном случае памяти) и произвольным параметрам (в данном случае RPS).

# Запуск теста HPA by memory usage

Task3\deploy-hpa-by-mem.bat

# Запуск теста HPA by RPS

**Установка и конфигурирование Prometeus**
Task3\deploy-prometheus.bat

**Открытие порта**
kubectl --namespace monitoring port-forward svc/prometheus-kube-prometheus-prometheus 9090:9090
 
**Простмотр в UI** 
open http://localhost:9090 -> Status -> Targets

**Запуск теста**
Task3\deploy-hpa-by-rps.bat                   # (already does image load + chart + HPA + locust)

# Очистка кластера после теста
Task3\clean-prometheus.bat