$filepath = ".\clients.csv"
$password = 'fäldfmkg=490!'

Write-Host "set the password: $password"


$Imported = Import-Csv $filepath -Header hostname, online, status, error

foreach ($i in $Imported)
{
	
	$host1 = $i.hostname
	
	if ((Test-Connection -ComputerName $i.hostname -count 1 -ErrorAction 0))
	{
		$i.online = "ONLINE"
		
		Write-Host "`t$host1 is Online"
		
		try
		{
			$account = [ADSI]("WinNT://$host1/Administrator,user")
			$account.psbase.invoke("setpassword", $password)
			$i.status = "OK"
			Write-Host "`tPassword Change completed successfully"
		}
		
		catch
		{
			$i.status = "FAILED"
			$i.error = "`tFailed to Change the administrator password. Error: $_"
			Write-Host "`tFailed to Change the administrator password. Error: $_"
		}
		
	}
	else
	{
		$i.online = "OFFLINE"
		
		Write-Host "`t$host1 is OFFLINE"
	}
	
}

$Imported  | Export-Csv ".\updated.csv" -NoTypeInformation

