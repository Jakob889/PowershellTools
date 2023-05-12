
[void][Reflection.Assembly]::LoadWithPartialName('Microsoft.VisualBasic')
Add-Type -AssemblyName PresentationFramework

$global:username = ""
$global:password = ""

$Zippath = "C:\temp\files.zip"
$Filepath = "C:\temp\O365Update"
$BlobURL = "https://azure.blob.core.windows.net/o365update/O365Update.zip"

$Office2016SetupPath = $Filepath + "\Office2016_EN_64\setup.exe"
$Office2016XMLPath = $Filepath + "\Office2016_EN_64\uninstall_config.xml"
$Office2016Parameter = " /uninstall ProPlus /config " + $Office2016XMLPath

$O365SetupPath = $Filepath + "\O365BussinesOffline\setup.exe"
$O365XMLPath = $Filepath + "\O365BussinesOffline\Default.xml"
$O365Parameter = "/configure " + $O365XMLPath

#$Office2010SetupPath = $Filepath + "\2010_64bit\setup.exe"
#$Office2010XMLPath = $Filepath + "\2010_64bit\config.xml"
#$Office2010MSPPath = $Filepath + "\2010_64bit\STD_CHDL.MSP"
#$Office2010Parameter = "/adminfile " + $Office2010MSPPath + " /config " + $Office2010XMLPath
$Office2010Parameter = '/adminfile C:\temp\O365Update\2010_64bit\STD_CHDL.MSP /config C:\temp\O365Update\2010_64bit\config.xml'


#-----------Credential Form--------

function GetCredForms
{
	$title = 'Username'
	$msg = 'Enter Username:'
	$global:username = [Microsoft.VisualBasic.Interaction]::InputBox($msg, $title)
	
	[void][System.Reflection.Assembly]::LoadWithPartialName("System.Drawing")
	[void][System.Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms")
	$objForm = New-Object System.Windows.Forms.Form
	$objForm.Text = "Data Entry Form"
	$objForm.Size = New-Object System.Drawing.Size(300, 150)
	$objForm.StartPosition = "CenterScreen"
	$objForm.KeyPreview = $True
	$objForm.Add_KeyDown({
			if ($_.KeyCode -eq "Enter")
			{ $x = $objTextBox.Text; $objForm.Close() }
		})
	$objForm.Add_Shown({ $objForm.Activate(); $MaskedTextBox.focus() })
	$OKButton = New-Object System.Windows.Forms.Button
	$OKButton.Location = New-Object System.Drawing.Size(120, 80)
	$OKButton.Size = New-Object System.Drawing.Size(75, 23)
	$OKButton.Text = "OK"
	$OKButton.Add_Click({ $x = $objTextBox.Text; $objForm.Close() })
	$objForm.Controls.Add($OKButton)
	$objLabel = New-Object System.Windows.Forms.Label
	$objLabel.Location = New-Object System.Drawing.Size(10, 20)
	$objLabel.Size = New-Object System.Drawing.Size(280, 20)
	$objLabel.Text = "Enter password below:"
	$objForm.Controls.Add($objLabel)
	$MaskedTextBox = New-Object System.Windows.Forms.MaskedTextBox
	$MaskedTextBox.PasswordChar = '*'
	$MaskedTextBox.Location = New-Object System.Drawing.Size(10, 40)
	$MaskedTextBox.Size = New-Object System.Drawing.Size(260, 20)
	$objForm.Controls.Add($MaskedTextBox)
	$objForm.Topmost = $True
	$objForm.Add_Shown({ $objForm.Activate() })
	[void]$objForm.ShowDialog()
	
	$global:password = $MaskedTextBox.Text
}

Function Test-ADAuthentication
{
	param (
		$username,
		$password)
	
	(New-Object DirectoryServices.DirectoryEntry "", $username, $password).psbase.name -ne $null
}

GetCredForms

$testauth = Test-ADAuthentication -username $global:username -password $global:password

if (!$testauth)
{
	Write-Host 'Authentication failed'
	[System.Windows.MessageBox]::Show('Authentication failed', 'Error')
	exit
}

$PWord = ConvertTo-SecureString -String $password -AsPlainText -Force
$cred = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $username, $PWord


#-----------Start downloading the Files

function DownloadFiels
{
	Clear-Host
	Write-Host 'Downloading the Office 365, please wait...'
	
	$ProgressPreference = 'SilentlyContinue'
	Invoke-WebRequest -Uri $BlobURL -OutFile C:\temp\files.zip
	$ProgressPreference = 'Continue'
	
	$ZipSize = (gci $Zippath | measure Length -s).sum / 1Mb
	
	If (!(test-path $Zippath) -or ($ZipSize -lt 5243))
	{
		[System.Windows.MessageBox]::Show('Download failed', 'Error')
		
		Start-Sleep -Seconds 5
		
		exit
	}
	Write-Host 'Download done!'
}

Write-Host Do not turn off your Comupter:
[System.Windows.MessageBox]::Show('Do not turn off your Comupter!!','Downloading Office 365')


If (test-path $Zippath)
{
	$ZipSize = (gci $Zippath | measure Length -s).sum / 1Mb
	
	If ($ZipSize -lt 5243)
	{
		DownloadFiels
	}
	else
	{
		Clear-Host
		Write-Host 'Downloading already done...'
	}
}
ELSE
{
	DownloadFiels
}

Write-Host 'Start to Unzip the Files:'
[System.Windows.MessageBox]::Show('Please Close all Office application and Press OK','Close Office')



#-----------------Unzip

Expand-Archive -LiteralPath 'C:\temp\files.zip' -DestinationPath C:\temp\ | Out-Null

If (!(test-path $Filepath))
{
    [System.Windows.MessageBox]::Show('Unzip failed','Error')
    Start-Sleep -Seconds 5
	exit
}
Write-Host ''
Write-Host 'Uninstall Office 2010/16'
[System.Windows.MessageBox]::Show('Uninstall Office 2010/16 and installing Office 365','Install Office 365')
Write-Host ''

#-------------Uninstall old office


try
{
	$O16proc = Start-Process -FilePath $Office2016SetupPath -ArgumentList $Office2016Parameter -Credential $cred -NoNewWindow -PassThru
	$O16proc.WaitForExit()
}
catch
{
	Write-Host "Error while trying to uninstall Office2010 and Office2016: $($_.Exception.Message)"
	Start-Sleep -Seconds 15
	Exit
}

Start-Sleep -Seconds 5

Write-Host 'Start installing Office 365:'
Write-Host ''
#--------------install Office 354 and Access 2010

try
{
	$O365proc = Start-Process -FilePath $O365SetupPath -ArgumentList $O365Parameter -Credential $cred -NoNewWindow -PassThru
	$O365proc.WaitForExit()
}
catch
{
	Write-Host "Error while trying to install O365: $($_.Exception.Message)"
	Start-Sleep -Seconds 25
	Exit
}

[System.Windows.MessageBox]::Show('Install Access', 'check')
Write-Host ''
try
{
	
	$O10proc = Start-Process -FilePath C:\temp\O365Update\2010_64bit\setup.exe -ArgumentList /adminfile C:\temp\O365Update\2010_64bit\STD_CHDL.MSP /config C:\temp\O365Update\2010_64bit\config.xml -Credential $cred -NoNewWindow -PassThru
	$O10proc.WaitForExit()
}
catch
{
	Write-Host "Error while trying to install Office2010 Access: $($_.Exception.Message)"
	Start-Sleep -Seconds 25
	Exit
}

Start-Sleep -Seconds 2

[System.Windows.MessageBox]::Show('Installation DONE! Deleting old files', 'Finish')
Write-Host ''

Start-Sleep -Seconds 2

Remove-Item -path "c:\temp\files.zip" -recurse
Remove-Item -path "C:\temp\O365Update" -recurse

[System.Windows.MessageBox]::Show('Please reboot your Comupter', 'Reboot')
