Write-Host "Starting Sitecore Deployment. Please wait..."
 
 
Write-Host "Environment Variables.."
Get-ChildItem Env:
 
$storageAccount = Get-AzureRmStorageAccount -ResourceGroupName "Fiskars-DevOps" -Name "ecxsitecorearm"
 
 
$parametersFile = "$(System.DefaultWorkingDirectory)\sc-inf-pack\sc-inf-pack\azuredeploy.parameters.json"
$templateFile = "$(System.DefaultWorkingDirectory)\sc-inf-pack\sc-inf-pack\azuredeploy.json"
 
 
$licenseFile = "$($env:Agent_TempDirectory)\license.xml"
$certificateFile= "$($env:Agent_TempDirectory)\D9FD40E11567909E36197837DCAE3EE18B27467E.pfx"
 
#Sitecore Azure Toolkit requires a Base64 encoded blob.  
$authCertificateBlob = [System.Convert]::ToBase64String([System.IO.File]::ReadAllBytes($certificateFile));
 
# Identity Server
$siMsDeployPackageUrl="https://sitecorepackages1.blob.core.windows.net/sitecore/9.3.0/XPSingle/Sitecore.IdentityServer.4.0.0-r00257.scwdp.zip"
 
$parameters = @{
    "deploymentId"="matko-deploy-test-pipe";
    "siMsDeployPackageUrl" = "$siMsDeployPackageUrl";
    "templateLinkBase" = "https://ecxsitecorearm.blob.core.windows.net/arm/Sitecore930/XPSingle/";
    "templateLinkAccessToken" = "?st=2020-01-29T09%3A57%3A29Z&se=2020-03-30T09%3A57%3A00Z&sp=rwl&sv=2018-03-28&sr=c&sig=21soC%2Bz2%2BVY9HGnrPjy8ztsjMcSHVm5BXhucZZ03Rc8%3D";
    "sqlServerPassword" = "AswE!ff00";
    "sitecoreAdminPassword" = "blablaBla";
    "sqlServerLogin" = "sqladminecxio";
    "authCertificateBlob" = "$authCertificateBlob";
    "authCertificatePassword" = "Abc123!!!";
    "location" = "North Europe";   
}
 
 
$singleMsDeployPackageUrl="https://sitecorepackages1.blob.core.windows.net/sitecore/9.3.0/XPSingle/Sitecore 9.3.0 rev. 003498 (Cloud)_single.scwdp.zip"
$parameters.Add("singleMsDeployPackageUrl" , "$singleMsDeployPackageUrl")
$parameters.Add("allowInvalidClientCertificates" , "true")
 
 
$xcSingleMsDeployPackageUrl="https://sitecorepackages1.blob.core.windows.net/sitecore/9.3.0/XPSingle/Sitecore 9.3.0 rev. 003498 (Cloud)_xp0xconnect.scwdp.zip"
$parameters.Add("xcSingleMsDeployPackageUrl" , "$xcSingleMsDeployPackageUrl")
 
 
 
Write-Host "Deployment parameters output: "
Write-Host ($parameters | Out-String)
 
Import-Module "$(System.DefaultWorkingDirectory)\sc-inf-pack\sc-inf-pack\aztoolkit\tools\Sitecore.Cloud.Cmdlets.psm1" -Verbose
 
Start-SitecoreAzureDeployment `
   -Name "matko-deploy-test-pipe" `
    -Location "North Europe" `
    -ArmTemplateUrl $templateFile `
    -ArmParametersPath $parametersFile `
    -LicenseXmlPath $licenseFile `
    -SetKeyValue $parameters `
    -Verbose