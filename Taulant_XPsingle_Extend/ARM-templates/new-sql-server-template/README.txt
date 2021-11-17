When deploying new server to Azure using this template, following files needs to be edited:
    - azure-parameters.json: serverName, serverLocation, sqlServerLogin, sqlServerPassword (at least 8 chars and 3 character groups), sitecoreSKU (explanation in azure-deploy.json)
    - execute-new-server.ps1: ResourceGroupName, TemplateFile (path to file), TemplateParameterFile (path fo file)

In order to use execute-new-server.ps1 script you need to manually authenticate in Powershell with your Azure credentials by using "Connect-AzAccount" command which will guide you through login proceess. 