
##############################
# Ce script lance l'AUDIT AD #
##############################


#Déclaration variables nécessaires pour le script 
Import-Module DSInternals

#Déclaration des DC, remplacer ces variables par les informations de votre DC 
$DC = "SUPERAD.demo.local"
$Domain = "DC=demo,DC=local"


# Accès aux variables globales


#Declaration variable fichier log
$logs = Join-Path $PSScriptRoot "logs-audit-passwd-ad.txt"

#Declaration vers un fichier tmp contenant le resultat de l'audit.
$cheminFichier = Join-Path $PSScriptRoot ("Audit-results.txt")

#Declaration vers un fichier wordlist contenant la wordlist utilisée pour l'audit.
$cheminWordlist = Join-Path $PSScriptRoot ("wordlist.txt")

#TEST Ping vers l'AD déclaré
$testping = $DC

$Ping = Test-Connection -ComputerName $testping -Count 3 -ErrorAction SilentlyContinue
   if($Ping) {
       #Write-Host "$testping est en ligne" -ForegroundColor Green 
       $pingok = "Script 2 - Le ping vers le DC est OK !"
        $pingok | Out-File -FilePath $logs -Append 
   }else {
       Write-Host "$testping est hors ligne" -ForegroundColor Red
       $pingko = "Script 2 - Le ping vers le DC est KO arret du script"
       $pingko | Out-File -FilePath $logs -Append 
       exit 1
   } 


# Vérifier si le module DSInternals est présent
if (Get-Module -ListAvailable -Name DSInternals) {
    try {
        # Log de début de l'audit
        $loglunch = "Script 2 - Lancement de l'Audit en cours"
        $loglunch | Out-File -FilePath $logs -Append  

        # Exécution de l'audit et sauvegarde dans le fichier Audit-results.txt 
        $audit = Get-ADReplAccount -All -Server $global:DC | Test-PasswordQuality -WeakPasswordsFile $cheminWordlist
        $audit | Out-File $cheminFichier

        # Log de succès
        $logstop = "Script 2 - Succès de l'audit. Les résultats de l'audit ont été sauvegardés dans le fichier tmp Audit-results.txt"
        $logstop | Out-File -FilePath $logs -Append  
    } catch {
        # En cas d'erreur (par exemple si les droits de réplication AD sont insuffisants)
        $logerror = "Script 2 - Erreur lors de l'exécution de l'audit : $_"
        $logerror | Out-File -FilePath $logs -Append  
        Write-Host "Erreur lors de l'exécution de l'audit : $_" -ForegroundColor Red
        exit 1
    }
} else {
    # Si le module DSInternals n'est pas installé
    $logfail = "Script 2 - Le module DSInternals n'est pas installé. Veuillez l'installer pour exécuter l'audit."
    $logfail | Out-File -FilePath $logs -Append  
    Write-Host "Le module DSInternals n'est pas installé. Veuillez l'installer pour exécuter l'audit." -ForegroundColor Red
    exit 1
}



#Si vous voulez inclure les comptes désactives de l'AD dans l'audit : 
#Get-ADReplAccount  -All  -Server $DC | `Test-PasswordQuality -WeakPasswordsFile wordlist.txt  -IncludeDisabledAccounts