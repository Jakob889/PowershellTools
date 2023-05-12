
$SendMail = $false
$UsermailNickname = $null
$ExchangeCon = $null
$ADuser = $null

$ADGroup = "DL_GLOBAL_Office365_Mailbox"

#mail
$To = "it@muster.ch"
$From = "monitoring@muster.com"
$SMTPServer = "mailrelay-o365.muster.local"
$Subject = "Exchange Online Mailbox Created "
$Body = $null


Import-Module ActiveDirectory

$ADuser = Get-ADGroupMember -identity $ADGroup -Recursive | Get-ADUser
$ADuserName = $ADuser.UserPrincipalName


foreach ($user in $ADuser){
    #connect online check if mailbox and license exist
    #Write-Host $User.UserPrincipalName
    $UsermailNickname = get-aduser $User.sAMAccountName -properties * | select -property mailNickname

    if !($UsermailNickname.mailNickname -ne $null){
       
        Write-Host "usermailbox nicht vorhanden"
        Write-Host $User.UserPrincipalName
        if ($ExchangeCon -eq $null){
        Add-PSSnapin Microsoft.Exchange.Management.PowerShell.SnapIn
        $ExchangeCon = $true

        }

        $AliasMail = $user.UserPrincipalName

        if ($AliasMail -contains "@muster.com"){

            $Alias = $AliasMail.Replace("@muster.com","")
            #Enable-RemoteMailbox "$Alias" -RemoteRoutingAddress "$Alias@musterag.mail.onmicrosoft.com"

            $SendMail = $true
            $name = $User.UserPrincipalName
            $Body += "Created mailbox for $name <br /> "

        }
        else{

            $SendMail = $true
            $name = $User.UserPrincipalName
            $Body += "User $name dosen't has a muster.com account - No mailbox created<br /> "
        }

    }

}


If ($SendMail -eq $true)
{
    Send-MailMessage -SmtpServer $SMTPServer -From $From -To $To -Subject $Subject -Body $Body -BodyAsHtml  
}

$Body = $null
$SendMail = $false
$ADuser = $null