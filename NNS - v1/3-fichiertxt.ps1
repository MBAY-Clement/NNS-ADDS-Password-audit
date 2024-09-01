#########################################################################
# Ce script permet de créer un txt qui sera utile pour le rapport final #
#########################################################################

#Declaration variable fichier log
$logs = Join-Path $PSScriptRoot "logs-audit-passwd-ad.txt"

# Récupère la date actuelle au format yyyy-MM-dd
$date = Get-Date -Format "yyyy-MM-dd"

# Construit le chemin complet du fichier avec la date incluse dans le nom
$rapportaudit = Join-Path $PSScriptRoot ("Rapport-Audit-AD-" + $date + ".txt")
New-Item -ItemType File -Path $rapportaudit | Out-Null

if (Test-Path -Path $rapportaudit) {

    $espace = "`r`n"
    $br = "###########################################################################"
    $start = "### NNS - AUDIT PASSWD ACTIVE DIRECTORY LANCEE LE $date ####"

    $br, $start, $br | Out-File -FilePath $rapportaudit -Append
 

    $resultats = "###### Résultat de l'AUDIT ######"
    $espace, $resultats | Out-File -FilePath $rapportaudit -Append

    $fileok = "Script 3 - Succès dans la création du fichier $rapportaudit qui servira pour le rapport"
    $fileok | Out-File -FilePath $logs -Append  
}

else {
    $fileok = "Script 3 - Le fichier .txt ne c'est pas créé. Arret du script 3 et du programme main"
    $fileok | Out-File -FilePath $logs -Append  

    exit 1
}
