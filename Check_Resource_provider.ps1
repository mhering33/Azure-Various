$Credential = Get-Credential
Connect-AzAccount -Credential $Credential
#connect to azure for first time

$playground_devops_sub = "ca5cc17f-181d-461f-b29e-5770448adefd"
Select-AzureSubscription -SubscriptionId $playground_devops_sub 
Write-Host "Selected subscriptiom is $playgroung_devops_sub"


#Get-AzSubscription
#Get-AzContext
#Get-AzStorageAccount -ResourceGroupName "Fiskars-DevOps" -Name "ecxsitecorearm"
#get resource providers on selected subscriptions
#Get-AzResourceProvider -ProviderNamespace "Microsoft.RecoveryServices"

#Set the context to the appropriate subscription.
#Select-AzSubscription -SubscriptionId $playground_devops_sub | Set-AzContext

#get resource providers on selected subscriptions
#Get-AzResourceProvider -ProviderNamespace "Microsoft.RecoveryServices" | Format-Table


#$var_check_azresource_Provider = Get-AzResourceProvider -ProviderNamespace Microsoft.RecoveryServices

#Get-AzResourceProvider -ProviderNamespace Microsoft.RecoveryServices | where {$_.RegistrationState -eq "NotRegistered"} | Select ProviderNamespace, RegistrationState

#Get-AzResourceProvider -ProviderNamespace Microsoft.RecoveryServices | where {$_.RegistrationState -eq "Registered"} | Select ProviderNamespace, RegistrationState


#Write-Output ($var_check_azresource_Provider | Format-Table | Where $RegistrationState -eq "Registered")

#Write-Host $var_check_azresource_Provider

#if (-not::IsNullOrEmpty($var_check_azresource_Provider) ){
#    Write-Host "Nije registrirani resource provider."
#    }
#    else {
#        Write-Host "Resource provider postoji!"
#        }

#$var_check_azresource_Provider = Get-AzResourceProvider -ProviderNamespace Microsoft.RecoveryServices | where {$_.RegistrationState -eq "Registered"} | Select ProviderNamespace, RegistrationState

#Check if Recovery Service provider allready registered in Azure or register if not present
if (Get-AzResourceProvider -ProviderNamespace Microsoft.RecoveryServices | Where-Object {$_.RegistrationState -eq "Registered"} | Select-Object ProviderNamespace, RegistrationState) {
    Write-Host "Resource provider is registered. Skipping!"
}
    elseif (Get-AzResourceProvider -ProviderNamespace Microsoft.RecoveryServices | Where-Object {$_.RegistrationState -eq "Unregistered"} | Select-Object ProviderNamespace, RegistrationState) {
        Write-Host "Resource provider is not registered. Registering!"
            Try
            {
            Register-AzResourceProvider -ProviderNamespace Microsoft.RecoveryServices -ErrorAction Stop
            }
            Catch
            {
            $ErrorMessage = $_.Exception.Message
            #$FailedItem = $_.Exception.ItemName
            Write-Host "Resource provider failed to register with error $ErrorMessage"
            #Write-Host "It failed with $FailedItem"
            }
    }
    else {
        Write-Host ("Resource provider status is N/A.")
    }



#Create a Recovery Services Vault
$myRSvault = "Fiskars-Recovery-Services-Vault"
$myResourceGroup = "matko-deploy-test-pipe"
$myLocation= "northeurope"
$RS_vault = Get-AzRecoveryServicesVault
#$rs_vault2 = Get-AzRecoveryServicesVault -Name $myRSvault #radi isto kao RS_vault
if ($null -eq $RS_vault) {
    Write-Host "Recovery Services Vault does not exist. Creating!"
        Try
        {
        #create a recovery services vault
        New-AzRecoveryServicesVault -Name $myRSvault -ResourceGroupName $myResourceGroup -Location $myLocation | Set-AzRecoveryServicesVaultContext;
        Write-Host "Recovery Services Vault created with name $myRSvault ."
        }
        Catch
        {
        $ErrorMessage = $_.Exception.Message
        Write-Host "Recovery services Vault failed to create with $ErrorMessage"
        }
}
else {
    Write-Host ("Recovery Services Vault exists with following parameters:")
    Write-Host $RS_vault
    Get-AzRecoveryServicesVault | Set-AzRecoveryServicesVaultContext;
}

#get vault id and display it
$targetVaultID = Get-AzRecoveryServicesVault -ResourceGroupName $myResourceGroup -Name $myRSvault | Select-Object -ExpandProperty ID
Write-Host "Vault ID is $targetVaultID"

#set storage replication configuration (GeoRedundant/LocallyRedundant)
Write-Host "Setting storage rep conf"
Set-AzRecoveryServicesBackupProperty -Vault $RS_vault -BackupStorageRedundancy LocallyRedundant
$rep_conf = Get-AzRecoveryServicesBackupProperty -Vault $RS_vault
if ($null -eq $rep_conf){
    Write-Host "Storage replication conf not set - setting..."
        Try
        {
        Set-AzRecoveryServicesBackupProperty -Vault $RS_vault -BackupStorageRedundancy LocallyRedundant
        Write-Host "Setting storage rep conf to"
        }
        Catch{
        $ErrorMessage = $_.Exception.Message
        Write-Host "Storage replication conf failed to set with $ErrorMessage"
        }
}
else {
    Write-Host ("Storage replication conf exists with following parameters:")
    Write-Host $rep_conf
}


#--------------------------------------Backup policy creation------------------------------------------------------------

#get existing default policy
$policy = Get-AzRecoveryServicesBackupProtectionPolicy #-Name "DefaultPolicy"
$policy_default = Get-AzRecoveryServicesBackupProtectionPolicy -Name "DefaultPolicy"
$policy_name_vm = "NewPolicyVM"
#$policy_name_sql = "NewPolicySQL"
#$workload_name_vm = "AzureVM"
#Write-Host $policy

if ($null -eq $policy) {
    Write-Host "Default policy does not exist - creating..."
       Try
        {
        $policy_default
        }
        Catch{
        $ErrorMessage = $_.Exception.Message
        Write-Host "Default policy creation failed with $ErrorMessage"
        }
}
elseif (Get-AzRecoveryServicesBackupProtectionPolicy | Where-Object {$_.Name -eq "DefaultPolicy"}) {
   Write-Host "DefaultPolicy exists, skipping..."
   Write-Host "Creating policy $policy_name_vm"
    Try
    {
        if ($policy_name_vm -eq (Get-AzRecoveryServicesBackupProtectionPolicy | Where-Object {$_.Name -eq $policy_name_vm})) {
            Write-Host "Policy with name $policy_name_vm allready exists. Skipping..."
        else {

        }
        }
    #get retention policy
    $RetPol = Get-AzRecoveryServicesBackupRetentionPolicyObject -WorkloadType AzureVM
    $RetPol.DailySchedule.DurationCountInDays = 365
    #get schedule policy
    $SchPol = Get-AzRecoveryServicesBackupSchedulePolicyObject -WorkloadType AzureVM
    #create new policy
    New-AzRecoveryServicesBackupProtectionPolicy -Name $policy_name_vm -WorkloadType AzureVM -RetentionPolicy $RetPol -SchedulePolicy $SchPol
    Write-Host "Created policy with name $policy_name_vm"
    }
    Catch{
    $ErrorMessage = $_.Exception.Message
    Write-Host "Failed to create policy $policy_name_vm with $ErrorMessage"
    }
}

#-------------------Start backup job-----------------------------------------
#specify container
$backupcontainer = Get-AzRecoveryServicesBackupContainer `
    -ContainerType "AzureVM" `
    -FriendlyName "VM1-test"
#obtain VM information
$item = Get-AzRecoveryServicesBackupItem `
    -Container $backupcontainer `
    -WorkloadType "AzureVM"
#run backup
Backup-AzRecoveryServicesBackupItem -Item $item

#check progress of backup
Get-AzRecoveryServicesBackupJob | Where-Object {$_.Status -eq "InProgress"}


$backups = Get-AzRecoveryServicesBackupJob #| where {$_.Status -eq "InProgress"}
if ($backups | Where-Object {$_.Status -eq "InProgress"}){
    Write-Progress -Activity "Processing backup, please wait"
}
elseif ($backups | Where-Object {$_.Status -eq "Failed"}){
    Write-Progress -Activity "Backup failed"
}
elseif ($backups | Where-Object {$_.Status -eq "Completed"}){
    Write-Progress -Activity "Backup failed"
}
else {
    Write-Host ("Backup block done")
}






#enable vm backup
#Enable-AzRecoveryServicesBackupProtection -ResourceGroupName $myResourceGroup -Name VM1-test -Policy $policy
#run backup job
#$backupcontainer = Get-AzRecoveryServicesBackupContainer -ContainerType "AzureVM" -FriendlyName "VM1-test-backup"
#$item = Get-AzRecoveryServicesBackupItem -Container $backupcontainer -WorkloadType "AzureVM"
#Backup-AzRecoveryServicesBackupItem -Item $item
#monitor the backup job
#Get-AzRecoveryservicesBackupJob

#$job = Start-Job { invoke command here }
#Wait-Job $job
#Receive-Job $job

#get vault id
#$MyvaultID = Get-AzRecoveryServicesVault -ResourceGroupName $myResourceGroup -Name $myRSvault | select -ExpandProperty ID
#Write-Host "Vault ID is $MyvaultID"

#get vault id
#$targetVaultID = Get-AzRecoveryServicesVault -ResourceGroupName $myResourceGroup -Name $myRSvault | select -ExpandProperty ID
#Write-Host "Vault ID is $targetVaultID"



#display current protection policy
#Write-Host "Displaying current protection policy"
#$schPol = Get-AzRecoveryServicesBackupProtectionPolicy -WorkloadType "AzureVM" -VaultId $targetVaultID
#Write-Host $schPol | select -ExpandProperty BackupTime

#create protection policy
#Write-Host "Creating custom protection policy"
#$UtcTime = Get-Date -Date "2019-03-20 01:00:00Z"
#Write-Host "UtcTime $UtcTime"
#$UtcTime2 = $UtcTime.ToUniversalTime()
#Write-Host "UtcTime2 $UtcTime2"
#$myArray = @("2020-03-20 01:00:00Z","2020-03-21 01:00:00Z") # directly referencing array
#$schPol.ScheduleRunTimes = $myArray

#$myArray = @(64,"Hello",3.5,"World")

#$schPol.ScheduleRunTimes[0] = $UtcTime2

#Get time object
#(Get-AzRecoveryServicesBackupProtectionPolicy -WorkloadType "AzureVM" -VaultId $targetVaultID) | Format-Table @{Label="BackupTime"; Expression={(Get-Date) - $_.BackupTime}}

#create a backup protection policy
#$SchPol = Get-AzRecoveryServicesBackupSchedulePolicyObject -WorkloadType "AzureVM" 
#$SchPol.ScheduleRunTimes.Clear()
#$Dt = Get-Date
#$SchPol.ScheduleRunTimes.Add($Dt.ToUniversalTime())
#$RetPol = Get-AzRecoveryServicesBackupRetentionPolicyObject -WorkloadType "AzureVM" 
#$RetPol.DailySchedule.DurationCountInDays = 365
#New-AzRecoveryServicesBackupProtectionPolicy -Name "NewPolicy" -WorkloadType AzureVM -RetentionPolicy $RetPol -SchedulePolicy $SchPol

#Policy variables example use
#$retPol = Get-AzRecoveryServicesBackupRetentionPolicyObject -WorkloadType "AzureVM" -VaultId $targetVault.ID
#New-AzRecoveryServicesBackupProtectionPolicy -Name "NewPolicy" -WorkloadType "AzureVM" -RetentionPolicy $retPol -SchedulePolicy $schPol -VaultId $targetVault.ID

#Set AZ vault context
#Get-AzRecoveryServicesVault -Name $myRSvault -ResourceGroupName $myResourceGroup | Set-AzRecoveryServicesVaultContext
#deprecated

#Create VM backup

#$namedContainer = Get-AzRecoveryServicesBackupContainer -ContainerType AzureVM -Status Registered -FriendlyName "V2VM"
#$item = Get-AzRecoveryServicesBackupItem -Container $namedContainer -WorkloadType AzureVM
#$job = Backup-AzRecoveryServicesBackupItem -Item $item