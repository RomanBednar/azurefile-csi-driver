## Driver Parameters
`file.csi.azure.com` driver parameters

### Dynamic Provision
  > get a [example](../deploy/example/storageclass-azurefile-csi.yaml)

Name | Meaning | Example | Mandatory | Default value 
--- | --- | --- | --- | ---
skuName | Azure file storage account type (alias: `storageAccountType`) | `Standard_LRS`, `Standard_ZRS`, `Standard_GRS`, `Standard_RAGRS`, `Premium_LRS`, `Premium_ZRS` | No | `Standard_LRS` <br><br> Note:  <br> 1. minimum file share size of Premium account type is `100GB`<br> 2.[`ZRS` account type](https://docs.microsoft.com/en-us/azure/storage/common/storage-redundancy#zone-redundant-storage) is supported in limited regions <br> 3. NFS file share only supports Premium account type
storageAccount | specify Azure storage account name| STORAGE_ACCOUNT_NAME | No | if empty, driver will find a suitable storage account that matches account settings in the same resource group; if a storage account name is provided, storage account must exist.
enableLargeFileShares | specify whether to use a storage account with large file shares enabled or not. If this flag is set to true and a storage account with large file shares enabled doesn't exist, a new storage account with large file shares enabled will be created. This flag should be used with the standard sku as the storage accounts created with premium sku have largeFileShares option enabled by default.  | `true`,`false` | No | `false`
protocol | specify file share protocol | `smb`, `nfs` (`nfs` is in [Preview](https://github.com/kubernetes-sigs/azurefile-csi-driver/tree/master/deploy/example/nfs)) | No | `smb`
networkEndpointType | specify network endpoint type for the storage account created by driver. If `privateEndpoint` is specified, a private endpoint will be created for the storage account. For other cases, a service endpoint will be created by default. | "",`privateEndpoint` | No | ``
location | specify Azure storage account location | `eastus`, `westus`, etc. | No | if empty, driver will use the same location name as current k8s cluster
resourceGroup | specify the resource group in which Azure file share will be created | existing resource group name | No | if empty, driver will use the same resource group name as current k8s cluster
shareName | specify Azure file share name | existing or new Azure file name | No | if empty, driver will generate an Azure file share name
accessTier | [Access tier for file share](https://docs.microsoft.com/en-us/azure/storage/files/storage-files-planning#storage-tiers) | GpV2 account can choose between `TransactionOptimized` (default), `Hot`, and `Cool`. FileStorage account can choose `Premium` | No | empty(use default setting for different storage account types)
shareName | specify Azure file share name | existing or new Azure file name | No | if empty, driver will generate an Azure file share name
server | specify Azure storage account server address | existing server address, e.g. `accountname.privatelink.file.core.windows.net` | No | if empty, driver will use default `accountname.file.core.windows.net` or other sovereign cloud account address
storeAccountKey | whether store account key to k8s secret | `true`,`false` | No | `true`
secretName | specify secret name to store account key | | No |
secretNamespace | specify the namespace of secret to store account key | `default`,`kube-system`, etc | No | `default`
useDataPlaneAPI | specify whether use [data plane API](https://github.com/Azure/azure-sdk-for-go/blob/master/storage/share.go) for file share create/delete/resize | `true`,`false` | No | `false`
disableDeleteRetentionPolicy | specify whether disable DeleteRetentionPolicy for storage account created by driver | `true`,`false` | No | `false`
allowBlobPublicAccess | Allow or disallow public access to all blobs or containers for storage account created by driver | `true`,`false` | No | `false`
storageEndpointSuffix | specify Azure storage endpoint suffix | `core.windows.net` | No | if empty, driver will use default storage endpoint suffix according to cloud environment, e.g. `core.windows.net`
tags | [tags](https://docs.microsoft.com/en-us/azure/azure-resource-manager/management/tag-resources) would be created in newly created storage account | tag format: 'foo=aaa,bar=bbb' | No | ""
--- | **Following parameters are only for [VHD disk feature](../deploy/example/disk)** | --- | --- |
fsType | File System Type | `ext4`, `ext3`, `ext2`, `xfs` | Yes | `ext4`
diskName | existing VHD disk file name | `pvc-062196a6-6436-11ea-ab51-9efb888c0afb.vhd` | No |

 - account tags format created by dynamic provisioning
```
k8s-azure-created-by: azure
```

 - file share name format created by dynamic provisioning(example)
```
pvc-92a4d7f2-f23b-4904-bad4-2cbfcff6e388
```

### Static Provision(bring your own file share)
  > get a [smb pv example](../deploy/example/pv-azurefile-csi.yaml)

  > get a [nfs pv example](../deploy/example/pv-azurefile-nfs.yaml)

Name | Meaning | Available Value | Mandatory | Default value
--- | --- | --- | --- | ---
volumeAttributes.resourceGroup | Azure resource group name | existing resource group name | No | if empty, driver will use the same resource group name as current k8s cluster
volumeAttributes.storageAccount | existing storage account name | existing storage account name | Yes |
volumeAttributes.shareName | Azure file share name | existing Azure file share name | Yes |
volumeAttributes.protocol | specify file share protocol | `smb`, `nfs` | No | `smb`
volumeAttributes.server | specify Azure storage account server address | existing server address, e.g. `accountname.privatelink.file.core.windows.net` | No | if empty, driver will use default `accountname.file.core.windows.net` or other sovereign cloud account address
volumeAttributes.secretName | secret name that stores storage account name and key | | No |
volumeAttributes.secretNamespace | secret namespace  | `default`,`kube-system`, etc | No | `default`
nodeStageSecretRef.name | secret name that stores storage account name and key | existing secret name |  Yes  |
nodeStageSecretRef.namespace | secret namespace | k8s namespace  |  Yes  |

 - create a Kubernetes secret for `nodeStageSecretRef.name`
 ```console
kubectl create secret generic azure-secret --from-literal=azurestorageaccountname="xxx" --from-literal azurestorageaccountkey="xxx" --type=Opaque
 ```
