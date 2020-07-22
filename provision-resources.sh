#! /usr/bin/env bash

set -e

# --- start ---

# variables

# TODO: enter your name here in place of 'student'
student_name="paul"

# !! do not edit below !!

rg_name="${student_name}-cli-scripting-rg"

# -- vm
vm_name="${student_name}-cli-scripting-vm"

vm_admin_username=student
vm_admin_password='LaunchCode-@zure1'

vm_size=Standard_B2s
vm_image=$(az vm image list --query "[? contains(urn, 'Ubuntu')] | [0].urn" -o tsv)

# -- kv
kv_name="${student_name}-cli-scripting-kv"
kv_secret_name='ConnectionStrings--Default'
kv_secret_value='server=localhost;port=3306;database=coding_events;user=coding_events;password=launchcode'

# set az location default

az configure --default location=eastus

# RG: provision

az group create -n "$rg_name"

# set az rg default

az configure --default group=$rg_name

# VM: provision

# capture vm output for splitting
vm_data=$(az vm create -n $vm_name --size $vm_size --image $vm_image --admin-username $vm_admin_username --admin-password $vm_admin_password --authentication-type password --assign-identity --query "[ identity.systemAssignedIdentity, publicIpAddress ]" -o tsv)

# vm value is (2 lines):
# <identity line>
# <public IP line>

# get the 1st line (identity)
vm_id=$(echo "$vm_data" | head -n 1)

# get the 2nd line (ip)
vm_ip=$(echo "$vm_data" | tail -n +2)

# set az vm default

az configure --default vm=$vm_name

# KV: provision

az keyvault create -n $kv_name --enable-soft-delete false --enabled-for-deployment true

# KV: set secret

az keyvault secret set --vault-name $kv_name --description 'connection string' --name $kv_secret_name --value $kv_secret_value

# VM: add NSG rule for port 443 (https)

az vm open-port --port 443

# VM: grant access to KV

az keyvault set-policy --name $kv_name --object-id $vm_id --secret-permissions list get

# VM setup-and-deploy script

az vm run-command invoke --command-id RunShellScript --scripts @configure-vm.sh @configure-ssl.sh @deliver-deploy.sh

# finished print out IP address

echo "VM available at $vm_ip"

# --- end ---