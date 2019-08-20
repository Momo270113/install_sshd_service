# Check user exist
[string]$UserName = $(Read-Host "Enter the user name")
$UserExist = Get-LocalUser | Where-Object {$_.Name -eq "$UserName"}
$UserExist = "$UserExist"

#Create a new user if it does not exist in the system
If ( -not $UserExist)
 {
    Write-Host "Create new user...`n`
    Password requirements:`
    - capital letters of European languages (A – Z, using signs, Greek and Cyrillic characters)`
    - lowercase characters of European languages (a through z, sharp-s, with marks, Greek and Cyrillic characters)`
    - basic 10 digits (0 to 9)`
    - characters (special characters): (~! @# $%^&*_-+='|\(){}\ []:;" " <>, .? /)`
    - Currency symbols such as the Euro or British pound are not considered as special symbols for this policy setting.`n" -ForegroundColor Yellow

    $Password = $(Read-Host "Enter password for $UserName" -AsSecureString)
    New-LocalUser "$UserName" -Password $Password -FullName "$UserName" -Description "SFTP user"
    Add-LocalGroupMember -Group "Administrators" -Member "$UserName"
    Mkdir C:\sftp\$Username
    [string]$PathToSshConfig = "C:\ProgramData\ssh\sshd_config"

    #Add a home directory for the user. Add lines to the end of the sshd_conf file
    "Match User $UserName`
    ChrootDirectory C:\sftp\$Username`
    PermitTunnel no`
    AllowTcpForwarding no`
    X11Forwarding no`n"` | Out-File $PathToSshConfig -Encoding "ASCII" -Append

} else {
    Mkdir C:\sftp\$Username
    [string]$PathToSshConfig = "C:\ProgramData\ssh\sshd_config"
    
    #Add a home directory for the user. Add lines to the end of the sshd_conf file
    "Match User $UserName`
    ChrootDirectory C:\sftp\$Username`
    #Disable tunneling, authentication agent, TCP and X11 forwarding.`
    PermitTunnel no`
    AllowTcpForwarding no`
    X11Forwarding no`n"` | Out-File $PathToSshConfig -Encoding "ASCII" -Append
}
Restart-Service sshd

