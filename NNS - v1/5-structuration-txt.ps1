####################################################################################################
### Ce script sera utile pour generer le rapport final d'audit HTML                              ### 
####################################################################################################

#Module necessaire pour recuperer les informations AD sur les comptes détectés dans l'audit.
Import-Module ActiveDirectory


# Définir le format de date
$date = Get-Date -Format "yyyy-MM-dd"

# Récupérer le répertoire du script
$scriptDirectory = $PSScriptRoot

#Declaration variable fichier log
$logs = Join-Path $PSScriptRoot "logs-audit-passwd-ad.txt"

$structure = "Script 5 - Structuration en cours du rapport final"
$structure | Out-File -FilePath $logs -Append

##############################################################
#première Carte : Find in wordlist

# Définir les séparateurs
$br = "####################################################################################################"
$espace = "`r`n"

# Construire le chemin du rapport d'audit avec la date
$rapportaudit = Join-Path $PSScriptRoot ("Rapport-Audit-AD-" + $date + ".txt")

# Définir le chemin du fichier source
$sourceTextFile2 = Join-Path $PSScriptRoot ("/temp/password-dictionary-temp.txt")

# Lire le contenu du fichier texte
$content2 = Get-Content $sourceTextFile2
$nbdeligne = $content2.Count

# Définir les données initiales
$data = @(
   
    "`r`n",
    "alpha",
    "$nbdeligne",
    "elephant"
    
    ""
)

# Écrire les données initiales dans le fichier rapport d'audit
$data | Out-File -FilePath $rapportaudit -Append

# Ajouter un entête de tableau
$tableHeader = "Compte                         | SamAccountName                 | Compte Actif    | Last Logon                     | Adresse mail			      | Description"
$tableDivider = "─" * 200
$tableContent = @($tableHeader, $tableDivider)

# Créer un tableau à partir du contenu du fichier texte
$table = $content2 | ForEach-Object {
    $line = $_
    # Récupérer les informations de l'utilisateur depuis Active Directory
    $accountInfo = Get-ADUser -Filter {SamAccountName -eq $line} -Properties SamAccountName, LastLogonDate, Enabled, EmailAddress, Description |
                  Select-Object Name, SamAccountName, LastLogonDate, Enabled, EmailAddress, Description

    # Vérifier si Last Login est négatif
        if ($accountInfo.LastLogonDate -eq $null) {
            $lastLoginText = "Aucune connexion"
        } else {
            $lastLoginText = $accountInfo.LastLogonDate
        }

        # Vérifier si l'adresse mail est vide
        if ($accountInfo.EmailAddress -eq $null) {
            $adresseMail = "Aucune adresse mail"
        } else {
            $adresseMail = $accountInfo.EmailAddress
        }

        # Vérifier si la description est vide
        if ($accountInfo.Description -eq $null) {
            $descriptionText = "Aucune description"
        } else {
            $descriptionText = $accountInfo.Description
        }

    # Formatage des informations de compte
    $accountObject = "{0,-30} | {1,-30} | {2,-15} | {3,-30} | {4,-40} | {5}" -f $accountInfo.Name, $accountInfo.SamAccountName, $accountInfo.Enabled, $lastLoginText, $adresseMail, $descriptionText
    $accountObject
}

# Ajouter le tableau au fichier rapport d'audit
$tableContent += $table
$tableContent | Out-File -FilePath $rapportaudit -Append

$wordlistok = "Script 5 - Succès dans l'ajout de la partie wordlist"
$wordlistok | Out-File -FilePath $logs -Append


##############################################################
#troisième carte "Never expire"

# Définir le chemin du fichier source
$sourceTextFile3 = Join-Path $PSScriptRoot "temp/neverexpire-temp.txt"

# Lire le contenu du fichier texte
$content3 = Get-Content $sourceTextFile3

# Filtrer les lignes commençant par "adm" en utilisant une expression régulière
$admAccounts = $content3 -match '^adm.*'

# Filtrer les lignes contenant "-t suivi d'un chiffre" dans le nom
$tieringAccounts = $content3 -match '-t\d'

# Compter le nombre de lignes correspondantes
$nbAdmAccounts = $admAccounts.Count
$nbTieringAccounts = $tieringAccounts.Count

#Write-Host $tieringAccounts
#Write-Host $admAccounts

$totalAccountCritiqueNeverExpire = $nbAdmAccounts + $nbTieringAccounts
$nbdeligneaccountneverexpire = $content3.Count



# Contenu du rapport
$data2 = @(
   
    @"
`r`n
bravo
 $totalAccountCritiqueNeverExpire
biberon
$nbdeligneaccountneverexpire
bravo3

bravo4

`r`n
"@
)

# Ajouter un entête de tableau pour les informations AD
$tableHeaderAD = "Compte                         | Last Logon                     | Compte Actif    | Adresse Mail"
$tableDividerAD = "─" * 125
$tableContentAD = @($tableHeaderAD, $tableDividerAD)

# Récupérer les informations de chaque compte critique depuis Active Directory
foreach ($account in ($admAccounts + $tieringAccounts)) { ################### ->  nbtierring account ne fonctione pas 
    $accountInfo = Get-ADUser -Filter { SamAccountName -eq $account } -Properties LastLogonDate, Enabled, EmailAddress |
                   Select-Object Name, LastLogonDate, Enabled, EmailAddress

    # Vérifier si Last Login est négatif
    if ($accountInfo.LastLogonDate -eq $null) {
        $lastLoginText = "Aucune connexion"
    } else {
        $lastLoginText = $accountInfo.LastLogonDate
    }

    # Formatage des informations de compte
    $accountObject = "{0,-30} | {1,-30} | {2,-15} | {3}" -f $accountInfo.Name, $lastLoginText, $accountInfo.Enabled, $accountInfo.EmailAddress
    $tableContentAD += $accountObject
}

# Ajouter le tableau des informations AD au rapport d'audit
$data2 += "`r`n" + ($tableContentAD -join "`r`n")

# Écrire le contenu dans le fichier rapport d'audit
$data2 | Out-File -FilePath $rapportaudit -Append

$expireok = "Script 5 - Succès dans l'ajout de la partie compte n'expire jamais"
$expireok | Out-File -FilePath $logs -Append


##############################################################
#deuxieme carte "Same password"

# Chemin vers le fichier texte
$textFilePath = Join-Path $PSScriptRoot "temp\same-passwords-temp.txt"


# Lire le contenu du fichier texte
$fileContent = Get-Content -Path $textFilePath

# Initialiser les variables
$currentGroup = ""
$groups = @{}
$tableContentAD = @()

# Parcourir chaque ligne du fichier texte
foreach ($line in $fileContent) {
    if ($line -match "Group (\d+):") {
        # Extraire le nom du groupe
        $currentGroup = "Group $($matches[1]):"
        # Initialiser un nouveau tableau pour ce groupe
        $groups[$currentGroup] = @()
    } elseif ($currentGroup -ne "") {
        # Ajouter le pseudo au tableau du groupe actuel
        $groups[$currentGroup] += $line.Trim()
    }
}

# Trier les groupes par leur numéro
$sortedGroups = $groups.Keys | Sort-Object {[int]($_ -replace '\D', '')}

# Initialiser le contenu du rapport avec du texte d'introduction
$data2 = @(
   
    "`r`n",
    "charlie",
    "`r`n",
     "Tableau sous la forme : Nom | SamAccountName | Date de dernière connexion | Compate actif | Adresse mail | Description AD du compte",
    
    ""
)

# Fonction pour ajouter des bordures verticales à chaque champ
function Format-TableCell {
    param (
        [string]$content
    )
    return "│ {0,-30} │" -f $content
}

foreach ($group in $sortedGroups) {
    $data2 += "`r`n$group`r`n"
    $tableContentAD = @()

    foreach ($account in $groups[$group]) {
        $accountInfo = Get-ADUser -Filter { SamAccountName -eq $account } -Properties SamAccountName, LastLogonDate, Enabled, EmailAddress, Description |
                       Select-Object Name, LastLogonDate, Enabled, EmailAddress, Description, SamAccountName

        # Vérifier si Last Login est négatif
        if ($accountInfo.LastLogonDate -eq $null) {
            $lastLoginText = "Aucune connexion"
        } else {
            $lastLoginText = $accountInfo.LastLogonDate
        }

        # Vérifier si l'adresse mail est vide
        if ($accountInfo.EmailAddress -eq $null) {
            $adresseMail = "Aucune adresse mail"
        } else {
            $adresseMail = $accountInfo.EmailAddress
        }

        # Vérifier si la description est vide
        if ($accountInfo.Description -eq $null) {
            $descriptionText = "Aucune description"
        } else {
            $descriptionText = $accountInfo.Description
        }

        # Formatage des informations de compte avec bordures verticales
        $name = Format-TableCell -content $accountInfo.Name
        $lastLogon = Format-TableCell -content $lastLoginText
        $enabled = Format-TableCell -content $accountInfo.Enabled
        $email = Format-TableCell -content $adresseMail
        $description = Format-TableCell -content $descriptionText
        $samaccountname = Format-TableCell -content $accountInfo.SamAccountName

        # Ajouter les informations formatées au tableau du groupe
        $tableContentAD += "$name $samaccountname $lastLogon $enabled $email $description  "
    }

    # Ajouter le tableau des informations AD au rapport d'audit avec des bordures
    $data2 += "╭───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────╮`r`n"
    $data2 += ($tableContentAD -join "`r`n")
    $data2 += "`r`n╰───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────╯`r`n"
}

# Écrire le contenu dans le fichier rapport d'audit
$data2 | Out-File -FilePath $rapportAudit -Append

$samepassword = "Script 5 - Succès dans l'ajout de la partie same password"
$samepassword | Out-File -FilePath $logs -Append



#############################################################################################
#Ajout d'un mot dans le fichier txt, indispensable pour le rapport final.

# Définir les données initiales
$data = @(
   
    "`r`n",
    "monstrueux",
    
    ""
)

#############################################################################################

# Écrire les données initiales dans le fichier rapport d'audit
$data | Out-File -FilePath $rapportaudit -Append

$wordlistok = "Script 5 - Succès dans l'ajout de la partie wordlist"
$wordlistok | Out-File -FilePath $logs -Append

# Afficher un message pour debug
#Write-Host "Rapport d'audit généré avec succès : $rapportAudit"