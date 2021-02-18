# add gcs credentials for gcs access 
```
kubectl create secret generic gcs-key --from-file=gcs.client.default.credentials_file=./company-elasticsearch-backup.json
vim /opt/service-account.json
/usr/share/elasticsearch/bin/elasticsearch-keystore add-file gcs.client.default.credentials_file /opt/service-account.json
systemctl restart elasticsearch
```

# create repository 
```
folder=sit-video
repository=company-$folder


curl -X PUT "localhost:9200/_snapshot/$repository?pretty" -H 'Content-Type: application/json' -d'
{
  "type": "gcs",
  "settings": {
    "bucket": "company_elasticsearch_backup",
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
curl -X PUT "localhost:9200/_snapshot/company-sit-video?pretty" -H 'Content-Type: application/json' -d'
{
  "type": "gcs",
  "settings": {
    "bucket": "company_elasticsearch_backup",
    "base_path": "sit-video"
  }
}
'
```
### Verify snapshot repository      
Verifies that a snapshot repository is functional.   
```
curl -X POST localhost:9200/_snapshot/company-sit-video/_verify\?pretty   
```
### Get snapshot repository   
Gets information about one or more registered snapshot repositories.   
```
curl -X GET localhost:9200/_snapshot/company-sit-video\?pretty   
```
### Delete snapshot repository      
Unregisters one or more snapshot repositories.   
```
curl -X DELETE localhost:9200/_snapshot/company-sit-video   
```
### Clean up snapshot repository      
Triggers the review of a snapshot repository’s contents and deletes any stale data that is not referenced by existing snapshots.   
```
curl -X POST localhost:9200/_snapshot/company-sit-video/_cleanup\?pretty
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

curl -X POST "localhost:9200/_snapshot/my_repository/my_snapshot/_restore?wait_for_completion=true&pretty" -H 'Content-Type: application/json' -d'
{
  "indices": "index_1,index_2",
  "ignore_unavailable": true,
  "include_global_state": false,
  "rename_pattern": "index_(.+)",
  "rename_replacement": "restored_index_$1",
  "include_aliases": false
}
'

curl -X POST "localhost:9200/_snapshot/company-prod-oolong/202011220836/_restore?wait_for_completion=true&pretty" -H 'Content-Type: application/json' -d'
{
  "indices": "company-k8s-2020.11.04",
  "ignore_unavailable": true,
  "include_global_state": false,
  "include_aliases": false
}
'

### Delete snapshot
curl -X DELETE "localhost:9200/_snapshot/my_repository/my_snapshot?pretty"



