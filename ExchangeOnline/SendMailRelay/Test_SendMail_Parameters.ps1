$SMTP = "smtp.office365.com"
$Port = "587"
$From = "noreply@muster.ch"
$To = "hans.muster@muster.ch"
$PW = "5KNdsfg5r62sdfg'`!MFdofk"
$Body = "Test1"
$Subject = "Test1"
$LogPath = "C:\SendMailTest\Log.txt"


$argumentList = @($SMTP,$Port,$From,$To,$PW,$Body,$Subject,$LogPath)

$scriptPath = "C:\Scripts\Tools\SendMailTest\SendMail_Parameters.ps1" 


Invoke-Expression "& `"$scriptPath`" $argumentList"