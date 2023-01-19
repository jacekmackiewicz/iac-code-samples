Get-Date
# Warning!!! This script has to be run on same machine to ensure idempotency
# It's due to ~\.azure\aksServicePrincipal.json file being created by az aks create command
Write-Output "Warning!!! This script has to be run on same machine to ensure idempotency"

$SubscriptionId = "hash"
$ResourceGroup = "project-dev"
$Location = "north europe"
$ClusterName = "project-aks-dev"
$WindowsAdmin = "nonstandarduser"
$WindowsPassword = "#{WindowsPoolPassword}#"
$WindowsNodePoolName = "npwin"
$ContainerRegistryName = "projectregistrydev"
$LogAnalyticsWorkspaceName = "project-aks-monitoring-dev"

az account set --subscription $SubscriptionId
az group create --name $ResourceGroup --location $Location

az acr create `
    --resource-group $ResourceGroup `
    --name $ContainerRegistryName `
    --sku Standard
$LogAnalyticsWorkspaceID = $(az monitor log-analytics workspace create `
    --resource-group $ResourceGroup `
    --workspace-name $LogAnalyticsWorkspaceName `
    --query id `
    -o tsv)
az aks create `
    --resource-group $ResourceGroup `
    --name $ClusterName `
    --kubernetes-version 1.20.15 `
    --node-count 3 `
    --node-vm-size Standard_D2as_v4 `
    --vm-set-type VirtualMachineScaleSets `
    --enable-addons monitoring `
    --generate-ssh-keys `
    --load-balancer-sku standard `
    --network-plugin azure `
    --windows-admin-password $WindowsPassword `
    --windows-admin-username $WindowsAdmin `
    --workspace-resource-id $LogAnalyticsWorkspaceID
az aks nodepool add `
    --resource-group $ResourceGroup `
    --cluster-name $ClusterName `
    --kubernetes-version 1.20.15 `
    --os-type Windows `
    --name $WindowsNodePoolName `
    --node-count 1 `
    --node-vm-size Standard_D4as_V4

# Get the service principal ID of your AKS cluster
$AKS_SP_ID = $(az aks show --resource-group $ResourceGroup --name $ClusterName --query "servicePrincipalProfile.clientId" -o tsv)
# Get the resource ID of your ACR instance
$ACR_RESOURCE_ID = $(az acr show --resource-group $ResourceGroup --name $ContainerRegistryName --query "id" -o tsv)
# Create a role assignment for your AKS cluster to access the ACR instance
az role assignment create --assignee $AKS_SP_ID --scope $ACR_RESOURCE_ID --role contributor

$ContainerRegistryId = az acr show `
    --name $ContainerRegistryName `
    --subscription $SubscriptionId `
    --query id `
    -o tsv
az aks update `
    --resource-group $ResourceGroup `
    --name $ClusterName `
    --attach-acr $ContainerRegistryId

Get-Date
