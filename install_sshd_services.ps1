#Download and install OpenSSH.Client and OpenSSH.Server
Add-WindowsCapability -Online -Name OpenSSH.Server~~~~0.0.1.0
Add-WindowsCapability -Online -Name OpenSSH.Client~~~~0.0.1.0

#Installing the required module for SSH connection
Install-Module -Force OpenSSHUtils -Scope AllUsers

#Configure autorun for the client and the server
Set-Service -Name ssh-agent -StartupType 'Automatic'
Set-Service -Name sshd -StartupType 'Automatic'

#Starting services
Start-Service ssh-agent
Start-Service sshd

Restart-Service sshd
[string]$PathToSshConfig = "C:\ProgramData\ssh\sshd_config"
(Get-Content $PathToSshConfig) -replace "Match Group","# Match Group" | Out-File $PathToSshConfig -Encoding "UTF8"
(Get-Content $PathToSshConfig) -replace "AuthorizedKeysFile __PROGRAMDATA","# AuthorizedKeysFile __PROGRAMDATA" | Out-File $PathToSshConfig -Encoding "UTF8"
 
Restart-Service sshd