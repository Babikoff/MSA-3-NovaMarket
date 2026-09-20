helm template scaletestapp ./helm/scaletestapp -f ./helm/scaletestapp/values-staging.yaml --set image.tag=latest
helm lint ./helm/scaletestapp -f ./helm/scaletestapp/values-staging.yaml
helm lint ./helm/scaletestapp -f ./helm/scaletestapp/values-prod.yaml
helm lint ./helm/scaletestapp -f ./helm/scaletestapp/values.yaml