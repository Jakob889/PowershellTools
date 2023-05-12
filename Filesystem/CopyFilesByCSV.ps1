#Set Locations
$SourcePDFLocation = "C:\source\"
$DestinationPDFLocation = "C:\destination\"
$CSVPath = "C:\temp\pdf_locations.csv"
$LogFileLocation = "C:\temp"


<# CSV example:
name,filelocation
pdf1.pdf,test1\undertest1_1\
pdf2.pdf,test1\undertest1_1\
pdf3.pdf,test2\
pdf4.pdf,test1\undertest1_2\
#>

#Script creates a Log file in the Script directory
$LogFilePath = "$LogFileLocation\Logfile_$(Get-Date -Format 'yyyyMMdd_HHmmss').txt"
New-Item -ItemType File -Path "$LogFilePath"

# CSV-Datei mit Dateipfaden laden
$filePaths = Import-Csv -Path $CSVPath


foreach($filePath in $filePaths) {
    $PDFfilePath =$SourcePDFLocation+($filePath.filelocation+$filePath.name)

    # Wenn die Quelldatei vorhanden ist, kopieren Sie sie in den Zielordner
    if(Test-Path -Path $PDFfilePath -PathType Leaf) 
    {
        # Zielordner festlegen
        $destinationFolder = Join-Path -Path $DestinationPDFLocation -ChildPath (Split-Path -Path $filePath.filelocation -NoQualifier)

        # Wenn der Zielordner nicht vorhanden ist, erstellen Sie ihn
        if(!(Test-Path -Path $destinationFolder -PathType Container)) 
        {
            New-Item -Path $destinationFolder -ItemType Directory
        }

        # Wenn die Datei im Zielordner nicht vorhanden ist, kopieren Sie sie
        $destinationPath = Join-Path -Path $destinationFolder -ChildPath $filePath.name
        if(!(Test-Path -Path $destinationPath -PathType Leaf)) 
        {
            try 
            {
                # Datei in den Zielordner kopieren
                Copy-Item -Path $PDFfilePath -Destination $destinationFolder -ErrorAction Stop
            
                $logEntry = "Done,{0},{1} to {2}" -f (Get-Date -Format "yyyy-MM-dd HH:mm:ss"),$PDFfilePath,$destinationFolder
                Write-Output $logEntry | Out-File $LogFilePath -Append
            }
            catch 
            {
                $logEntry = "Error,{0},Fehler beim Kopieren der Datei {1} : {2}" -f (Get-Date -Format "yyyy-MM-dd HH:mm:ss"),$PDFfilePath,$_
                Write-Warning $logEntry | Out-File $LogFilePath -Append
            }
        }
        else 
        {
            $logEntry = "Skipped,{0},Die Datei {1} wurde nicht kopiert, da sie bereits im Zielordner vorhanden ist." -f (Get-Date -Format "yyyy-MM-dd HH:mm:ss"),$PDFfilePath
            Write-Output $logEntry | Out-File $LogFilePath -Append
        }
    }
    else 
    {
        $logEntry = "Error,{0},Die Datei {1} konnte nicht gefunden werden." -f (Get-Date -Format "yyyy-MM-dd HH:mm:ss"),$PDFfilePath
        Write-Warning $logEntry | Out-File $LogFilePath -Append
    }
}