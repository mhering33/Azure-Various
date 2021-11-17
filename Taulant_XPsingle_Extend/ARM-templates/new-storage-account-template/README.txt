When deploying new server to Azure using this template, following files needs to be edited:
 - azure-parameters.json: storageAccountType, storageAccountName
 - execute-new-storage-account.ps1: ResourceGroupName, TemplateFile (path to file), TemplateParameterFile (path to file)

In order to use execute-new-storage-account.ps1 script you need to manually authenticate in Powershell with your Azure credentials by using "Connect-AzAccount" command which will guide you through login proceess. 