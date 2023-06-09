﻿<#	
	.NOTES
	===========================================================================
	 Created with: 	SAPIEN Technologies, Inc., PowerShell Studio 2020 v5.7.172
	 Created on:   	30.11.2021 08:17
	 Created by:   	adm_schmid
	 Organization: 	
	 Filename:     	
	===========================================================================
	.DESCRIPTION
		A description of the file.
#>
[void][Reflection.Assembly]::LoadWithPartialName('Microsoft.VisualBasic')
Add-Type -AssemblyName PresentationFramework

$global:username = ""
$global:password = ""

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

#----test---

Start-Process -FilePath "C:\Program Files\Google\Chrome\Application\chrome.exe" -ArgumentList $cred
Start-Sleep -Seconds 10

# SIG # Begin signature block
# MIIkwAYJKoZIhvcNAQcCoIIksTCCJK0CAQExDzANBglghkgBZQMEAgEFADB5Bgor
# BgEEAYI3AgEEoGswaTA0BgorBgEEAYI3AgEeMCYCAwEAAAQQH8w7YFlLCE63JNLG
# KX7zUQIBAAIBAAIBAAIBAAIBADAxMA0GCWCGSAFlAwQCAQUABCAF5MycXMllyXOB
# iT6Oe1lujqAIIp7bYWQVGwGzoOxglaCCHs0wggNfMIICR6ADAgECAgsEAAAAAAEh
# WFMIojANBgkqhkiG9w0BAQsFADBMMSAwHgYDVQQLExdHbG9iYWxTaWduIFJvb3Qg
# Q0EgLSBSMzETMBEGA1UEChMKR2xvYmFsU2lnbjETMBEGA1UEAxMKR2xvYmFsU2ln
# bjAeFw0wOTAzMTgxMDAwMDBaFw0yOTAzMTgxMDAwMDBaMEwxIDAeBgNVBAsTF0ds
# b2JhbFNpZ24gUm9vdCBDQSAtIFIzMRMwEQYDVQQKEwpHbG9iYWxTaWduMRMwEQYD
# VQQDEwpHbG9iYWxTaWduMIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEA
# zCV2kHkGeCIW9cCDtoTKKJ79BXYRxa2IcvxGAkPHsoqdBF8kyy5L4WCCRuFSqwyB
# R3Bs3WTR6/Usow+CPQwrrpfXthSGEHm7OxOAd4wI4UnSamIvH176lmjfiSeVOJ8G
# 1z7JyyZZDXPesMjpJg6DFcbvW4vSBGDKSaYo9mk79svIKJHlnYphVzesdBTcdOA6
# 7nIvLpz70Lu/9T0A4QYz6IIrrlOmOhZzjN1BDiA6wLSnoemyT5AuMmDpV8u5BJJo
# aOU4JmB1sp93/5EU764gSfytQBVI0QIxYRleuJfvrXe3ZJp6v1/BE++bYvsNbOBU
# aRapA9pu6YOTcXbGaYWCFwIDAQABo0IwQDAOBgNVHQ8BAf8EBAMCAQYwDwYDVR0T
# AQH/BAUwAwEB/zAdBgNVHQ4EFgQUj/BLf6guRSSuTVD6Y5qL3uLdG7wwDQYJKoZI
# hvcNAQELBQADggEBAEtA28BQqv7IDO/3llRFSbuWAAlBrLMThoYoBzPKa+Z0uboA
# La6kCtP18fEPir9zZ0qDx0R7eOCvbmxvAymOMzlFw47kuVdsqvwSluxTxi3kJGy5
# lGP73FNoZ1Y+g7jPNSHDyWj+ztrCU6rMkIrp8F1GjJXdelgoGi8d3s0AN0GP7URt
# 11Mol37zZwQeFdeKlrTT3kwnpEwbc3N29BeZwh96DuMtCK0KHCz/PKtVDg+Rfjbr
# w1dJvuEuLXxgi8NBURMjnc73MmuUAaiZ5ywzHzo7JdKGQM47LIZ4yWEvFLru21Vv
# 34TuBQlNvSjYcs7TYlBlHuuSl4Mx2bO1ykdYP18wggOzMIICm6ADAgECAhAtu7RH
# ZOtnikJT971qd11LMA0GCSqGSIb3DQEBCwUAME4xFTATBgoJkiaJk/IsZAEZFgVs
# b2NhbDEUMBIGCgmSJomT8ixkARkWBGx1emkxHzAdBgNVBAMTFmx1emkubG9jYWwt
# Q0hETFMwMTgtQ0EwHhcNMTMwMzE1MTQ1MjIzWhcNMjIwOTEyMDkwMzAxWjBOMRUw
# EwYKCZImiZPyLGQBGRYFbG9jYWwxFDASBgoJkiaJk/IsZAEZFgRsdXppMR8wHQYD
# VQQDExZsdXppLmxvY2FsLUNIRExTMDE4LUNBMIIBIjANBgkqhkiG9w0BAQEFAAOC
# AQ8AMIIBCgKCAQEAk/H/qb4oU0FjqABEnMJuFBAdEmvw/E/A+eZuy9mJl+6d7em1
# BgRCI2rKkuVsC/h32VRqLE0+CziYCCAnG27WYIcJdzhVoN+cruewLNcnZYuFALUt
# hoB28cWwVtSM02AAXThNLSDZM2IkMTQzv4pKqHJ3OLa8A9yxHtqYiJIvJv5ZxZPi
# B0aUsuYN9SCnB50ejwZTpCZgJFd8PgBevYPzbUdU4WEHp5m0dVz9PVbhMUMYo0QN
# 3nd7hVgqWQee5G83blIUbpvq/UaeapRgt/g0Bzj6pp1+XjtxKngpuFMbWOFn8JHl
# J3gl4AAYU5nEPCQgvjDmS+cYNg4ltwgC3y7wAwIDAQABo4GMMIGJMBMGCSsGAQQB
# gjcUAgQGHgQAQwBBMAsGA1UdDwQEAwIBhjAPBgNVHRMBAf8EBTADAQH/MB0GA1Ud
# DgQWBBTCfsaL7DeN8KRh0Wz9TSJOizmCVjAQBgkrBgEEAYI3FQEEAwIBATAjBgkr
# BgEEAYI3FQIEFgQUrLgEy1P90S8gbKMr1tF9DisHKJEwDQYJKoZIhvcNAQELBQAD
# ggEBACvY5NMF/0b3LQu35BN4FnsbAlxiiauNIcv3lYHtq7bVEuPvJO2ARXXTSOBS
# 4cYbsahd/oy5/fBGP64a62Xcu++HQI7FKRkBg21YwzAGTZwskLH4bFO3ezdkAYJ0
# fqh39eD6Q0gYL57k+oEc7u5RmYlLHEHDFKxOi1NC018pWPrGAOYB1TvPU21CgIX5
# jZvRe4D4V70606HxTztRE9MlQrrmjQK1Ow6zv+Q7igTb8ALRhrtQbT0oGFRMjCb+
# XHABAckjuR07uDk2OGrdNuomQnvj6+vNQl5H3Fijjwwv/s7OZM+A2NgAw1XWzMIT
# 4ScPmnQpF76jTGZafETKHiBK2IEwggVHMIIEL6ADAgECAg0B8kBCQM79ItvpbHH8
# MA0GCSqGSIb3DQEBDAUAMEwxIDAeBgNVBAsTF0dsb2JhbFNpZ24gUm9vdCBDQSAt
# IFIzMRMwEQYDVQQKEwpHbG9iYWxTaWduMRMwEQYDVQQDEwpHbG9iYWxTaWduMB4X
# DTE5MDIyMDAwMDAwMFoXDTI5MDMxODEwMDAwMFowTDEgMB4GA1UECxMXR2xvYmFs
# U2lnbiBSb290IENBIC0gUjYxEzARBgNVBAoTCkdsb2JhbFNpZ24xEzARBgNVBAMT
# Ckdsb2JhbFNpZ24wggIiMA0GCSqGSIb3DQEBAQUAA4ICDwAwggIKAoICAQCVB+hz
# ymb57BTKezz3DQjxtEULLIK0SMbrWzyug7hBkjMUpG9/6SrMxrCIa8W2idHGsv8U
# zlEUIexK3RtaxtaH7k06FQbtZGYLkoDKRN5zlE7zp4l/T3hjCMgSUG1CZi9NuXko
# TVIaihqAtxmBDn7EirxkTCEcQ2jXPTyKxbJm1ZCatzEGxb7ibTIGph75ueuqo7i/
# voJjUNDwGInf5A959eqiHyrScC5757yTu21T4kh8jBAHOP9msndhfuDqjDyqtKT2
# 85VKEgdt/Yyyic/QoGF3yFh0sNQjOvddOsqi250J3l1ELZDxgc1Xkvp+vFAEYzTf
# a5MYvms2sjnkrCQ2t/DvthwTV5O23rL44oW3c6K4NapF8uCdNqFvVIrxclZuLojF
# UUJEFZTuo8U4lptOTloLR/MGNkl3MLxxN+Wm7CEIdfzmYRY/d9XZkZeECmzUAk10
# wBTt/Tn7g/JeFKEEsAvp/u6P4W4LsgizYWYJarEGOmWWWcDwNf3J2iiNGhGHcIEK
# qJp1HZ46hgUAntuA1iX53AWeJ1lMdjlb6vmlodiDD9H/3zAR+YXPM0j1ym1kFCx6
# WE/TSwhJxZVkGmMOeT31s4zKWK2cQkV5bg6HGVxUsWW2v4yb3BPpDW+4LtxnbsmL
# EbWEFIoAGXCDeZGXkdQaJ783HjIH2BRjPChMrwIDAQABo4IBJjCCASIwDgYDVR0P
# AQH/BAQDAgEGMA8GA1UdEwEB/wQFMAMBAf8wHQYDVR0OBBYEFK5sBaOTE+Ki5+LX
# HNbH8H/IZ1OgMB8GA1UdIwQYMBaAFI/wS3+oLkUkrk1Q+mOai97i3Ru8MD4GCCsG
# AQUFBwEBBDIwMDAuBggrBgEFBQcwAYYiaHR0cDovL29jc3AyLmdsb2JhbHNpZ24u
# Y29tL3Jvb3RyMzA2BgNVHR8ELzAtMCugKaAnhiVodHRwOi8vY3JsLmdsb2JhbHNp
# Z24uY29tL3Jvb3QtcjMuY3JsMEcGA1UdIARAMD4wPAYEVR0gADA0MDIGCCsGAQUF
# BwIBFiZodHRwczovL3d3dy5nbG9iYWxzaWduLmNvbS9yZXBvc2l0b3J5LzANBgkq
# hkiG9w0BAQwFAAOCAQEASaxexYPzWsthKk2XShUpn+QUkKoJ+cR6nzUYigozFW1y
# hyJOQT9tCp4YrtviX/yV0SyYFDuOwfA2WXnzjYHPdPYYpOThaM/vf2VZQunKVTm8
# 08Um7nE4+tchAw+3TtlbYGpDtH0J0GBh3artAF5OMh7gsmyePLLCu5jTkHZqaa0a
# 3KiJ2lhP0sKLMkrOVPs46TsHC3UKEdsLfCUn8awmzxFT5tzG4mE1MvTO3YPjGTrr
# wmijcgDIJDxOuFM8sRer5jUs+dNCKeZfYAOsQmGmsVdqM0LfNTGGyj43K9rE2iT1
# ThLytrm3R+q7IK1hFregM+Mtiae8szwBfyMagAk06TCCBZ4wggSGoAMCAQICCh4B
# DZAAAQAAAiEwDQYJKoZIhvcNAQELBQAwTjEVMBMGCgmSJomT8ixkARkWBWxvY2Fs
# MRQwEgYKCZImiZPyLGQBGRYEbHV6aTEfMB0GA1UEAxMWbHV6aS5sb2NhbC1DSERM
# UzAxOC1DQTAeFw0yMDA3MzExMjUwMTJaFw0yMjA5MTIwOTAzMDFaMFgxFDASBgNV
# BAYTC1N3aXR6ZXJsYW5kMRAwDgYDVQQKEwdMVVpJIEFHMQswCQYDVQQLEwJJVDEh
# MB8GA1UEAxMYTFVaSSBBRyBEZXZlbG9wbWVudCBUZWFtMIIBIjANBgkqhkiG9w0B
# AQEFAAOCAQ8AMIIBCgKCAQEAkGwwSFgSP/NdfOwWe40BbmPffOA9ssviX4807yyW
# UcF0I7K29t1ykgFUH8YcsUn3pvtN0C8vZD/XiBl6F2anPPwJCMoiB2zdZHJinAYF
# 20gOJRXgPyaQ3FRyp8cLzD4y+MQJM1gxLStsSkOBtvvLi4swa3F+baeMzpAU9vtZ
# lFwjVh2C6ZcC3T1SebgVNWhUXYGZDL6AexZ+nllmSHsmD90NkTYebVw7mqlau2bO
# GXkuR4N7yurnbqpm7uWz2jKWkGRQJXsyouKVjoamnDbw8xMkg8FE5DW9YlfPZRGG
# RlsQ0B5B6Doh3RwrRvirFrpeB/nGLysS5dasUTFtaKuVqQIDAQABo4ICcjCCAm4w
# PgYJKwYBBAGCNxUHBDEwLwYnKwYBBAGCNxUIhMHrfYaU3X+HiZMmhIuETYWG212B
# F4So41CEubhgAgFkAgECMBMGA1UdJQQMMAoGCCsGAQUFBwMDMAsGA1UdDwQEAwIH
# gDAMBgNVHRMBAf8EAjAAMBsGCSsGAQQBgjcVCgQOMAwwCgYIKwYBBQUHAwMwHQYD
# VR0OBBYEFD1Ek8vklftYKE1aojBtPUkSWKT/MB8GA1UdIwQYMBaAFMJ+xovsN43w
# pGHRbP1NIk6LOYJWMIHUBgNVHR8EgcwwgckwgcaggcOggcCGgb1sZGFwOi8vL0NO
# PWx1emkubG9jYWwtQ0hETFMwMTgtQ0EsQ049Q0hETFMwMTgsQ049Q0RQLENOPVB1
# YmxpYyUyMEtleSUyMFNlcnZpY2VzLENOPVNlcnZpY2VzLENOPUNvbmZpZ3VyYXRp
# b24sREM9bHV6aSxEQz1sb2NhbD9jZXJ0aWZpY2F0ZVJldm9jYXRpb25MaXN0P2Jh
# c2U/b2JqZWN0Q2xhc3M9Y1JMRGlzdHJpYnV0aW9uUG9pbnQwgccGCCsGAQUFBwEB
# BIG6MIG3MIG0BggrBgEFBQcwAoaBp2xkYXA6Ly8vQ049bHV6aS5sb2NhbC1DSERM
# UzAxOC1DQSxDTj1BSUEsQ049UHVibGljJTIwS2V5JTIwU2VydmljZXMsQ049U2Vy
# dmljZXMsQ049Q29uZmlndXJhdGlvbixEQz1sdXppLERDPWxvY2FsP2NBQ2VydGlm
# aWNhdGU/YmFzZT9vYmplY3RDbGFzcz1jZXJ0aWZpY2F0aW9uQXV0aG9yaXR5MA0G
# CSqGSIb3DQEBCwUAA4IBAQA1P1EfZne+7OUvjlLwJ9tyDk/eD/+/cJ5JZkzoF3f4
# qD5SPgsIu7LKUxEYtl80B0vooU86r6puHlyf4/MYqf23nx+enQFqBbTdNoLzFDnk
# snRMJSQ6ZLSsY1EIPcmNK/zxm/ABbAp6ALgwWWifPQcPA4w+0kcYALE9PG/5VNl4
# 3H5b2n6F+/qcIgl2pBdU2U4zXeNnN0vxurtVWIGpT+0htdReiJFhwwh1waIYLzgR
# 0c7IxtnwE4HS94d+bhuGvq8gIBn7hdfgG62PNUvNp73Z3odlCFZdJEp94Ls24Dn2
# kcOU8KDioRunor+8g9Rx8TBCdibspYPOYhnYmzPJmYrFMIIGWTCCBEGgAwIBAgIN
# AewckkDe/S5AXXxHdDANBgkqhkiG9w0BAQwFADBMMSAwHgYDVQQLExdHbG9iYWxT
# aWduIFJvb3QgQ0EgLSBSNjETMBEGA1UEChMKR2xvYmFsU2lnbjETMBEGA1UEAxMK
# R2xvYmFsU2lnbjAeFw0xODA2MjAwMDAwMDBaFw0zNDEyMTAwMDAwMDBaMFsxCzAJ
# BgNVBAYTAkJFMRkwFwYDVQQKExBHbG9iYWxTaWduIG52LXNhMTEwLwYDVQQDEyhH
# bG9iYWxTaWduIFRpbWVzdGFtcGluZyBDQSAtIFNIQTM4NCAtIEc0MIICIjANBgkq
# hkiG9w0BAQEFAAOCAg8AMIICCgKCAgEA8ALiMCP64BvhmnSzr3WDX6lHUsdhOmN8
# OSN5bXT8MeR0EhmW+s4nYluuB4on7lejxDXtszTHrMMM64BmbdEoSsEsu7lw8nKu
# jPeZWl12rr9EqHxBJI6PusVP/zZBq6ct/XhOQ4j+kxkX2e4xz7yKO25qxIjw7pf2
# 3PMYoEuZHA6HpybhiMmg5ZninvScTD9dW+y279Jlz0ULVD2xVFMHi5luuFSZiqgx
# kjvyen38DljfgWrhsGweZYIq1CHHlP5CljvxC7F/f0aYDoc9emXr0VapLr37WD21
# hfpTmU1bdO1yS6INgjcZDNCr6lrB7w/Vmbk/9E818ZwP0zcTUtklNO2W7/hn6gi+
# j0l6/5Cx1PcpFdf5DV3Wh0MedMRwKLSAe70qm7uE4Q6sbw25tfZtVv6KHQk+JA5n
# Jsf8sg2glLCylMx75mf+pliy1NhBEsFV/W6RxbuxTAhLntRCBm8bGNU26mSuzv31
# BebiZtAOBSGssREGIxnk+wU0ROoIrp1JZxGLguWtWoanZv0zAwHemSX5cW7pnF0C
# TGA8zwKPAf1y7pLxpxLeQhJN7Kkm5XcCrA5XDAnRYZ4miPzIsk3bZPBFn7rBP1Sj
# 2HYClWxqjcoiXPYMBOMp+kuwHNM3dITZHWarNHOPHn18XpbWPRmwl+qMUJFtr1eG
# fhA3HWsaFN8CAwEAAaOCASkwggElMA4GA1UdDwEB/wQEAwIBhjASBgNVHRMBAf8E
# CDAGAQH/AgEAMB0GA1UdDgQWBBTqFsZp5+PLV0U5M6TwQL7Qw71lljAfBgNVHSME
# GDAWgBSubAWjkxPioufi1xzWx/B/yGdToDA+BggrBgEFBQcBAQQyMDAwLgYIKwYB
# BQUHMAGGImh0dHA6Ly9vY3NwMi5nbG9iYWxzaWduLmNvbS9yb290cjYwNgYDVR0f
# BC8wLTAroCmgJ4YlaHR0cDovL2NybC5nbG9iYWxzaWduLmNvbS9yb290LXI2LmNy
# bDBHBgNVHSAEQDA+MDwGBFUdIAAwNDAyBggrBgEFBQcCARYmaHR0cHM6Ly93d3cu
# Z2xvYmFsc2lnbi5jb20vcmVwb3NpdG9yeS8wDQYJKoZIhvcNAQEMBQADggIBAH/i
# iNlXZytCX4GnCQu6xLsoGFbWTL/bGwdwxvsLCa0AOmAzHznGFmsZQEklCB7km/fW
# pA2PHpbyhqIX3kG/T+G8q83uwCOMxoX+SxUk+RhE7B/CpKzQss/swlZlHb1/9t6C
# yLefYdO1RkiYlwJnehaVSttixtCzAsw0SEVV3ezpSp9eFO1yEHF2cNIPlvPqN1eU
# kRiv3I2ZOBlYwqmhfqJuFSbqtPl/KufnSGRpL9KaoXL29yRLdFp9coY1swJXH4uc
# /LusTN763lNMg/0SsbZJVU91naxvSsguarnKiMMSME6yCHOfXqHWmc7pfUuWLMwW
# axjN5Fk3hgks4kXWss1ugnWl2o0et1sviC49ffHykTAFnM57fKDFrK9RBvARxx0w
# xVFWYOh8lT0i49UKJFMnl4D6SIknLHniPOWbHuOqhIKJPsBK9SH+YhDtHTD89szq
# SCd8i3VCf2vL86VrlR8EWDQKie2CUOTRe6jJ5r5IqitV2Y23JSAOG1Gg1GOqg+ps
# cmFKyfpDxMZXxZ22PLCLsLkcMe+97xTYFEBsIB3CLegLxo1tjLZx7VIh/j72n585
# Gq6s0i96ILH0rKod4i0UnfqWah3GPMrz2Ry/U02kR1l8lcRDQfkl4iwQfoH5DZSn
# ffK1CfXYYHJAUJUg1ENEvvqglecgWbZ4xqRqqiKbMIIGZTCCBE2gAwIBAgIQAYTT
# qM43getX9P2He4OusjANBgkqhkiG9w0BAQsFADBbMQswCQYDVQQGEwJCRTEZMBcG
# A1UEChMQR2xvYmFsU2lnbiBudi1zYTExMC8GA1UEAxMoR2xvYmFsU2lnbiBUaW1l
# c3RhbXBpbmcgQ0EgLSBTSEEzODQgLSBHNDAeFw0yMTA1MjcxMDAwMTZaFw0zMjA2
# MjgxMDAwMTVaMGMxCzAJBgNVBAYTAkJFMRkwFwYDVQQKDBBHbG9iYWxTaWduIG52
# LXNhMTkwNwYDVQQDDDBHbG9iYWxzaWduIFRTQSBmb3IgTVMgQXV0aGVudGljb2Rl
# IEFkdmFuY2VkIC0gRzQwggGiMA0GCSqGSIb3DQEBAQUAA4IBjwAwggGKAoIBgQDi
# opu2Sfs0SCgjB4b9UhNNusuqNeL5QBwbe2nFmCrMyVzvJ8bsuCVlwz8dROfe4Qjv
# BBcAlZcM/dtdg7SI66COm0+DuvnfXhhUagIODuZU8DekHpxnMQW1N3F8en7YgWUz
# 5JrqsDE3x2a0o7oFJ+puUoJY2YJWJI3567MU+2QAoXsqH3qeqGOR5tjRIsY/0p04
# P6+VaVsnv+hAJJnHH9l7kgUCfSjGPDn3es33ZSagN68yBXeXauEQG5iFLISt5SWG
# fHOezYiNSyp6nQ9Zeb3y2jZ+Zqwu+LuIl8ltefKz1NXMGvRPi0WVdvKHlYCOKHm6
# /cVwr7waFAKQfCZbEYtd9brkEQLFgRxmaEveaM6dDIhhqraUI53gpDxGXQRR2z9Z
# C+fsvtLZEypH70sSEm7INc/uFjK20F+FuE/yfNgJKxJewMLvEzFwNnPc1ldU01dg
# nhwQlfDmqi8Qiht+yc2PzlBLHCWowBdkURULjM/XyV1KbEl0rlrxagZ1Pok3O5EC
# AwEAAaOCAZswggGXMA4GA1UdDwEB/wQEAwIHgDAWBgNVHSUBAf8EDDAKBggrBgEF
# BQcDCDAdBgNVHQ4EFgQUda8nP7jbmuxvHO7DamT2v4Q1sM4wTAYDVR0gBEUwQzBB
# BgkrBgEEAaAyAR4wNDAyBggrBgEFBQcCARYmaHR0cHM6Ly93d3cuZ2xvYmFsc2ln
# bi5jb20vcmVwb3NpdG9yeS8wCQYDVR0TBAIwADCBkAYIKwYBBQUHAQEEgYMwgYAw
# OQYIKwYBBQUHMAGGLWh0dHA6Ly9vY3NwLmdsb2JhbHNpZ24uY29tL2NhL2dzdHNh
# Y2FzaGEzODRnNDBDBggrBgEFBQcwAoY3aHR0cDovL3NlY3VyZS5nbG9iYWxzaWdu
# LmNvbS9jYWNlcnQvZ3N0c2FjYXNoYTM4NGc0LmNydDAfBgNVHSMEGDAWgBTqFsZp
# 5+PLV0U5M6TwQL7Qw71lljBBBgNVHR8EOjA4MDagNKAyhjBodHRwOi8vY3JsLmds
# b2JhbHNpZ24uY29tL2NhL2dzdHNhY2FzaGEzODRnNC5jcmwwDQYJKoZIhvcNAQEL
# BQADggIBADiTt301iTTqGtaqes6NhNvhNLd0pf/YXZQ2JY/SgH6hZbGbzzVRXdug
# S273IUAu7E9vFkByHHUbMAAXOY/IL6RxziQzJpDV5P85uWHvC8o58y1ejaD/TuFW
# ZB/UnHYEpERcPWKFcC/5TqT3hlbbekkmQy0Fm+LDibc6oS0nJxjGQ4vcQ6G2ci0/
# 2cY0igLTYjkp8H0o0KnDZIpGbbNDHHSL3bmmCyF7EacfXaLbjOBV02n6d9FdFLmW
# 7JFFGxtsfkJAJKTtQMZl+kGPSDGc47izF1eCecrMHsLQT08FDg1512ndlaFxXYqe
# 51rCT6gGDwiJe9tYyCV9/2i8KKJwnLsMtVPojgaxsoKBhxKpXndMk6sY+ERXWBHL
# 9pMVSTG3U1Ah2tX8YH/dMMWsUUQLZ6X61nc0rRIfKPuI2lGbRJredw7uMhJgVgyR
# nViPvJlX8r7NucNzJBnad6bk7PHeb+C8hB1vw/Hb4dVCUYZREkImPtPqE/QonK1N
# ereiuhRqP0BVWE6MZRyz9nXWf64PhIAvvoh4XCcfRxfCPeRpnsuunu8CaIg3EMJs
# JorIjGWQU02uXdq4RhDUkAqK//QoQIHgUsjyAWRIGIR4aiL6ypyqDh3FjnLDNiIZ
# 6/iUH7/CxQFW6aaA6gEdEzUH4rl0FP2aOJ4D0kn2TOuhvRwU0uOZMYIFSTCCBUUC
# AQEwXDBOMRUwEwYKCZImiZPyLGQBGRYFbG9jYWwxFDASBgoJkiaJk/IsZAEZFgRs
# dXppMR8wHQYDVQQDExZsdXppLmxvY2FsLUNIRExTMDE4LUNBAgoeAQ2QAAEAAAIh
# MA0GCWCGSAFlAwQCAQUAoEwwGQYJKoZIhvcNAQkDMQwGCisGAQQBgjcCAQQwLwYJ
# KoZIhvcNAQkEMSIEIMEI8GA2mcMqtrQZtgIdcuUIlWaE2hi1IjpAc77t5SI/MA0G
# CSqGSIb3DQEBAQUABIIBAG+SA4TphJbnvM/ZyYUBM/CyNjF0MnNrNrcYtlZIHeQO
# Uo9SnGw58fcekPkgJ+/9uF+bPF1S5vIovUTegCZhE0zri/cIKn33r3DTFlcG7x4b
# GESg7thTrTaLbB+h+rH1XYlgUPFb3NRlRPGVqx9HYXfUp0R4mrpYDc6misj6LYe6
# 9QDjg4mOWYKhRL86CGN+yPVw1VyIAqj47BGvpmGAM84ZkbUJ0cs0FVaS8AB6Ota4
# PuVh4O76+C1fOCIV241XxtUihmtIAlpBOIle/A5Wz6d10g6F9cUKJKfyVPlJ6vAi
# hsK937B56uNhrGzmUeUCtlDYhTbujvcJ5pP5XsgZkD+hggNwMIIDbAYJKoZIhvcN
# AQkGMYIDXTCCA1kCAQEwbzBbMQswCQYDVQQGEwJCRTEZMBcGA1UEChMQR2xvYmFs
# U2lnbiBudi1zYTExMC8GA1UEAxMoR2xvYmFsU2lnbiBUaW1lc3RhbXBpbmcgQ0Eg
# LSBTSEEzODQgLSBHNAIQAYTTqM43getX9P2He4OusjANBglghkgBZQMEAgEFAKCC
# AT8wGAYJKoZIhvcNAQkDMQsGCSqGSIb3DQEHATAcBgkqhkiG9w0BCQUxDxcNMjEx
# MTMwMTIxMjE0WjAtBgkqhkiG9w0BCTQxIDAeMA0GCWCGSAFlAwQCAQUAoQ0GCSqG
# SIb3DQEBCwUAMC8GCSqGSIb3DQEJBDEiBCBgCUG0pS5OgfWMW6fE4ZUmtce5znfD
# NuNc6FW9vrJt2TCBpAYLKoZIhvcNAQkQAgwxgZQwgZEwgY4wgYsEFN1XtbOHPIYb
# KcauxHMa++iNdcFJMHMwX6RdMFsxCzAJBgNVBAYTAkJFMRkwFwYDVQQKExBHbG9i
# YWxTaWduIG52LXNhMTEwLwYDVQQDEyhHbG9iYWxTaWduIFRpbWVzdGFtcGluZyBD
# QSAtIFNIQTM4NCAtIEc0AhABhNOozjeB61f0/Yd7g66yMA0GCSqGSIb3DQEBCwUA
# BIIBgHkC7UvZ10n+adIVJccip573sgOTts9trfmpoc4+uO0UoK6bJPS6cCzCLf1j
# zO0agEUNv/+o87yaAyBcmHWLqbDkrYqgsDmUNOBIm6etg0HNvC0SQjhRmXb9nr+u
# wHqyzl3QuzAU069dTeAP4oihLmsO0x06QAj06VZuNc5K6SYKikWl5JYINcl+6tFd
# GPSRobOwpskRQOVbxjGmzqFkxnCAYDqqvgDk6C90wmN8qGeQ3uPTECpfi/NnMzFP
# Wb+avI1pizAWEO69/km9FQm3cZxmRNhLRpY9FluLYqWRgDxoI6ZuN2c0v7dIC+7P
# tD6N13CzEoeh4AXTVnJ0/VCEDj4x59a9CO/zfZY7sm2aG2GboUOBgC6lkeTY7HZZ
# XPjG4JyRq8jxr1mPPqD1V9nb76eIQ/I8H9MOWktf8xGLnATiH9vUquzlJUHUa0SH
# WJq8++MLkU/UWPUYbySF+xCCn2xRL0GXzpD8vgven/0DEFZi1pv7fjzIyapVrSdA
# AcD2Dw==
# SIG # End signature block
