#!/usr/bin/env bash
set -x
set -euo pipefail

set -o allexport; source .env; set +o allexport


wait_for_output() {
  local cmd=$1; shift
  local value=$1; shift

  while true; do
    output="$(eval "$cmd")" && [ "$output" = "$value" ] && echo "finished"; return 0 || echo "waiting"; sleep 5
  done
}

az account set --subscription $SUBSCRIPTION


### --- as needed register provider -- ###
az extension add --name aks-preview
az extension update --name aks-preview
az feature register --namespace "Microsoft.ContainerService" --name "EnableWorkloadIdentityPreview"
# wait till registered
#az feature show --namespace "Microsoft.ContainerService" --name "EnableWorkloadIdentityPreview"
wait_for_output "az feature show --namespace Microsoft.ContainerService --name EnableWorkloadIdentityPreview | jq -r .properties.state" "Registered"

# when done
az provider register --namespace Microsoft.ContainerService


### --- create resource group --- ###
if [ $(az group exists --name $RESOURCEGROUPNAME) = false ]; then
    az group create --name $RESOURCEGROUPNAME --location $LOCATION
fi

### --- create keyvault --- ###
kvresult=$(az rest --method post \
    --uri "https://management.azure.com/subscriptions/$SUBSCRIPTION/providers/Microsoft.KeyVault/checkNameAvailability?api-version=2019-09-01" \
    --headers 'Content-Type=application/json' \
    --body "{\"name\": \"$KEYVAULT_NAME\",\"type\": \"Microsoft.KeyVault/vaults\"}")

kvresult=$(echo $kvresult | jq -r .nameAvailable)

if [ $kvresult = true ]; then
    az keyvault create --resource-group $RESOURCEGROUPNAME --name $KEYVAULT_NAME --location $LOCATION
fi

### --- create user assigned identity --- ###
az identity create --name "$UAID" --resource-group "$RESOURCEGROUPNAME" --location "$LOCATION" --subscription "$SUBSCRIPTION"

### --- assign keyvault policy to user assigned identity --- ###
export USER_ASSIGNED_CLIENT_ID="$(az identity show --resource-group "$RESOURCEGROUPNAME" --name "$UAID" --query 'clientId' -otsv)"
sleep 30
az keyvault set-policy --name "$KEYVAULT_NAME" --secret-permissions get --spn "$USER_ASSIGNED_CLIENT_ID"
az keyvault set-policy --name "$KEYVAULT_NAME" --key-permissions get --spn "$USER_ASSIGNED_CLIENT_ID"
az keyvault set-policy --name "$KEYVAULT_NAME" --certificate-permissions get --spn "$USER_ASSIGNED_CLIENT_ID"