$Device = Get-CimInstance -ClassName Win32_ComputerSystem | fw -Property Model | out-string

$Device = $Device.Trim()

$dir = "Driver $Device"

Write-Host please wait

If (!(test-path .\$dir))
{
	New-Item -ItemType Directory -Force -Path .\$dir
}

try
{
	Export-WindowsDriver -Destination ".\$dir\" -Online
}
catch
{
	Write-Host "'Cant export Drivers to Directory' $dir"
}

Write-Host check folder $dir