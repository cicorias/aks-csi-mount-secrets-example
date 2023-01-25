#!/usr/bin/env bash
set -x
set -euo pipefail

set -o allexport; source .env; set +o allexport

export USER_ASSIGNED_CLIENT_ID="$(az identity show --resource-group "$RESOURCEGROUPNAME" --name "$UAID" --query 'clientId' -otsv)"
export KEYVAULT_URL="$(az keyvault show -g $RESOURCEGROUPNAME -n $KEYVAULT_NAME --query properties.vaultUri -o tsv)"

az keyvault secret set --vault-name $KEYVAULT_NAME -n $KEYVAULT_SECRET_NAME1 --value "secret1"
# az keyvault secret set --vault-name $KEYVAULT_NAME -n $KEYVAULT_SECRET_NAME2 --value "secret2"

az keyvault key create --vault-name $KEYVAULT_NAME -n $KEYVAULT_KEY_NAME1 --kty RSA --size 2048

### --- create cluster --- ###
#create aks cluster -- with workload identity
# TEMP -- exists
az aks create -g $RESOURCEGROUPNAME \
    --name $AKS_CLUSTER_NAME \
    --location $LOCATION \
    --node-count $nodeCount \
    --enable-oidc-issuer \
    --enable-workload-identity \
    --enable-addons azure-keyvault-secrets-provider

export AKS_OIDC_ISSUER="$(az aks show -n $AKS_CLUSTER_NAME -g $RESOURCEGROUPNAME --query "oidcIssuerProfile.issuerUrl" -otsv)"
export IDENTITY_TENANT=$(az aks show --name $AKS_CLUSTER_NAME --resource-group $RESOURCEGROUPNAME --query identity.tenantId -o tsv)

az aks get-credentials -n $AKS_CLUSTER_NAME -g "${RESOURCEGROUPNAME}"

## --- create service account --- ##
cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: ServiceAccount
metadata:
  annotations:
    azure.workload.identity/client-id: ${USER_ASSIGNED_CLIENT_ID}
  labels:
    azure.workload.identity/use: "true"
  name: ${SERVICE_ACCOUNT_NAME}
  namespace: ${SERVICE_ACCOUNT_NAMESPACE}
EOF

### --- setup federated credential linkage --- ###
# TEMP -- exists already...
az identity federated-credential create \
    --name ${FICID} \
    --identity-name ${UAID} \
    --resource-group ${RESOURCEGROUPNAME} \
    --issuer ${AKS_OIDC_ISSUER} \
    --subject system:serviceaccount:${SERVICE_ACCOUNT_NAMESPACE}:${SERVICE_ACCOUNT_NAME}

sleep 30
echo "should be ready to go... check with kubectl get secretproviderclass -n ${SERVICE_ACCOUNT_NAMESPACE} -o yaml"

