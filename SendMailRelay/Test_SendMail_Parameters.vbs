Dim objShell
Set objShell = WScript.CreateObject("WScript.Shell")

' Setze die Parameter für die PowerShell-Skriptausführung '
SMTP = "smtp.office365.com"
Port = "587"
vFrom = "noreply@muster.ch"
vTo = "hans.muster@muster.ch"
PW = "5KNXsdfuh89!dOPIDS"
Body = "TestVBS"
Subject = "TestVBS"
LogPath = "C:\SendMailRelay\Log.txt"

' Setze das Docs Array '
Set gobjLogfilesToAttach = CreateObject("Scripting.Dictionary")
gobjLogfilesToAttach.Add 0, "C:\temp\File1.txt"
gobjLogfilesToAttach.Add 1, "C:\temp\File2.docx"
gobjLogfilesToAttach.Add 2, "C:\temp\File3.pdf"

Dim logFilesArray
logFilesArray = gobjLogfilesToAttach.Items
	

' Führe das PowerShell-Skript aus '
cmdLine = "powershell.exe -ExecutionPolicy Bypass -Command ""& 'C:\SendMailRelay\SendMail_Relay.ps1' -SMTP '" & SMTP & "' -Port '" & Port & "' -From '" & vFrom & "' -To '" & vTo & "' -PW '" & PW & "' -Body '" & Body & "' -Subject '" & Subject & "' -LogPath '" & LogPath & "' -Docs '" & Join(logFilesArray, ",") & "'"""
objShell.Run cmdLine, 0, True

Set objShell = Nothing



