param(
  [Parameter(Mandatory)]
  [ValidateNotNullOrEmpty()]
  [string]$ResourceGroupName,

  [Parameter(Mandatory)]
  [ValidateNotNullOrEmpty()]
  [string]$TemplateFile,

  [Parameter(Mandatory)]
  [ValidateNotNullOrEmpty()]
  [string]$ParametersFile,

  [Parameter(Mandatory)]
  [ValidateNotNullOrEmpty()]
  [string]$KeyVaultName,

  [Parameter(Mandatory)]
  [ValidateNotNullOrEmpty()]
  [string]$Environment,

  [Parameter(Mandatory)]
  [ValidateNotNullOrEmpty()]
  [string]$SubscriptionId
)
  Describe "Project Deployment Tests" -Tag BeforeDeployment {
    # Init
    BeforeAll {
    }
    # Teardown
    AfterAll {
    }

    # Tests whether the cmdlet returns value or not.
    Context "Check resource group contains only defined resources" {
        $result = az deployment group validate `
                                                --subscription $SubscriptionId `
                                                --resource-group $ResourceGroupName `
                                                --template-file $TemplateFile `
                                                --parameters $ParametersFile `
                                                --parameters "keyVaultName=$KeyVaultName" | ConvertFrom-Json
        
        It "Should be deployed successfully" {
            $result.properties.provisioningState | Should Be "Succeeded"
        }

        It "Shouldn't contain errors" {
            $result.error | Should BeNullOrEmpty
        }

        It "Deployment should contain only expected IDs" {
            # expected array must be sorted
            if ($environment -eq 'dev') {
                $expectedToDeploy = @(
                    ("#List of Azure Resource IDs")
                )
            }
            if ($environment -eq 'qa') {
                $expectedToDeploy = @(
                    ("#List of Azure Resource IDs")
                )
            }
            if ($environment -eq 'prod') {
                $expectedToDeploy = @(
                    ("#List of Azure Resource IDs")
                )
            }
            $resourcesSorted = $result.properties.validatedResources.id | sort
            
            # Workaround to get more sense out of error message when arrays do not match
            $expectedJoined = $expectedToDeploy -join ', '
            $resourceJoined = $resourcesSorted -join ', '

            $resourceJoined | Should Be $expectedJoined
        }
    }
  }

  Describe "Project Deployment Tests" -Tag AfterDeployment{
    # Init
    BeforeAll {
    }
    # Teardown
    AfterAll {
    }

    # Tests whether the cmdlet returns value or not.
    Context "Check resource group contains only defined resources" {
        $resources = az resource list --subscription $SubscriptionId --resource-group $ResourceGroupName | ConvertFrom-Json

        It "Resource group should contain only expected IDs" {
            # expected array must be sorted
            if ($environment -eq 'dev') {
                $expectedResources = @(
                    ("#List of Azure Resource IDs")
                )
            }
            if ($environment -eq 'qa') {
                $expectedResources = @(
                    ("#List of Azure Resource IDs")
                )
            }
            if ($environment -eq 'prod') {
                $expectedResources = @(
                    ("#List of Azure Resource IDs")
                )
            }
            $resourcesSorted = $resources.id | sort
            
            # Workaround to get more sense out of error message when arrays do not match
            $expectedJoined = $expectedResources -join ', '
            $resourceJoined = $resourcesSorted -join ', '

            $resourceJoined | Should Be $expectedJoined
        }
    }
}
