Elasticsearch Helm
===

This document describe steps of install elasticsearch with helm chart.

# preemptible node
請先準備preemptible node   
- [terragrunt](https://gitlab.company.com.tw/team_devops/terraform-infra/tree/master/gcp/terragrunt)   
![gke_preemptible](picture/gke_preemptible.png)   

# Helm v3
請先準備 helm v3   

## Through Package Managers
### From Homebrew (macOS)
```
brew install helm
```
### From Chocolatey (Windows)
```
choco install kubernetes-helm
```

## From Script
```
$ curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/master/scripts/get-helm-3
$ chmod 700 get_helm.sh
$ ./get_helm.sh
```


# Chart
請先準備 Chart repo   

- [Elastic](https://github.com/elastic/helm-charts)   
#新增 elastic repo
```
helm repo add elastic https://helm.elastic.co
```
- [Bitnami](https://charts.bitnami.com/bitnami)   
#新增 bitnami repo
```
helm repo add bitnami https://charts.bitnami.com/bitnami
```
- [Stable](https://charts.helm.sh/stable)   
#新增 stable repo
```
helm repo add stable https://charts.helm.sh/stable
```

# GKE
check tainted on preemptible node   
```
kubectl get nodes --selector cloud.google.com/gke-nodepool=preemptible   
```


# Prepare elasticsearch image, gcs credentials and storageclass


已經準備好elasticsearch version = 7.8.0的版本   
如果以後想用新版本的elasticsearch 就要再docker build 一次   


已經準備好company-elasticsearch-backup.json，等elasticsearch namespace建好就可以apply as secret   

[storageclass](storageclass.yaml)   
已經準備好ssd storageclass yaml，等elasticsearch namespace建好就可以apply
 

# Elasticsearch helm install
### please modify elasticsearch-values.yaml first 
[elasticsearch-values](elasticsearch-values.yaml)

### please ensure what storage class and size of disk first   


### please change the correct elasticsearch ingress   


### create namespace
```
kubectl create namespace elasticsearch
```

### add storageclass settings
```
kubectl apply -f storageclass.yaml
```

### add gcp service account json file
```
kustomize build elastic/elasticsearch/snapshot | kubectl apply -f - -n elasticsearch
```

## Elasticsearch helm install
```
helm install -n elasticsearch --values=elasticsearch-values.yaml --dry-run elasticsearch elastic/elasticsearch
helm install -n elasticsearch --values=elasticsearch-values.yaml elasticsearch elastic/elasticsearch
```

## Elasticsearch helm upgrade
```
helm upgrade -n elasticsearch --values=elasticsearch-values.yaml elasticsearch elastic/elasticsearch --dry-run
helm upgrade -n elasticsearch --values=elasticsearch-values.yaml elasticsearch elastic/elasticsearch 
```

---

# Kibana

### please change the correct kibana ingress   


## kibana helm install
```
helm install -n elasticsearch --values=kibana-values.yaml kibana elastic/kibana --dry-run 
helm install -n elasticsearch --values=kibana-values.yaml kibana elastic/kibana
```

## kibana helm Upgrade
```
helm upgrade -n elasticsearch --values=kibana-values.yaml kibana elastic/kibana --dry-run
helm upgrade -n elasticsearch --values=kibana-values.yaml kibana elastic/kibana 
```
---

# Apm server
apm server 設定不需要改動

## Apm helm install
```
helm install -n elasticsearch --values=apm-server-values.yaml apm-server elastic/apm-server --dry-run 
helm install -n elasticsearch --values=apm-server-values.yaml apm-server elastic/apm-server
```

## Apm helm Upgrade
```
helm upgrade -n elasticsearch --values=apm-server-values.yaml apm-server elastic/apm-server --dry-run
helm upgrade -n elasticsearch --values=apm-server-values.yaml apm-server elastic/apm-server  
```
---

# Logstash
[logstash](logstash-values.yaml)   
這是最主要的部分 調整input, filter, output, 這部分不會變動


logstash monitor exporter 啟動(預設 enabled: true)後就有service monitor 給 prometheus 資料


## logstash helm install
```
helm install -n elasticsearch --values=logstash-values.yaml logstash bitnami/logstash --dry-run 
helm install -n elasticsearch --values=logstash-values.yaml logstash bitnami/logstash
```

## logstash helm upgrade
```
helm upgrade -n elasticsearch --values=logstash-values.yaml logstash bitnami/logstash --dry-run
helm upgrade -n elasticsearch --values=logstash-values.yaml logstash bitnami/logstash 
```
---

# Curator
prod 和 sit 會用不同的values.yaml -> 因為prod elasticsearch 會需要備份
使用creation_date 這個欄位，大於１４天會刪除
https://www.elastic.co/guide/en/elasticsearch/client/curator/current/fe_source.html#_creation_date_based_ages_2

## sit
[curator-sit](curator-values-sit.yaml) 

直接helm install就好, action 只有刪除index,沒有snapshot


### helm install curator
```
helm install -n elasticsearch --values=curator-values-sit.yaml --dry-run curator stable/elasticsearch-curator --version 2.2.1
helm install -n elasticsearch --values=curator-values-sit.yaml curator stable/elasticsearch-curator --version 2.2.1
```

## prod
[curator-prod](curator-values.yaml) 

prod curator 會需要   

### 準備repository 和 folder 變數
```
#set up the snaphot gcs setting var
folder=$(kubectl config current-context | awk -F '_' '{print $4}' | awk -F '-' '{print $1"-"$2}')
repository=company-$folder
```


### 先去GCS建立資料夾



### create snapshot repoitory
```
# create snapshot repoitory 
kubectl exec -n elasticsearch -it elasticsearch-master-0 -- sh -c "curl -X POST elasticsearch-master:9200/_snapshot/$repository\?pretty -H 'Content-Type: application/json' -d'{\"type\": \"gcs\", \"settings\": {\"bucket\": \"company_elasticsearch_backup\",\"base_path\": \"$folder\"}}'"
```

### verify gcs repository in GCS
```
kubectl exec -n elasticsearch -it elasticsearch-master-0 -- sh -c "curl -X POST elasticsearch-master:9200/_snapshot/$repository/_verify\?pretty"

kubectl exec -n elasticsearch -it elasticsearch-master-0 -- sh -c "curl -X GET elasticsearch-master:9200/_snapshot/$repository\?pretty"
```


### verify gcs repository in GCS
我們要取代第86行，repository的名稱   

```
# replace the repository value in curator-values.yaml
sed -i '' -e "86s/repository: .*/repository: $repository/g" curator-values.yaml
```


### helm install

```
helm install -n elasticsearch --values=curator-values.yaml curator stable/elasticsearch-curator --version 2.2.1 --dry-run
helm install -n elasticsearch --values=curator-values.yaml curator stable/elasticsearch-curator --version 2.2.1
```

### helm upgrade
```
helm upgrade -n elasticsearch --values=curator-values.yaml curator stable/elasticsearch-curator --version 2.2.1 --dry-run
helm upgrade -n elasticsearch --values=curator-values.yaml curator stable/elasticsearch-curator --version 2.2.1
```