Import-Module ActiveDirectory

$ScriptLog = $null
$SendMail = $false

$invocation = (Get-Variable MyInvocation).Value 
$scriptPath = Split-Path $invocation.MyCommand.Path 

$ConfigurationFile = $scriptPath +"\config.txt"
$Configuration = Get-Content $ConfigurationFile

<#  ------ config file example  --------
------------Groups need the same name as sharedmailboxes---
ActiveDirectoryGroup1
ActiveDirectoryGroup2
ActiveDirectoryGroup3
#>

<# --- to create secure PW file ----
$username = "bad.admin@acme.com.au"
$password = 'Password123!@#'
$secureStringPwd = $password | ConvertTo-SecureString -AsPlainText -Force 
$creds = New-Object System.Management.Automation.PSCredential -ArgumentList $username, $secureStringPwd
$string = $secureStringPwd | ConvertFrom-SecureString 
Write-Host $string
#>

#MailCredentials
$MailUsername = "donot.reply@muster.com"
$MailPasswordString = "01000000d08c9ddf0115d1118c7a00c04fc297eb0100000069bea857538892438c39e225cece44880000000002000000000003660000c000000010000000c0a9c4d27f0e95d6431949c804e20ac00000000004800000a000000010000000960e61db5f3d501d443c93fcf620dd8138000000f512f6c5f4dee7752de2de688c41432a8ef2100d68df5e3ff2be17d0cb0d5307d3fa9d87fecb903513a5436738f816c329c355a58a9d39611400000026f764d73f06ddf34eeb5f00a867d2e8994c7064"
$MailSecPasswd = ConvertTo-SecureString $MailPasswordString;
$MailCredentials = New-Object System.Management.Automation.PSCredential ($MailUsername, $MailSecPasswd)

#AzureCredentials
$Username = "powershell.service@muster.com"
$PasswordString = "01000000d08c9ddf0115d1118c7a00c04fc297eb0100000069bea857538892438c39e225cece44880000000002000000000003660000c00000001000000053e0c0d2f3d37d3ab07f64fd8c06aae30000000004800000a00000001000000035126e7005310d67b351c1b0b6b7b36538000000832b22bdd62b004aef4e83515b4736099137552ab79ae699dceeeb952e0225361b2d364762819ef6926f53a26b805fb1a788d3b7294ec0b9140000008f6f7f7f527caef592eae14d80564af5780947c0"
$SecPasswd = ConvertTo-SecureString $PasswordString;
$Credentials = New-Object System.Management.Automation.PSCredential ($Username, $SecPasswd)

Connect-ExchangeOnline -Credential $Credentials


 foreach ($ADGroup in $Configuration){
    
    Write-Host 
    Write-Host $ADGroup

    $ADuser = Get-ADGroupMember -identity $ADGroup -Recursive | Get-ADUser
    $ADuserName = $ADuser.UserPrincipalName

    $EXOMB = $ADGroup.Remove(0,22)
    $MBuser = Get-EXOMailboxPermission $EXOMB
    $MBuserName = $MBuser.User

    $MBRecipientPermission = Get-RecipientPermission $EXOMB
    $MBRecipientPermissionUserName = $MBRecipientPermission.Trustee

    #grant permission
    ForEach ($item in $ADuserName)
    {
        #grant FullAccess permission
        If (-not ( $MBuserName -contains $item ))
        {
            $ScriptLog += "Grant FullAccess permission for $item to $EXOMB sharedmailbox <br />"
            $SendMail = $true

            try
            {
                Add-MailboxPermission -Identity $EXOMB -User $item -AccessRights FullAccess -InheritanceType All -Confirm:$false
                Write-Host "Grant FullAccess permission for $item to $EXOMB sharedmailbox"
                
            }
            catch{
                    $ScriptLog += "<strong> ERROR: cloud not grant FullAccess permission for $item to $EXOMB sharedmailbox </strong> <br />"
                    Write-Host "ERROR: cloud not grant FullAccess permission for $item to $EXOMB sharedmailbox"
            }
  
        }
            ELSE
        {
            Write-Host "Alredy have FullAccess permission "$item
        }
              
             #grant Send As permission
        If (-not ( $MBRecipientPermissionUserName -contains $item ))
        {
            $ScriptLog += "Grant Send As permission for $item to $EXOMB sharedmailbox <br />"
            $SendMail = $true

            try
            {
                Add-RecipientPermission -Identity $EXOMB -AccessRights SendAs -Trustee $item -Confirm:$false
                Write-Host "Grant Send As permission for $item to $EXOMB sharedmailbox"
            }
            catch{
                    $ScriptLog += "<strong> ERROR: cloud not grant Send As permission for $item to $EXOMB sharedmailbox </strong> <br />"
                    Write-Host "ERROR: cloud not grant Send As permission for $item to $EXOMB sharedmailbox"
            }
  
        }
            ELSE
        {
            Write-Host "Alredy have Send As permission "$item
        }
    }


    #remove permission
    ForEach ($item in $MBuserName)
    {
        If (-not ( $ADuserName -contains $item ))
        {
            If ( $item -ne "NT AUTHORITY\SELF" )
            {
                $ScriptLog += "Remove permission for $item from $EXOMB sharedmailbox <br /> "
                Write-Host Remove permission for $item from $EXOMB sharedmailbox
                $SendMail = $true

                try
                {
                    Remove-MailboxPermission -Identity $EXOMB -User $item -AccessRights FullAccess,SendAs,DeleteItem,ReadPermission,ChangePermission,ChangeOwner -InheritanceType All -Confirm:$false
                    Remove-RecipientPermission -Identity $EXOMB -Trustee $item -AccessRights SendAs -Confirm:$false
                }
                catch{
                    $ScriptLog += "<strong> ERROR: cloud not remove permission for $item to $EXOMB sharedmailbox </strong> <br />"
                    Write-Host  "ERROR: cloud not remove permission for $item to $EXOMB sharedmailbox"
                }    
            }
     
         }
    }

    
    $ScriptLog += " <br /> "

    $ADGroup = $null
    $ADuser = $null
    $ADuserName = $null
    $EXOMB = $null
    $MBuser = $null
    $MBuserName = $null
    $item = $null
    
}

Disconnect-ExchangeOnline -Confirm:$false

If ($SendMail -eq $true)
{
    Write-Host 'Changes Done. Send E-Mail'
    Send-MailMessage -From 'do-not-reply@muster.com' -To 'it@muster.com' -Subject "Shared Mailbox Permission changed" -BodyAsHtml -Body "$ScriptLog" -Credential $MailCredentials -UseSsl -smtpserver smtp.office365.com -port 587
    #Send-MailMessage -SmtpServer 'outlook.muster.ch' -From 'monitoring@muster.ch' -To 'it@muster.com' -Subject "Shared Mailbox Permission changed" -BodyAsHtml -Body "$ScriptLog"    
}

$ScriptLog = $null
$SendMail = $false