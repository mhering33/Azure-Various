$thumbprint = (New-SelfSignedCertificate `
    -Subject "CN=$env:COMPUTERNAME @ Sitecore, Inc." `
    -Type SSLServerAuthentication `
    -FriendlyName "$env:USERNAME Certificate").Thumbprint


$certificateFilePath = "C:\Temp\sitecore.azure.fiskars.int.pfx"
Export-PfxCertificate `
    -cert cert:\LocalMachine\MY\$thumbprint `
    -FilePath "$certificateFilePath" `
    -Password (Read-Host -Prompt "fiskars@2020" -AsSecureString)