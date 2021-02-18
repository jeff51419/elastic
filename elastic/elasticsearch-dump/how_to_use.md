login k8s and switch to elasticsearch namespace

# create a nginx pod

```
kubectl run nginx --image=nginx
```

# exec nginx
```
kubectl exec -it nginx -- sh
```

# install npm and elasticdump
```
apt update
apt install npm -y
npm install elasticdump -g
```

# move index from local elasticsearch to k9s elasticsearch 

```
elasticdump \
  --input=http://prod-game-es-tw-m01.gcp.silkrode.com.tw:9200/prod-game-event-20201223 \
  --output=http://elasticsearch-master.elasticsearch.svc.cluster.local:9200/prod-game-event-20201223 \
  --type=analyzer
elasticdump \
  --input=http://prod-game-es-tw-m01.gcp.silkrode.com.tw:9200/prod-game-event-20201223 \
  --output=http://elasticsearch-master.elasticsearch.svc.cluster.local:9200/prod-game-event-20201223 \
  --type=mapping
elasticdump \
  --input=http://prod-game-es-tw-m01.gcp.silkrode.com.tw:9200/prod-game-event-20201223 \
  --output=http://elasticsearch-master.elasticsearch.svc.cluster.local:9200/prod-game-event-20201223 \
  --type=data
```