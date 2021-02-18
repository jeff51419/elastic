#!/bin/bash

folder=$(kubectl config current-context | awk -F '_' '{print $4}' | awk -F '-' '{print $1"-"$2}')
repository=silkrode-$folder

echo "grep 'kubectl current-context for cluster name'"
echo "cluster name: $folder"
echo ""
echo "-----------------------------------------------"

echo "SET cluster's gcs repository name: $repository"
echo "SET snapshot's folder name: $folder"
echo ""
echo "-----------------------------------------------"

echo "##### create gcs repository in GCS #####"
# kubectl exec -n elasticsearch -it elasticsearch-master-0 -- sh -c "curl -X POST 127.0.0.1:9200/_snapshot/$repository/_verify\?pretty"

kubectl exec -n elasticsearch -it elasticsearch-master-0 -- sh -c "curl -X POST elasticsearch-master:9200/_snapshot/$repository\?pretty -H 'Content-Type: application/json' -d'{\"type\": \"gcs\", \"settings\": {\"bucket\": \"silkrode_elasticsearch_backup\",\"base_path\": \"$folder\"}}'"
echo ""
echo "-----------------------------------------------"
echo "##### verify gcs repository in GCS #####"

kubectl exec -n elasticsearch -it elasticsearch-master-0 -- sh -c "curl -X POST elasticsearch-master:9200/_snapshot/$repository/_verify\?pretty"

echo ""
echo "-----------------------------------------------"

echo "##### replace the repository value in curator-values.yaml #####"

sed -i '' -e "86s/repository: .*/repository: $repository/g" curator-values.yaml
grep $repository curator-values.yaml
echo ""
echo "-----------------------------------------------"

echo "you can use new curator-values.yaml to helm install curator"
echo "check readme.md to install"
echo "helm install -n elasticsearch --values=curator-values.yaml curator stable/elasticsearch-curator --version 2.2.1"