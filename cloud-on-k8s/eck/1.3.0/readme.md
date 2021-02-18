Install custom resource definitions and the operator with its RBAC rules:

kubectl apply -f https://download.elastic.co/downloads/eck/1.3.0/all-in-one.yaml

Monitor the operator logs:

kubectl -n elastic-system logs -f statefulset.apps/elastic-operator