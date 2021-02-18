```
kubectl create secret generic gcs-key --from-file=gcs.client.default.credentials_file=./silkrode-elasticsearch-backup.json
vim /opt/service-account.json
/usr/share/elasticsearch/bin/elasticsearch-keystore add-file gcs.client.default.credentials_file /opt/service-account.json
systemctl restart elasticsearch
```

```
folder=sit-video
repository=silkrode-$folder


curl -X PUT "localhost:9200/_snapshot/$repository?pretty" -H 'Content-Type: application/json' -d'
{
  "type": "gcs",
  "settings": {
    "bucket": "silkrode_elasticsearch_backup",
    "base_path": "$folder"
  }
}
'

```
# Snapshot and restore APIs

You can use the following APIs to set up snapshot repositories, manage snapshot
backups, and restore snapshots to a running cluster.

For more information, see <<snapshot-restore>>.
## Snapshot repository management APIs
### Put snapshot repository    
Registers or updates a snapshot repository.   
```
curl -X PUT "localhost:9200/_snapshot/silkrode-sit-video?pretty" -H 'Content-Type: application/json' -d'
{
  "type": "gcs",
  "settings": {
    "bucket": "silkrode_elasticsearch_backup",
    "base_path": "sit-video"
  }
}
'
```
### Verify snapshot repository      
Verifies that a snapshot repository is functional.   
```
curl -X POST localhost:9200/_snapshot/silkrode-sit-video/_verify\?pretty   
```
### Get snapshot repository   
Gets information about one or more registered snapshot repositories.   
```
curl -X GET localhost:9200/_snapshot/silkrode-sit-video\?pretty   
```
### Delete snapshot repository      
Unregisters one or more snapshot repositories.   
```
curl -X DELETE localhost:9200/_snapshot/silkrode-sit-video   
```
### Clean up snapshot repository      
Triggers the review of a snapshot repository’s contents and deletes any stale data that is not referenced by existing snapshots.   
```
curl -X POST localhost:9200/_snapshot/silkrode-sit-video/_cleanup\?pretty
```


## Snapshot Management APIs

### Create snapshot
curl -X PUT "localhost:9200/_snapshot/my_repository/my_snapshot?pretty"

### Clone snapshot
curl -X PUT "localhost:9200/_snapshot/my_repository/source_snapshot/_clone/target_snapshot?pretty" -H 'Content-Type: application/json' -d'
{
  "indices": "index_a,index_b"
}
'


### Get snapshot
curl -X GET "localhost:9200/_snapshot/my_repository/my_snapshot?pretty"

### Get snapshot status
curl -X GET "localhost:9200/_snapshot/my_repository/my_snapshot/_status?pretty"

### Restore snapshot
curl -X POST "localhost:9200/_snapshot/my_repository/my_snapshot/_restore?pretty"

### Delete snapshot
curl -X DELETE "localhost:9200/_snapshot/my_repository/my_snapshot?pretty"



