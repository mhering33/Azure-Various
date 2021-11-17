## Configuration 
$SCSDK = "C:\\Projects\Fiskars\Sitecore_Upgrade\Azure Toolkit\tools"
$SCARMTemplate = "C:\\Projects\Fiskars\Sitecore_Upgrade\Integration\ARMS\9.2\XPSingle_Extend\azuredeploy.json"
$DeploymentId = "NE-OneD"
$LicenceFile = "C:\\Projects\Fiskars\install\license.xml"
$CertificateFile = "C:\\Projects\Fiskars\Sitecore_Upgrade\Integration\ARMS\9.2\XPSingle_Extend\sitecore.azure.fiskars.int.pfx"
$SubscriptionId = "5c2c3249-06b5-4a04-8a4f-ca61fb3910db"
$Location = "North Europe"
$ParamFile = "C:\\Projects\Fiskars\Sitecore_Upgrade\Integration\ARMS\9.2\XPSingle_Extend\azuredeploy.parameters.json"
$Parameters = @{
    "authCertificateBlob" = [System.Convert]::ToBase64String([System.IO.File]::ReadAllBytes($CertificateFile))
    "templateLinkAccessToken" = "?st=2020-02-27T15%3A07%3A42Z&se=2027-12-31T15%3A07%3A00Z&sp=rwl&sv=2018-03-28&sr=c&sig=96uZ5%2Bwm%2BjSbG83KIo9lB3eYeEph0%2FERvPFG9wt0LJ4%3D"
    "templateLinkBase" = "https://scdeploymentstoragetau.blob.core.windows.net/sitecore92wdpscaled/Sitecore92/XPSingle_Extend/"
	"solrConnectionString"= "https://fiskars-solr-intt.northeurope.cloudapp.azure.com:8983/solr"
}

## Initialize
Import-Module $SCSDK\Sitecore.Cloud.Cmdlets.psm1

##Connect-AzureRmAccount
#Add-AzureRmAccount
Connect-AzureRmAccount
Select-AzureRmSubscription -Subscription $SubscriptionId


## ARM Template Installation
Start-SitecoreAzureDeployment -Name "rg-se-in-ne-testing-oned" -ArmTemplateUrl $SCARMTemplate -ArmParametersPath $ParamFile -LicenseXmlPath $LicenceFile -SetKeyValue $Parameters -Location $Location

##Set-ExecutionPolicy -ExecutionPolicy Unrestricted

#Install-Module AzureRM -AllowClobber