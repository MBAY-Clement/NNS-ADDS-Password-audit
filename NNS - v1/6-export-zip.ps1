############################################################################
# Ce script permet de créer un zip qui contiendra le rapport d'audit final #
############################################################################


# Obtenir la date au format yyyy-MM-dd
$date = Get-Date -Format "yyyy-MM-dd"

# Chemin du fichier .txt à compresser
$rapportaudittxt = Join-Path $PSScriptRoot ("RAP-" + $date + ".html")

#fichier log 
$logs = Join-Path $PSScriptRoot "logs-audit-passwd-ad.txt"


# Chemin du fichier .zip de destination
$fichierZip = Join-Path $PSScriptRoot ("Rapport-Audit-MDP-AD-" + $date +".zip")

# Le zip va se trouver dans le repertoire où est executé ce script
$outputPath = $PSScriptRoot

# Supprime le fichier .zip existant s'il existe
if (Test-Path $fichierZip) {
    Remove-Item $fichierZip
    
    $zipsupp = "Script 6 - Fichier zip existant supprimé : $fichierZip"
    $zipsupp | Out-File -FilePath $logs -Append 
}

# Vérifie si le fichier .txt existe
if (Test-Path $rapportaudittxt) {
    
    $zipencours = "Script 6 - Zip en cours du fichier $rapportaudittxt"
    $zipencours | Out-File -FilePath $logs -Append 

    # Convertir la chaîne en SecureString
    $securePassword = ConvertTo-SecureString -String "STRONGPASSWORD" -AsPlainText -Force  # Remplacez 'STRONGPASSWORD' par votre propre mot de passe (Malheureusement mot de passe en clair dans le script :( )
    
    # Compresser et protéger par mot de passe, le script se trouvera dans le repertoire courant.
    Compress-7Zip -Path $rapportaudittxt -ArchiveFileName $fichierZip -OutputPath $outputPath -Format Zip -SecurePassword $securePassword

    $zipok = "Script 6 - Compression et protection par mot de passe réussies : $fichierZip"
    $zipok | Out-File -FilePath $logs -Append 
    

} else {
    $zipko = "Script 6 - Le fichier $rapportaudittxt n'existe pas impossible de le chiffrer"
    $zipko | Out-File -FilePath $logs -Append 
    exit 1

}
