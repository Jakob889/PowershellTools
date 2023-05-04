Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Security

# Auslesen der Java-Version
try
{
    $javaVersion = & 'java' -version 2>&1 | Select-String 'version' | % { $_.ToString().Split('"')[1] } -ErrorAction Stop
}
catch
{
    Write-Output "Could not find Java"
    exit 1
}

$jdkVersion = 'jdk-'+$javaVersion
$jreVersion = 'jre-'+$javaVersion

$keytool = "C:\Program Files\Java\$jreVersion\bin\keytool.exe"
$destLocation_tomcatKeystore = "C:\Program Files\Java\$jdkVersion\bin\"
$destLocation_JDK = "C:\Program Files\Java\$jdkVersion\lib\security\"
$destLocation_JRE = "C:\Program Files\Java\$jreVersion\lib\security\"
$destLocation_tomcatKeystore_File = $destLocation_tomcatKeystore+'tomcat.keystore'

#POPUP FOR CERTIFICATE
$openFileDialog = New-Object System.Windows.Forms.OpenFileDialog
$openFileDialog.InitialDirectory = "\\muster.local\muster\Zertifikate"
$openFileDialog.Filter = "Certificate File (*.pfx;*.cer)|*.pfx;*.cer|Alle Dateien (*.*)|*.*"
$openFileDialog.Multiselect = $false
$openFileDialog.Title = "Select a certificate file"
$result = $openFileDialog.ShowDialog()

if ($result -ne [System.Windows.Forms.DialogResult]::OK) {
    Write-Output "No file selected."
    exit
}

$certificateFile = $openFileDialog.FileName
$password = Read-Host -AsSecureString "Enter password for certificate file $certificateFile"

$certificate = $null
while ($certificate -eq $null) {
    try {
        $certificate = New-Object System.Security.Cryptography.X509Certificates.X509Certificate2($certificateFile, $password)
    }
    catch {
        Write-Output "Password is incorrect for the selected certificate. Please try again."

        $message = "Password is incorrect for the selected certificate. Please try again or cancel."
        $caption = "Password is incorrect"
        $buttonType = [System.Windows.Forms.MessageBoxButtons]::OKCancel

        $result = [System.Windows.Forms.MessageBox]::Show($message, $caption, $buttonType)

        if ($result -eq [System.Windows.Forms.DialogResult]::OK) {
            Write-Output "Pressed OK."
            $password = Read-Host -AsSecureString "Enter password for certificate file $certificateFile"
        } else {
            Write-Output "Canceled"
            Exit.
        }


    }
}

# Erstellen des Keystores (wenn er noch nicht vorhanden ist)

#Keystore file test tomcat.keystore
if (!(Test-Path $destLocation_tomcatKeystore_File)) {
    Write-Output "tomcat.keystore File not exist"
    $openFileDialog = New-Object System.Windows.Forms.OpenFileDialog
    $openFileDialog.InitialDirectory = "C:\Program Files\Java\"
    $openFileDialog.Filter = "Keystore File (*.keystore)|*.keystore|Alle Dateien (*.*)|*.*"
    $openFileDialog.Multiselect = $false
    $openFileDialog.Title = "Keystore File could not be fund, Select a keystore file"
    $result = $openFileDialog.ShowDialog()

    if ($result -ne [System.Windows.Forms.DialogResult]::OK) {
        Write-Output "No file selected."
        exit
    }

    $destLocation_tomcatKeystore_File = $openFileDialog.FileName
}

#Keytool exe test keystore
if (!(Test-Path $keytool)) {
    Write-Output "Keytool.exe File not exist"
    $openFileDialog = New-Object System.Windows.Forms.OpenFileDialog
    $openFileDialog.InitialDirectory = "C:\Program Files\Java\"
    $openFileDialog.Filter = "Keytool.exe (*.exe)|*.exe|Alle Dateien (*.*)|*.*"
    $openFileDialog.Multiselect = $false
    $openFileDialog.Title = "Keytool.exe could not be fund, Select a Keytool.exe"
    $result = $openFileDialog.ShowDialog()

    if ($result -ne [System.Windows.Forms.DialogResult]::OK) {
        Write-Output "No file selected."
        exit
    }

    $keytool = $openFileDialog.FileName
}

 
try
{
    $params = @(
    "-importkeystore",
    "-srckeystore", $certificateFile,
    "-srcstoretype", "pkcs12",
    "-srcstorepass", $password,
    "-destkeystore", $destLocation_tomcatKeystore_File,
    "-deststoretype", "keystore",
    "-deststorepass", $password,
    "-noprompt"
    )

    & $keytool @params -ErrorAction Stop

}
catch
{
    Write-Output "Could not create Key"
    Write-Error $_.Exception.Message
}

# test $keytool -list -keystore $destLocation_tomcatKeystore_File -storepass $pfxPassword