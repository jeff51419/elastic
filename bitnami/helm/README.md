Elasticsearch Helm
===

# GKE

Use tainted node
```
kubectl get nodes --selector cloud.google.com/gke-nodepool=preemptible
kubectl taint nodes nodename preemptible=true:PreferNoSchedule
```

# Install

Elastic
```
NAMESPACE=elasticsearch
RELEASE=elasticsearch

# create namespace
kubectl create namespace elasticsearch
# add storageclass settings
kubectl apply -f storageclass.yaml
# add gcp service account json file
kustomize build elastic/elasticsearch/snapshot | kubectl apply -f - -n ${NAMESPACE}


# Bitnami (Elastic Alternative) 

without APM GUI support

```
kubectl apply -f storageclass.yaml

NAMESPACE=elasticsearch

RELEASE=elasticsearch-1
helm repo add bitnami https://charts.bitnami.com/bitnami/elasticsearch
helm install -n ${NAMESPACE} --values=bitnami-values.yaml --dry-run ${RELEASE} bitnami/elasticsearch

helm install -n ${NAMESPACE} --values=bitnami-values.yaml ${RELEASE} bitnami/elasticsearch
```

# Access

```
kubectl port-forward --namespace elasticsearch svc/elasticsearch-1-coordinating-only 9200:9200 &
curl http://127.0.0.1:9200/

kubectl port-forward --namespace elasticsearch svc/elasticsearch-1-kibana 5601:5601
open http://127.0.0.1:5601/
```

