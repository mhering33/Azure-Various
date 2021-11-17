
#configure an existing App Service Plan - one liner
#Set-AzAppServicePlan -ResourceGroupName "oned-qa-ne-rg" -Name "ne-oned-cd-hp-v01-qa" -Tier "Standard" -WorkerSize "Medium" -NumberofWorkers 9

#Scale an existing App Service Plan - Scale OUT
#Set-AzureRmAppServicePlan -Name "ne-oned-cd-hp-v01-qa" -ResourceGroupName "oned-qa-ne-rg" -NumberofWorkers 9

#Changing the worker size of an App Service Plan

#Set-AzureRmAppServicePlan -Name "ne-oned-cd-hp-v01-qa" -ResourceGroupName "oned-qa-ne-rg" -WorkerSize Medium

#Changing the Tier of an App Service Plan - Deprecated!!!
#Set-AzureRmAppServicePlan -Name "ne-oned-cd-hp-v01-qa" -ResourceGroupName "oned-qa-ne-rg" -Tier Standard

#Delete existing App service plans
#Remove-AzureRmAppServicePlan -Name "ne-oned-cd-hp-v01-qa" -ResourceGroupName "oned-qa-ne-rg"

#check if app service plan exists?
$rgname = "oned-qa-ne-rg"
$app_service_plan_name = "ne-oned-cd-hp-v01-qa"
$worker_no = 6
$app_service_plan = Get-AzAppServicePlan -name $app_service_plan_name #gets app service plan
if ($app_service_plan | Where-Object {$_.Status -eq 'Ready'}) {
    Write-Progress -Activity 'Plan exists, scaling OUT app service plan...'
    Set-AzAppServicePlan -Name $app_service_plan_name -ResourceGroupName $rgname -NumberofWorkers $worker_no
}