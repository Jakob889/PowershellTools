
$HomePath = "\\Server008\home$"
$Foldertest = Test-Path $HomePath -PathType Any
$HomeUser = Get-ADGroupMember -identity "G_CH_SHARE_Home" -Recursive | Get-ADUser | Select SamAccountName
$SendMail = $false
$ScriptLog = $null

<#  -- generet PW string --
$username = "donot.reply@muster.com"
$password = 'Password'
$secureStringPwd = $password | ConvertTo-SecureString -AsPlainText -Force 
$creds = New-Object System.Management.Automation.PSCredential -ArgumentList $username, $secureStringPwd
$string = $secureStringPwd | ConvertFrom-SecureString 
Write-Host $string
#>

$MailUsername = "donot.reply@muster.com"
$MailPasswordString = "01000000d08c9ddf0115d1118c7a00c04fc297eb010000001229746a53e4bb4b9231c778fa3def400000000002000000000003660000c000000010000000c1dbafdbb6528fcffa9429c719e9410e0000000004800000a000000010000000ad44072778e3c2ccc42fb8a43e06dbcd38000000c10f1e3d23dff68348f64ab04fccf1979abd42ebbd1e59068e58f3d6c42a57a6419530e3a2dc9f82231a2073455ae97a9c21346f3eadcb4f140000009e905f21b1d3b871027c0a8bef438e34b0321143"
$MailSecPasswd = ConvertTo-SecureString $MailPasswordString;
$MailCredentials = New-Object System.Management.Automation.PSCredential ($MailUsername, $MailSecPasswd)

if ($Foldertest -eq $true)
{
    foreach($user in $HomeUser.SamAccountName) {
    write-host $user;
    $userpath = "$HomePath\$user\"
    $scanfolder = "$HomePath\$user\scan\"

    If (test-path $userpath )
    {
	    write-host $userpath "homefolder already exist";
    }
    else
    {
        write-host $user "homefolder creating";
        New-Item -ItemType Directory -Force -Path $userpath
        
        write-host "set modify permissions";
        $Ar = New-Object  system.security.accesscontrol.filesystemaccessrule("$user","Modify","ContainerInherit, ObjectInherit", "None", "Allow")
        $Acl = Get-Acl $userpath
        $Acl.SetAccessRule($Ar)
        Set-Acl $userpath $Acl

        New-Item -ItemType Directory -Force -Path $scanfolder

        $Subject = "Homedrive created"
        $ScriptLog += "Homedrive for $user created <br />"
        $SendMail = $true
        #Send-MailMessage -SmtpServer 'outlook.muster.ch' -From 'monitoring@muster.ch' -To 'it@muster.ch' -Subject "Homedrive for $user created" -Body "The Homedrive on $HomePath for $user is created and permissions are set"     }

    }
    }
}
else
{
    $Subject = "Homedrive creation ERRROR!"
    $ScriptLog += "ERROR could not connect $HomePath"
    $SendMail = $true
}

If ($SendMail -eq $true)
{
    Write-Host "Send Mail"
    Send-MailMessage -From 'do-not-reply@muster.com' -To 'it@muster.com' -Subject "$Subject" -BodyAsHtml -Body "$ScriptLog" -Credential $MailCredentials -UseSsl -smtpserver smtp.office365.com -port 587  
}

$SendMail = $false