helm template scaletestapp ./helm/scaletestapp --set image.tag=latest
helm lint ./helm/scaletestapp -f ./helm/scaletestapp/values.yaml