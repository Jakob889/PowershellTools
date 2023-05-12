# Document creation
[xml]$xmlDoc = New-Object system.Xml.XmlDocument

$xmlDoc.LoadXml("<?xml version=`"1.0`" encoding=`"utf-8`"?><groups></groups>")

$groups = Get-ADGroup -Filter { name -like "*G_CH_DL_*" } -SearchBase "DC=muster,DC=local" | Select-Object -ExpandProperty sAMAccountName

foreach ($group in $groups)
{
	# New node
	$xmlElt = $xmlDoc.CreateElement("group")
	$xmlAtt = $xmlDoc.CreateAttribute("name")
	$xmlAtt.Value = "$group"
	$xmlElt.Attributes.Append($xmlAtt)
	
	$groupmambers = Get-AdGroupMember -identity $group | Select-Object -ExpandProperty SamAccountName
	
	foreach ($member in $groupmambers)
	{
		
		# Creation of a sub node
		$xmlSubElt = $xmlDoc.CreateElement("user")
		$xmlSubAtt = $xmlDoc.CreateAttribute("name")
		$xmlSubAtt.Value = "$member"
		$xmlSubElt.Attributes.Append($xmlSubAtt)
		$xmlElt.AppendChild($xmlSubElt)
		
	}
	
	# Add the node to the document
	$xmlDoc.LastChild.AppendChild($xmlElt);
}


# Save File
$xmlDoc.Save(".\UserInGroups.xml")