# StackBoss service principal creation script
# stackboss.com
# Run this script, log in to your Azure tenant when prompted, and a StackBoss
#  service principal will be created on each tenant you have access to
Write-Host "StackBoss service principal creation script"
Write-Host "(the Import-Module Az & Connect-AzAccount cmdlets take a moment; sit tight)"
Write-Host ""

# run 'Install-Module Az' if the Az module isn't already installed on your system
Import-Module Az
Connect-AzAccount
if ((Get-AzContext).Subscription.Id -eq $null) {
	foreach ($subscription in Get-AzSubscription) {
		Set-AzContext -Subscription $subscription
	}
}

Write-Host "This next warning is normal."
# create a new service principal, stackBossServicePrincipal
$sp = New-AzADServicePrincipal -DisplayName stackBossServicePrincipal

Write-Host "A bunch of text is displayed as permissions are granted on each subscription."
Write-Host "The information you'll need to copy/paste is displayed at the end."

# grant permissions to this new service principal on each subscription
foreach ($subscription in Get-AzSubscription) {
	if ((Get-AzContext).Subscription.Id -ne $subscription.Id) { # the default subscription already has the right role
		New-AzRoleAssignment -ObjectId $sp.Id -RoleDefinitionName Contributor -Scope /subscriptions/$subscription
	}
}

# make the service principal secret printable; it isn't viewable again
$BSTR = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($sp.Secret)
$UnsecureSecret = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto($BSTR)

# print the info that needs to get copy/pasted into StackBoss
Write-Host "****************************************"
Write-Host "Take note of the following information for entry into StackBoss:"
Write-Host "****************************************"
Write-Host ""

Write-Host "Your tenant ID:"
(Get-AzContext).Tenant.Id
Write-Host ""

Write-Host "Your service principal's application ID:"
(Get-AzADServicePrincipal -DisplayName stackBossServicePrincipal).ApplicationId.ToString()
Write-Host ""

Write-Host "Your service principal's secret:"
$UnsecureSecret