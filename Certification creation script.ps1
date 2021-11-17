# Certification creation script 
    
    # pfx certification stored path
    $certroopath = "C:\certLocation"
    
    #location of the resource group
    $location = "westus"
    
    # Azure virtual machine name that we are going to create
    $vmName = "testvm000000906"
    
    # Certification name - should match with FQDN of Windows Azure creating VM 
    $certname = "$vmName.$location.cloudapp.azure.com"
    
    # Certification password - should be match with password of Windows Azure creating VM 
    $certpassword = "SecretPassword@123"
    
    $cert=New-SelfSignedCertificate -DnsName "$certname" -CertStoreLocation cert:\LocalMachine\My
    $pwd = ConvertTo-SecureString -String $certpassword -Force -AsPlainText
    $certwithThumb="cert:\localMachine\my\"+$cert.Thumbprint
    $filepath="$certroopath\$certname.pfx"
    Export-PfxCertificate -cert $certwithThumb -FilePath $filepath -Password $pwd
    Remove-Item -Path $certwithThumb 

    #Create sitecore certificate
    $thumbprint = (New-SelfSignedCertificate `
    -Subject "CN=$env:COMPUTERNAME @ Sitecore, Inc." `
    -Type SSLServerAuthentication `
    -FriendlyName "$env:USERNAME Certificate").Thumbprint
    #certificate file path
    $SystemDefaultWorkingDirectory = "C:\test"
    $certificateFilePath = "$SystemDefaultWorkingDirectory\$thumbprint.pfx"
    Write-Host $SystemDefaultWorkingDirectory

    #export certificate
    Export-PfxCertificate `
    -cert cert:\LocalMachine\MY\$thumbprint `
    -FilePath "$certificateFilePath" `
    -Password (Read-Host -Prompt "Enter password that would protect the certificate" -AsSecureString)


    Invoke-WebRequest -Uri "https://sitecorepackages1.blob.core.windows.net/sitecore/AzureToolkit/Sitecore Azure Toolkit 2.1.0 rev. 18023.zip" -OutFile "$(System.DefaultWorkingDirectory)\Sitecore Azure Toolkit 2.1.0 rev. 181023.zip"