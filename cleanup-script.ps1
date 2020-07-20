#!/snap/bin/pwsh

$rgName = (Get-Content resourceGroup.json | ConvertFrom-Json).name

Remove-Item resourceGroup.json,keyVault.json,virtualMachine.json

az group delete -n "$rgName" -y

Write-Output "AZ resource group deleted; removed resourceGroup.json, keyVault.json and virtualMachine.json from directory"
