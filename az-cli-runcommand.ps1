$vmName = "final-paul-cli-scripting-vm"

az vm run-command invoke --command-id RunShellScript -n "$vmName" --scripts @configure-vm.sh | Set-Content runCommand1.json

az vm run-command invoke --command-id RunShellScript -n "$vmName" --scripts @configure-ssl.sh | Set-Content runCommand2.json

az vm run-command invoke --command-id RunShellScript -n "$vmName" --scripts @deliver-deploy.sh | Set-Content runCommand3.json