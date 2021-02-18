Volume claim templatesedit

Specifying the volume claim settingsedit
By default, the operator creates a PersistentVolumeClaim with a capacity of 1Gi for each pod in an Elasticsearch cluster to prevent data loss in case of accidental pod deletion. For production workloads, you should define your own volume claim template with the desired storage capacity and (optionally) the Kubernetes storage class to associate with the persistent volume. The name of the volume claim must always be elasticsearch-data.

ECK automatically deletes PersistentVolumeClaim resources if they are not required for any Elasticsearch node. The corresponding PersistentVolume may be preserved, depending on the configured storage class reclaim policy.

Updating the volume claim settingsedit
If the storage class allows volume expansion, you can increase the storage requests size in the volumeClaimTemplates. ECK will update the existing PersistentVolumeClaims accordingly, and recreate the StatefulSet automatically. If the volume driver supports ExpandInUsePersistentVolumes, the filesystem is resized online, without the need of restarting the Elasticsearch process, or re-creating the Pods. If the volume driver does not support ExpandInUsePersistentVolumes, Pods must be manually deleted after the resize, to be recreated automatically with the expanded filesystem.

Any other changes are forbidden in the volumeClaimTemplates, such as changing the storage class or decreasing the volume size. To make these changes, you can create a new nodeSet with different settings, and remove the existing nodeSet. In practice, that’s equivalent to renaming the existing nodeSet while modifying its claim settings in a single update. Before removing Pods of the deleted nodeSet, ECK makes sure that data is migrated to other nodes.