$parameters = @{

  ResourceGroupName = 'RG'

  TemplateFile  = 'azure-deploy-path'

  TemplateParameterFile = 'azure-parameters-path'

  Verbose = $true

  }

New-AzResourceGroupDeployment @parameters