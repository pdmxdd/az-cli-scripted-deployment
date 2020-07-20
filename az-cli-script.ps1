#!/snap/bin/pwsh

# --- start ---

# variables

$studentName = "paul"
$rgName = "$studentName-cli-deploy-rg"
$vmName = "$studentName-cli-deploy-vm"
$vmSize = "Standard_B2s"
$vmImage = "$(az vm image list --query "[? contains(urn, 'Ubuntu')] | [0].urn")"
$vmAdminUsername = "student"
$kvName = "$studentName-cli-deploy-kv"
$kvSecretName = "ConnectionStrings--Default"
$kvSecretValue = "server=localhost;port=3306;database=coding_events;user=coding_events;password=launchcode"

# set az location default

az configure --default location=eastus

# RG: provision

az group create -n "$rgName" | Set-Content resourceGroup.json

# set az rg default

az configure --default group=$rgName

# VM: provision

az vm create -n "$vmName" --size "$vmSize" --image "$vmImage" --admin-username "$vmAdminUsername" --admin-password "LaunchCode-@zure1" --authentication-type "password" --assign-identity | Set-Content virtualMachine.json

# set az vm default

az configure --default vm=$vmName

# KV: provision

az keyvault create -n "$kvName" --enable-soft-delete "false" --enabled-for-deployment "true" | Set-Content keyVault.json

# KV: set secret

az keyvault secret set --vault-name "$kvName" --description "connection string" --name "$kvSecretName" --value "$kvSecretValue"

# az keyvault secret set --vault-name "$kvName" --description "DB connection string" --file connectionString.json

# VM open NSGs

az vm open-port --port 443

# VM: grant access to KV

$vm = Get-Content virtualMachine.json | ConvertFrom-Json

az keyvault set-policy --name "$kvName" --object-id $vm.identity.systemAssignedIdentity --secret-permissions list get

# VM setup-and-deploy script

# az vm run-command invoke --command-id RunBashScript --scripts vm-setup-and-deploy.sh

# finished print out IP address

Write-Output "VM available at $($vm.publicIpAddress)"

# --- end ---

# access deployed app