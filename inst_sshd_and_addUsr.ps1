#Installs and configures OpenSHH
#Adds the required public key
#Adds a home directory for the user
#Restart sshd service

[string]$UserName = $(Read-Host "Enter the user name")
$UserExist = Get-LocalUser | Where-Object {$_.Name -eq "$UserName"}

#Create a new user if it does not exist in the system
If ( -not $UserExist)
 {
    Write-Host "Create new user"
    $Password = $(Read-Host "Enter password for $UserName" -AsSecureString)
    New-LocalUser "$UserName" -Password $Password -FullName "$UserName" -Description "SFTP user"
    Add-LocalGroupMember -Group "Administrators" -Member "$UserName"
    Mkdir C:\sftp\$Username
 }

$ServiceName = 'sshd'
$arrService = Get-Service -Name $ServiceName

if ($arrService.Status -ne 'Running')
{
    #Download and install OpenSSH.Client and OpenSSH.Server
    Add-WindowsCapability -Online -Name OpenSSH.Server~~~~0.0.1.0
    Add-WindowsCapability -Online -Name OpenSSH.Client~~~~0.0.1.0

    #Installing the required module for SSH connection
    Install-Module -Force OpenSSHUtils -Scope AllUsers

    #Configure autorun for the client and the server
    Set-Service -Name ssh-agent -StartupType ‘Automatic’
    Set-Service -Name sshd -StartupType ‘Automatic’

    #Starting services
    Start-Service ssh-agent
    Start-Service sshd
}

Restart-Service sshd 

[string]$PathToSshConfig = "C:\ProgramData\ssh\sshd_config"
(Get-Content $PathToSshConfig) -replace "Match Group","# Match Group" | Out-File $PathToSshConfig -Encoding "UTF8"
(Get-Content $PathToSshConfig) -replace "AuthorizedKeysFile __PROGRAMDATA","# AuthorizedKeysFile __PROGRAMDATA" | Out-File $PathToSshConfig -Encoding "UTF8"

#Add a home directory for the user. Add lines to the end of the sshd_conf file
"Match User $UserName`
ChrootDirectory C:\sftp\$Username`
#Disable tunneling, authentication agent, TCP and X11 forwarding.`
PermitTunnel no`
AllowTcpForwarding no`
X11Forwarding no`n"` | Out-File C:\ProgramData\ssh\sshd_config -Encoding "ASCII" -Append

Restart-Service sshd