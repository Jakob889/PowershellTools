
$path = "C:\temp"

# Get removing
Get-ChildItem $path -Recurse -Force | Where { $_.PSIsContainer } | %{
	$folder = $_
	Get-Acl $folder | %{
        foreach($acc in $_.access ) 
        { 
            $value = $acc.IdentityReference.Value 
            if($value -match "S-1-5-*") 
            { 
                $ACL.RemoveAccessRule($acc) | Out-Null 
                Set-Acl -Path $folder -AclObject $_ -ErrorAction Stop 
                Write-Host "Removed SID: $value  from  $folder " 
            } 
        }
	} 
}