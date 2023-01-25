
## not working
https://learn.microsoft.com/en-us/azure/aks/learn/tutorial-kubernetes-workload-identity

## try
https://learn.microsoft.com/en-us/azure/aks/csi-secrets-store-driver#set-an-environment-variable-to-reference-kubernetes-secrets

https://learn.microsoft.com/en-us/azure/aks/csi-secrets-store-nginx-tls

?? https://github.com/kubernetes/ingress-nginx/issues/9282
?? https://learn.microsoft.com/en-us/azure/aks/csi-secrets-store-identity-access
?? https://learn.microsoft.com/en-us/azure/aks/csi-secrets-store-identity-access



#https://learn.microsoft.com/en-us/azure/aks/csi-secrets-store-driver?tryIt=true&source=docs#code-try-0
#https://learn.microsoft.com/en-us/azure/aks/csi-secrets-store-identity-access
#https://learn.microsoft.com/en-us/azure/aks/learn/tutorial-kubernetes-workload-identity 


# https://samcogan.com/creating-kubernetes-secrets-from-azure-key-vault-with-the-csi-driver/
# https://azure.github.io/secrets-store-csi-driver-provider-azure/docs/configurations/identity-access-modes/workload-identity-mode/
# https://learn.microsoft.com/en-us/troubleshoot/azure/azure-kubernetes/troubleshoot-key-vault-csi-secrets-store-csi-driver




MountVolume.SetUp failed for volume "secrets-store01-inline" : rpc error: code = Unknown desc = failed to mount secrets store objects for pod default/busybox-secrets-store-inline-user-msi, err: rpc error: code = Unknown desc = failed to mount objects, error: failed to get objectType:secret, objectName:secret1, objectVersion:: keyvault.BaseClient#GetSecret: Failure responding to request: StatusCode=404 -- Original Error: autorest/azure: Service returned an error. Status=404 Code="SecretNotFound" Message="A secret with (name/id) secret1 was not found in this key vault. If you recently deleted this secret you may be able to recover it using the correct recovery command. For help resolving this issue, please see https://go.microsoft.com/fwlink/?linkid=2125182"


MountVolume.SetUp failed for volume "secrets-store-inline" : fetching NodePublishSecretRef default/secrets-store-creds failed: kubernetes.io/csi: failed to find the secret secrets-store-creds in the namespace default with error: secrets "secrets-store-creds" not found



MountVolume.SetUp failed for volume "secrets-store-inline" : rpc error: code = Unknown desc = failed to mount secrets store objects for pod default/busybox-secrets-store-inline, err: rpc error: code = Unknown desc = failed to mount objects, error: failed to create auth config, error: failed to get credentials, nodePublishSecretRef secret is not set

MountVolume.SetUp failed for volume "secrets-store01-inline" : rpc error: code = Unknown desc = failed to mount secrets store objects for pod default/busybox-secrets-store-inline-workload-identity, err: rpc error: code = Unknown desc = failed to mount objects, error: failed to get objectType:key, objectName:key1, objectVersion:: keyvault.BaseClient#GetKey: Failure responding to request: StatusCode=404 -- Original Error: autorest/azure: Service returned an error. Status=404 Code="KeyNotFound" Message="A key with (name/id) key1 was not found in this key vault. If you recently deleted this key you may be able to recover it using the correct recovery command. For help resolving this issue, please see https://go.microsoft.com/fwlink/?linkid=2125182"


```
Extension 'aks-preview' 0.5.123 is already installed.
+ az extension update --name aks-preview
The 'aks-preview' extension version 0.5.127 is not compatible with your current CLI core version 2.43.0.
This extension requires a min of 2.44.0 CLI core.
Please run 'az upgrade' to upgrade to a compatible version.
```