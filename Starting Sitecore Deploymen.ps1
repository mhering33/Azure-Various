Write-Host "Starting Sitecore Deployment. Please wait..."
#Import-Module AzureRm
Select-AzureRmSubscription -SubscriptionId playground_DevOps #| Set-AzContext
#Select subscription

Write-Host "Environment Variables.."
Get-ChildItem Env:

$storageAccount = Get-AzureRmStorageAccount  -ResourceGroupName $(azure_rg_name) -Name $(storage_acc_name)

$parametersFile = "$(System.DefaultWorkingDirectory)\sc-inf-pack2\azuredeploy.parameters.json"
$templateFile = "$(System.DefaultWorkingDirectory)\sc-inf-pack2\azuredeploy.json"


$licenseFile = "$($env:Agent_TempDirectory)\license.xml"
$certificateFile= $(Matko-test-2)

#Sitecore Azure Toolkit requires a Base64 encoded blob.   
#$authCertificateBlob = [System.Convert]::ToBase64String([System.IO.File]::ReadAllBytes($certificateFile)); 
##$authCertificateBlob = $(Matko-test-2)

$cert = Get-AzureKeyVaultSecret -VaultName 'matko-hering-key-vault' -Name 'Matko-test-2'

$certBytes = [System.Convert]::FromBase64String($cert.SecretValueText)
$certCollection = New-Object System.Security.Cryptography.X509Certificates.X509Certificate2Collection
$certCollection.Import($certBytes,$null,[System.Security.Cryptography.X509Certificates.X509KeyStorageFlags]::Exportable)

$protectedCertificateBytes = $certCollection.Export([System.Security.Cryptography.X509Certificates.X509ContentType]::Pkcs12, $password)
$pfxPath = "D:\a\1\temp\Matko-test-2-export.pfx"
[System.IO.File]::WriteAllBytes($pfxPath, $protectedCertificateBytes)

$password = (Get-AzureKeyVaultSecret -VaultName 'My-Vault' -Name 'My-PW').SecretValueText
$secure = ConvertTo-SecureString -String $password -AsPlainText -Force

Import-PfxCertificate -FilePath "D:\a\1\temp\ThomasRayner-export.pfx" Cert:\CurrentUser\My -Password $secure

# Identity Server
$siMsDeployPackageUrl=$(siMsDeployPackageUrl_var)

$parameters = @{
    "deploymentId"="$(deploymentID_var)";
    "siMsDeployPackageUrl" = "$(siMsDeployPackageUrl)";
    "templateLinkBase" = "$(templateLinkBase_var)";
    "templateLinkAccessToken" = "$(templateLinkAccessToken_var)";
    "sqlServerPassword" = "$(sqlServerPassword_var)";
    "sitecoreAdminPassword" = "$(sitecoreAdminPassword_var)";
    "sqlServerLogin" = "$(sqlServerLogin_var)";
    "authCertificateBlob" = "$authCertificateBlob";
    "authCertificatePassword" = "$(authCertificatePassword_var)";
    "location" = "$(location_var)";    
}


$singleMsDeployPackageUrl="$(siMsDeployPackageUrl_var)"
$parameters.Add("singleMsDeployPackageUrl" , "$singleMsDeployPackageUrl")
$parameters.Add("allowInvalidClientCertificates" , "true")


$xcSingleMsDeployPackageUrl="$(xcSingleMsDeployPackageUrl_var)"
$parameters.Add("xcSingleMsDeployPackageUrl" , "$xcSingleMsDeployPackageUrl")



Write-Host "Deployment parameters output: "
Write-Host ($parameters | Out-String)

Import-Module "$(System.DefaultWorkingDirectory)\sc-inf-pack\sc-inf-pack\aztoolkit\tools\Sitecore.Cloud.Cmdlets.psm1" -Verbose

Start-SitecoreAzureDeployment `
   -Name "$(deploymentID_var)" `
    -Location "$(location_var)" `
    -ArmTemplateUrl $templateFile `
    -ArmParametersPath $parametersFile `
    -LicenseXmlPath $licenseFile `
    -SetKeyValue $parameters `
    -Verbose