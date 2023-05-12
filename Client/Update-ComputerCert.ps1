Write-Host $env:computername

$oMachineStore = New-Object System.Security.Cryptography.X509Certificates.X509Store("My", "LocalMachine")
$oMachineStore.Open("ReadOnly")
$cert = $oMachineStore.Certificates | select-object Subject, SerialNumber, Issuer |Where-Object {$_.Issuer -like "*CN=muster.local-SRV018-CA*" }
$certSN = $cert.SerialNumber


Write-Host $certSN

try
{
	certreq -enroll -machine -q -PolicyServer SRV018 -cert $certSN renew
}
Catch
{
	Write-Host $_.Exception.Message
}


Pause