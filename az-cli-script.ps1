#!/snap/bin/pwsh

# configuration: set default location
# az configure --default location=eastus

# to file
# create resource group and save output to JSON file
# az group create -n paul-cli-scripting-rg2 | Set-Content resourceGroup.json

# to var
# $rg = az group create -n paul-cli-scripting-rg | ConvertTo-Json

# az configure --default group=$rg.name

# $ImageURN="$(az vm image list --query "[? contains(urn, 'Ubuntu')] | [0].urn")"

# to file
# az vm create -n paul-linux-vm --size "Standard_B2s" --image "$ImageURN" --admin-username "student" --assign-identity | Set-Content virtual_machine.json

# to var
# $vm = az vm create -n paul-linux-vm --size "Standard_B2s" --image "$ImageURN" --admin-username "student" --assign-identity | ConvertTo-Json

# az vm run-command invoke -n $vm.name --command-id RunBashScript setup-and-deploy.sh




# --- start ---

# variables

$rgName = "paul-cli-scripting-rg"
$vmName = "paul-cli-scripting-vm"
$vmSize = "Standard_B2s"
$vmImage = "$(az vm image list --query "[? contains(urn, 'Ubuntu')] | [0].urn")"
$vmAdminUsername = "student"
$kvName = "paul-cli-scripting-kv"
$kvSecretName = "ConnectionStrings--Default"
$kvSecretValue = "server=localhost;port=3306;database=coding_events;user=coding_events;password=launchcode"

# set az location default

az configure --default location=eastus

# RG: provision

az group create -n "$rgName" | Set-Content resourceGroup.json

# set az rg default

az configure --default group=$rgName

# VM: provision

az vm create -n "$vmName" --size "$vmSize" --image "$vmImage" --admin-username "$vmAdminUsername" --assign-identity | Set-Content virtualMachine.json

# set az vm default

az configure --default vm=$vmName

# KV: provision

az keyvault create -n "$kvName" --enable-soft-delete "false" --enabled-for-deployment "true" | Set-Content keyVault.json

# set az kv default

az configure --default kv=$kvName

# KV: set secret

az keyvault secret set --vault-name "$kvName" --description "connection string" --name "$kvSecretName" --value "$kvSecretValue"

# az keyvault secret set --vault-name "$kvName" --description "DB connection string" --file connectionString.json

# VM open NSGs

az vm open-port --port 80

# VM: grant access to KV

$vm = Get-Content virtualMachine.json | ConvertFrom-Json

az keyvault set-policy --name "$kvName" --object-id $vm.identity.systemAssignedIdentity --secret-permissions list get

# VM setup-and-deploy script

# az vm run-command invoke --command-id RunBashScript --scripts vm-setup-and-deploy.sh

# finished print out IP address

Write-Output "VM available at $($vm.publicIpAddress)"

# --- end ---

# access deployed app