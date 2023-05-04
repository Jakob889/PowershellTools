param (
    [Parameter(Mandatory = $true)]
    [string]$SMTP,
    [Parameter(Mandatory = $true)]
    [int]$Port,
    [Parameter(Mandatory = $true)]
    [string]$From,
    [Parameter(Mandatory = $true)]
    [string]$To,
    [Parameter(Mandatory = $true)]
    [string]$PW,
    [Parameter(Mandatory = $false)]
    [string]$Body,
    [Parameter(Mandatory = $true)]
    [string]$Subject,
    [Parameter(Mandatory = $false)]
    [string]$LogPath,
    [Parameter(Mandatory=$false)]
    [string[]]$Docs
)

#$LogPath = "Y:\Scripts\Tools\SendMailTest\Log.txt"
$Tstamp = (Get-Date).toString("dd/MM/yyyy HH:mm:ss")

try
{

    $Email = New-Object Net.Mail.SmtpClient($SMTP, $Port)
    $Email.EnableSsl = $true
    $Email.Credentials = New-Object System.Net.NetworkCredential($From, $PW);

    # Create the email message
    $mail = New-Object System.Net.Mail.MailMessage($From, $To, $Subject, $Body)
    $mail.IsBodyHtml = $true

    # Attach each document in the array
    $DocsArray = $Docs -split ","
    foreach ($doc in $DocsArray) {
        if (-not [string]::IsNullOrWhiteSpace($doc)) {
            try
            {
                $attachment = New-Object System.Net.Mail.Attachment($doc)
                $mail.Attachments.Add($attachment)
            }
            catch
            {
                $errorMessage = $_.Exception.Message
                Add-Content $LogPath "$Tstamp, 'SendMailRelay.ps1', 'ERROR: $errorMessage', Error to add attachment file: $doc"
            }
        }
    }

    # Send the email
    $Email.Send($mail)

    Add-Content $LogPath "$Tstamp, 'SendMailRelay.ps1', 'Mail was send.', From: $From PW: $To"
}
catch
{
    $errorMessage = $_.Exception.Message
    Write-Host $errorMessage
    Add-Content $LogPath "$Tstamp, 'SendMailRelay.ps1', 'ERROR: $errorMessage', From: $From PW: $To"
}


