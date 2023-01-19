$environment = $args[0]

if (!($environment -eq 'Dev' -or $environment -eq 'Prod' -or $environment -eq 'Qa')) {
    Write-Output "Please use available environments: prod, dev, qa. Exiting..."
    exit}

$environment                    = $environment.ToLower()
$resourceGroupName              = 'project-' + $environment
$clusterName                    = 'project-aks-' + $environment
$containerRegistryName          = 'projectregistry' + $environment

Write-Output "Attach AKS to ACR"
    # Get the service principal ID of your AKS cluster
    $AKS_SP_ID = $(az aks show --resource-group $resourceGroupName --name $clusterName --query "identity.principalId" -o tsv)
    # Get the resource ID of your ACR instance
    $ACR_RESOURCE_ID = $(az acr show --resource-group $resourceGroupName --name $containerRegistryName --query "id" -o tsv)
    # Create a role assignment for your AKS cluster to access the ACR instance
    az role assignment create --assignee $AKS_SP_ID --scope $ACR_RESOURCE_ID --role acrpull
    az role assignment create --assignee $AKS_SP_ID --scope $ACR_RESOURCE_ID --role contributor

    # Don't use command below until bug is resolved https://github.com/Azure/AKS/issues/1517
    # az aks update `
    #     --resource-group $resourceGroupName `
    #     --name $clusterName `
    #     --attach-acr $ACR_RESOURCE_ID
Write-Host "----------------------"
