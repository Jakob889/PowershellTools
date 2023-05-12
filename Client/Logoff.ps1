Add-Type -AssemblyName PresentationCore, PresentationFramework

$msgBody = "Logoff now?"
$msgTitle = "Confirm Logoff"
$msgButton = 'YesNoCancel'
$msgImage = 'Question'
$Result = [System.Windows.MessageBox]::Show($msgBody, $msgTitle, $msgButton, $msgImage)

if ($Result.value__ -eq 6)
{
	logoff
}