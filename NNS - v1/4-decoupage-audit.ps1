#######################################################################################################
### Ce script permet la suppresion de tous les DEMO\ du rapport d'audit  généré (etape2)       ###
### et decoupe des sections du rapport txt en plusieurs petites sections pour faciliter la lecture  ###
#######################################################################################################


# Fichier txt de l'audit entiere créé lors du lancement du script 2
$scriptDirectory = $PSScriptRoot
$cheminFichier = Join-Path $PSScriptRoot ("Audit-results.txt")

#Declaration variable fichier log
$logs = Join-Path $PSScriptRoot "logs-audit-passwd-ad.txt"

# Chemin vers le fichier texte source (audit)
$sourceTextFile = $cheminFichier

# Lire le contenu du fichier texte
$content = Get-Content $sourceTextFile

# Créer un tableau à partir du contenu du fichier texte
$table = $content | ForEach-Object { [PSCustomObject]@{ Texte = $_ } }


# Lisez le contenu du fichier dans un tableau de lignes
$contenu = Get-Content -Path $cheminFichier

# Créez un tableau pour stocker les lignes modifiées
$data = @()

# Parcourez chaque ligne du fichier et supprimez "  SUPERAD\" (avec deux espaces) #Remplacez SUPERAD\ par votre domaine attention bien laissez les 2 escpaces.
$contenu | ForEach-Object {
    $ligneModifiee = $_ -replace [regex]::Escape("  SUPERAD\"), ""
    $data += $ligneModifiee
}

# Écrivez les lignes modifiées dans le fichier
$data | Set-Content -Path $cheminFichier -Encoding UTF8

# Confirmez que la modification a été effectuée
Write-Host "Modification effectuée avec succès."



##############################################################

# Liste des noms de fichiers .txt , fichier temp normalement supprimer a la fin du script mais double verification necessaire.
$fichiersASupprimer = @(
    "password-reversible-temp.txt",
    "LM-hashes-temp.txt",
    "no-password-temp.txt",
    "password-dictionary-temp.txt",
    "same-passwords-temp.txt",
    "computer-accounts-temp.txt",
    "kerberos-aes-temp.txt",
    "kerberos-pre-auth-temp.txt",
    "des-encryption-temp.txt",
    "kerberoasting-attack-temp.txt",
    "delegated-service-temp.txt",
    "neverexpire-temp.txt",
    "not-required-password-temp.txt"
)

# Répertoire où se trouvent les fichiers
$repertoire = "$PSScriptRoot/temp"

# Parcourez la liste des fichiers à supprimer et vérifiez s'ils existent, puis suppresion
foreach ($fichier in $fichiersASupprimer) {
    $cheminComplet = Join-Path -Path $repertoire -ChildPath $fichier
    if (Test-Path $cheminComplet) {
        Remove-Item $cheminComplet
        #"Le fichier $cheminComplet a été supprimé." | Out-File -FilePath $logs -Append
    }
    else {
        #Write-Host "Le fichier $cheminComplet n'existe pas dans le répertoire."
        #$fileko = "Script 4 - Le fichier $cheminComplet n'existe pas dans le répertoire temp."
        #$fileko | Out-File -FilePath $logs -Append
        
        
    }
}



##############################################################
#Découpage des parties du rapport d'audit - 1 : Passwords of these accounts are stored using reversible encryption:

$filePath1 = $cheminFichier
$filePath2 = Join-Path $PSScriptRoot "temp\password-reversible-temp.txt"


 # Spécifiez le chemin complet vers votre fichier texte
$cheminFichier = $filePath1

# Spécifiez le chemin du fichier de sortie
$cheminSortie = $filePath2

# Lisez le contenu du fichier dans un tableau de lignes
$contenu = Get-Content -Path $cheminFichier

# Définissez des drapeaux pour indiquer le début et la fin de la section souhaitée
$sectionEnCours = $false

# Créez un tableau pour stocker les lignes de la section
$sectionLignes = @()

# Parcourez chaque ligne du fichier
foreach ($ligne in $contenu) {
    if ($ligne -match "Passwords of these accounts are stored using reversible encryption:") {
        $sectionEnCours = $true
    }
    elseif ($sectionEnCours -eq $true) {
        if ($ligne -match "LM hashes of passwords of these accounts are present:") {
            $sectionEnCours = $false
        }
        else {
            # Assurez-vous que la ligne n'est pas vide avant de l'ajouter au tableau de lignes de la section
            if ($ligne -ne "" -and $ligne -match '\S') {
                $sectionLignes += $ligne
            }
        }
    }
}

# Écrivez les lignes de la section dans le fichier de sortie
$sectionLignes | Out-File -FilePath $cheminSortie -Append

##############################################################
#Découpage des parties du rapport d'audit - 2 : LM hashes of passwords of these accounts are present:



$filePath2 = Join-Path $PSScriptRoot "temp\LM-hashes-temp.txt"


 # Spécifiez le chemin complet vers votre fichier texte
$cheminFichier = $filePath1

# Spécifiez le chemin du fichier de sortie
$cheminSortie = $filePath2

# Lisez le contenu du fichier dans un tableau de lignes
$contenu = Get-Content -Path $cheminFichier

# Définissez des drapeaux pour indiquer le début et la fin de la section souhaitée
$sectionEnCours = $false

# Créez un tableau pour stocker les lignes de la section
$sectionLignes = @()

# Parcourez chaque ligne du fichier
foreach ($ligne in $contenu) {
    if ($ligne -match "LM hashes of passwords of these accounts are present:") {
        $sectionEnCours = $true
    }
    elseif ($sectionEnCours -eq $true) {
        if ($ligne -match "These accounts have no password set:") {
            $sectionEnCours = $false
        }
        else {
            # Assurez-vous que la ligne n'est pas vide avant de l'ajouter au tableau de lignes de la section
            if ($ligne -ne "" -and $ligne -match '\S') {
                $sectionLignes += $ligne
            }
        }
    }
}

# Écrivez les lignes de la section dans le fichier de sortie
$sectionLignes | Out-File -FilePath $cheminSortie -Append

##############################################################
#Découpage des parties du rapport d'audit - 3 : These accounts have no password set:


$filePath2 = Join-Path $PSScriptRoot "temp\no-password-temp.txt"


 # Spécifiez le chemin complet vers votre fichier texte
$cheminFichier = $filePath1

# Spécifiez le chemin du fichier de sortie
$cheminSortie = $filePath2

# Lisez le contenu du fichier dans un tableau de lignes
$contenu = Get-Content -Path $cheminFichier

# Définissez des drapeaux pour indiquer le début et la fin de la section souhaitée
$sectionEnCours = $false

# Créez un tableau pour stocker les lignes de la section
$sectionLignes = @()

# Parcourez chaque ligne du fichier
foreach ($ligne in $contenu) {
    if ($ligne -match "These accounts have no password set:") {
        $sectionEnCours = $true
    }
    elseif ($sectionEnCours -eq $true) {
        if ($ligne -match "Passwords of these accounts have been found in the dictionary:") {
            $sectionEnCours = $false
        }
        else {
            # Assurez-vous que la ligne n'est pas vide avant de l'ajouter au tableau de lignes de la section
            if ($ligne -ne "" -and $ligne -match '\S') {
                $sectionLignes += $ligne
            }
        }
    }
}

# Écrivez les lignes de la section dans le fichier de sortie
$sectionLignes | Out-File -FilePath $cheminSortie -Append


##############################################################
#Découpage des parties du rapport d'audit - 4 : Passwords of these accounts have been found in the dictionary:


$filePath2 = Join-Path $PSScriptRoot "temp\password-dictionary-temp.txt"


 # Spécifiez le chemin complet vers votre fichier texte
$cheminFichier = $filePath1

# Spécifiez le chemin du fichier de sortie
$cheminSortie = $filePath2

# Lisez le contenu du fichier dans un tableau de lignes
$contenu = Get-Content -Path $cheminFichier

# Définissez des drapeaux pour indiquer le début et la fin de la section souhaitée
$sectionEnCours = $false

# Créez un tableau pour stocker les lignes de la section
$sectionLignes = @()

# Parcourez chaque ligne du fichier
foreach ($ligne in $contenu) {
    if ($ligne -match "Passwords of these accounts have been found in the dictionary:") {
        $sectionEnCours = $true
    }
    elseif ($sectionEnCours -eq $true) {
        if ($ligne -match "These groups of accounts have the same passwords:") {
            $sectionEnCours = $false
        }
        else {
            # Assurez-vous que la ligne n'est pas vide avant de l'ajouter au tableau de lignes de la section
            if ($ligne -ne "" -and $ligne -match '\S') {
                $sectionLignes += $ligne
            }
        }
    }
}


# Écrivez les lignes de la section dans le fichier de sortie
$sectionLignes | Out-File -FilePath $cheminSortie 

##############################################################
#Découpage des parties du rapport d'audit - 5 : These groups of accounts have the same passwords:


$filePath2 = Join-Path $PSScriptRoot "temp\same-passwords-temp.txt"


 # Spécifiez le chemin complet vers votre fichier texte
$cheminFichier = $filePath1

# Spécifiez le chemin du fichier de sortie
$cheminSortie = $filePath2

# Lisez le contenu du fichier dans un tableau de lignes
$contenu = Get-Content -Path $cheminFichier

# Définissez des drapeaux pour indiquer le début et la fin de la section souhaitée
$sectionEnCours = $false

# Créez un tableau pour stocker les lignes de la section
$sectionLignes = @()

# Parcourez chaque ligne du fichier
foreach ($ligne in $contenu) {
    if ($ligne -match "These groups of accounts have the same passwords:") {
        $sectionEnCours = $true
    }
    elseif ($sectionEnCours -eq $true) {
        if ($ligne -match "These computer accounts have default passwords:") {
            $sectionEnCours = $false
        }
        else {
            # Assurez-vous que la ligne n'est pas vide avant de l'ajouter au tableau de lignes de la section
            if ($ligne -ne "" -and $ligne -match '\S') {
                $sectionLignes += $ligne
            }
        }
    }
}


# Écrivez les lignes de la section dans le fichier de sortie
$sectionLignes | Out-File -FilePath $cheminSortie -Append


##############################################################
#Découpage des parties du rapport d'audit - 5 : These computer accounts have default passwords:


$filePath2 = Join-Path $PSScriptRoot "temp\computer-accounts-temp.txt"


 # Spécifiez le chemin complet vers votre fichier texte
$cheminFichier = $filePath1

# Spécifiez le chemin du fichier de sortie
$cheminSortie = $filePath2

# Lisez le contenu du fichier dans un tableau de lignes
$contenu = Get-Content -Path $cheminFichier

# Définissez des drapeaux pour indiquer le début et la fin de la section souhaitée
$sectionEnCours = $false

# Créez un tableau pour stocker les lignes de la section
$sectionLignes = @()

# Parcourez chaque ligne du fichier
foreach ($ligne in $contenu) {
    if ($ligne -match "These computer accounts have default passwords:") {
        $sectionEnCours = $true
    }
    elseif ($sectionEnCours -eq $true) {
        if ($ligne -match "Kerberos AES keys are missing from these accounts:") {
            $sectionEnCours = $false
        }
        else {
            # Assurez-vous que la ligne n'est pas vide avant de l'ajouter au tableau de lignes de la section
            if ($ligne -ne "" -and $ligne -match '\S') {
                $sectionLignes += $ligne
            }
        }
    }
}

# Écrivez les lignes de la section dans le fichier de sortie
$sectionLignes | Out-File -FilePath $cheminSortie -Append

##############################################################
#Découpage des parties du rapport d'audit - 6 : Kerberos AES keys are missing from these accounts:


$filePath2 = Join-Path $PSScriptRoot "temp\kerberos-aes-temp.txt"


 # Spécifiez le chemin complet vers votre fichier texte
$cheminFichier = $filePath1

# Spécifiez le chemin du fichier de sortie
$cheminSortie = $filePath2

# Lisez le contenu du fichier dans un tableau de lignes
$contenu = Get-Content -Path $cheminFichier

# Définissez des drapeaux pour indiquer le début et la fin de la section souhaitée
$sectionEnCours = $false

# Créez un tableau pour stocker les lignes de la section
$sectionLignes = @()

# Parcourez chaque ligne du fichier
foreach ($ligne in $contenu) {
    if ($ligne -match "Kerberos AES keys are missing from these accounts:") {
        $sectionEnCours = $true
    }
    elseif ($sectionEnCours -eq $true) {
        if ($ligne -match "Kerberos pre-authentication is not required for these accounts:") {
            $sectionEnCours = $false
        }
        else {
            # Assurez-vous que la ligne n'est pas vide avant de l'ajouter au tableau de lignes de la section
            if ($ligne -ne "" -and $ligne -match '\S') {
                $sectionLignes += $ligne
            }
        }
    }
}

# Écrivez les lignes de la section dans le fichier de sortie
$sectionLignes | Out-File -FilePath $cheminSortie -Append

##############################################################
#Découpage des parties du rapport d'audit - 7 : Kerberos pre-authentication is not required for these accounts:

$filePath2 = Join-Path $PSScriptRoot "temp\kerberos-pre-auth-temp.txt"


 # Spécifiez le chemin complet vers votre fichier texte
$cheminFichier = $filePath1

# Spécifiez le chemin du fichier de sortie
$cheminSortie = $filePath2

# Lisez le contenu du fichier dans un tableau de lignes
$contenu = Get-Content -Path $cheminFichier

# Définissez des drapeaux pour indiquer le début et la fin de la section souhaitée
$sectionEnCours = $false

# Créez un tableau pour stocker les lignes de la section
$sectionLignes = @()

# Parcourez chaque ligne du fichier
foreach ($ligne in $contenu) {
    if ($ligne -match "Kerberos pre-authentication is not required for these accounts:") {
        $sectionEnCours = $true
    }
    elseif ($sectionEnCours -eq $true) {
        if ($ligne -match "Only DES encryption is allowed to be used with these accounts:") {
            $sectionEnCours = $false
        }
        else {
            # Assurez-vous que la ligne n'est pas vide avant de l'ajouter au tableau de lignes de la section
            if ($ligne -ne "" -and $ligne -match '\S') {
                $sectionLignes += $ligne
            }
        }
    }
}

# Écrivez les lignes de la section dans le fichier de sortie
$sectionLignes | Out-File -FilePath $cheminSortie -Append

##############################################################
#Découpage des parties du rapport d'audit - 8 : Only DES encryption is allowed to be used with these accounts:

$filePath2 = Join-Path $PSScriptRoot "temp\des-encryption-temp.txt"


 # Spécifiez le chemin complet vers votre fichier texte
$cheminFichier = $filePath1

# Spécifiez le chemin du fichier de sortie
$cheminSortie = $filePath2

# Lisez le contenu du fichier dans un tableau de lignes
$contenu = Get-Content -Path $cheminFichier

# Définissez des drapeaux pour indiquer le début et la fin de la section souhaitée
$sectionEnCours = $false

# Créez un tableau pour stocker les lignes de la section
$sectionLignes = @()

# Parcourez chaque ligne du fichier
foreach ($ligne in $contenu) {
    if ($ligne -match "Only DES encryption is allowed to be used with these accounts:") {
        $sectionEnCours = $true
    }
    elseif ($sectionEnCours -eq $true) {
        if ($ligne -match "These accounts are susceptible to the Kerberoasting attack:") {
            $sectionEnCours = $false
        }
        else {
            # Assurez-vous que la ligne n'est pas vide avant de l'ajouter au tableau de lignes de la section
            if ($ligne -ne "" -and $ligne -match '\S') {
                $sectionLignes += $ligne
            }
        }
    }
}

# Écrivez les lignes de la section dans le fichier de sortie
$sectionLignes | Out-File -FilePath $cheminSortie -Append

##############################################################
#Découpage des parties du rapport d'audit - 9 : These accounts are susceptible to the Kerberoasting attack:

$filePath2 = Join-Path $PSScriptRoot "temp\kerberoasting-attack-temp.txt"


 # Spécifiez le chemin complet vers votre fichier texte
$cheminFichier = $filePath1

# Spécifiez le chemin du fichier de sortie
$cheminSortie = $filePath2

# Lisez le contenu du fichier dans un tableau de lignes
$contenu = Get-Content -Path $cheminFichier

# Définissez des drapeaux pour indiquer le début et la fin de la section souhaitée
$sectionEnCours = $false

# Créez un tableau pour stocker les lignes de la section
$sectionLignes = @()

# Parcourez chaque ligne du fichier
foreach ($ligne in $contenu) {
    if ($ligne -match "These accounts are susceptible to the Kerberoasting attack:") {
        $sectionEnCours = $true
    }
    elseif ($sectionEnCours -eq $true) {
        if ($ligne -match "These administrative accounts are allowed to be delegated to a service:") {
            $sectionEnCours = $false
        }
        else {
            # Assurez-vous que la ligne n'est pas vide avant de l'ajouter au tableau de lignes de la section
            if ($ligne -ne "" -and $ligne -match '\S') {
                $sectionLignes += $ligne
            }
        }
    }
}

# Écrivez les lignes de la section dans le fichier de sortie
$sectionLignes | Out-File -FilePath $cheminSortie -Append

##############################################################
#Découpage des parties du rapport d'audit - 10 : These administrative accounts are allowed to be delegated to a service:

$filePath2 = Join-Path $PSScriptRoot "temp\delegated-service-temp.txt"


 # Spécifiez le chemin complet vers votre fichier texte
$cheminFichier = $filePath1

# Spécifiez le chemin du fichier de sortie
$cheminSortie = $filePath2

# Lisez le contenu du fichier dans un tableau de lignes
$contenu = Get-Content -Path $cheminFichier

# Définissez des drapeaux pour indiquer le début et la fin de la section souhaitée
$sectionEnCours = $false

# Créez un tableau pour stocker les lignes de la section
$sectionLignes = @()

# Parcourez chaque ligne du fichier
foreach ($ligne in $contenu) {
    if ($ligne -match "These administrative accounts are allowed to be delegated to a service:") {
        $sectionEnCours = $true
    }
    elseif ($sectionEnCours -eq $true) {
        if ($ligne -match "Passwords of these accounts will never expire:") {
            $sectionEnCours = $false
        }
        else {
            # Assurez-vous que la ligne n'est pas vide avant de l'ajouter au tableau de lignes de la section
            if ($ligne -ne "" -and $ligne -match '\S') {
                $sectionLignes += $ligne
            }
        }
    }
}

# Écrivez les lignes de la section dans le fichier de sortie
$sectionLignes | Out-File -FilePath $cheminSortie -Append

##############################################################
#Découpage des parties du rapport d'audit - 11 : Passwords of these accounts will never expire:

$filePath2 = Join-Path $PSScriptRoot "temp\neverexpire-temp.txt"


 # Spécifiez le chemin complet vers votre fichier texte
$cheminFichier = $filePath1

# Spécifiez le chemin du fichier de sortie
$cheminSortie = $filePath2

# Lisez le contenu du fichier dans un tableau de lignes
$contenu = Get-Content -Path $cheminFichier

# Définissez des drapeaux pour indiquer le début et la fin de la section souhaitée
$sectionEnCours = $false

# Créez un tableau pour stocker les lignes de la section
$sectionLignes = @()

# Parcourez chaque ligne du fichier
foreach ($ligne in $contenu) {
    if ($ligne -match "Passwords of these accounts will never expire:") {
        $sectionEnCours = $true
    }
    elseif ($sectionEnCours -eq $true) {
        if ($ligne -match "These accounts are not required to have a password:") {
            $sectionEnCours = $false
        }
        else {
            # Assurez-vous que la ligne n'est pas vide avant de l'ajouter au tableau de lignes de la section
            if ($ligne -ne "" -and $ligne -match '\S') {
                $sectionLignes += $ligne
            }
        }
    }
}

# Écrivez les lignes de la section dans le fichier de sortie
$sectionLignes | Out-File -FilePath $cheminSortie -Append

##############################################################
#Découpage des parties du rapport d'audit - 12 : These accounts are not required to have a password:

$filePath2 = Join-Path $PSScriptRoot "temp\not-required-password-temp.txt"


 # Spécifiez le chemin complet vers votre fichier texte
$cheminFichier = $filePath1

# Spécifiez le chemin du fichier de sortie
$cheminSortie = $filePath2

# Lisez le contenu du fichier dans un tableau de lignes
$contenu = Get-Content -Path $cheminFichier

# Définissez des drapeaux pour indiquer le début et la fin de la section souhaitée
$sectionEnCours = $false

# Créez un tableau pour stocker les lignes de la section
$sectionLignes = @()

# Parcourez chaque ligne du fichier
foreach ($ligne in $contenu) {
    if ($ligne -match "These accounts are not required to have a password:") {
        $sectionEnCours = $true
    }
    elseif ($sectionEnCours -eq $true) {
        if ($ligne -match "These accounts that require smart card authentication have a password:") {
            $sectionEnCours = $false
        }
        else {
            # Assurez-vous que la ligne n'est pas vide avant de l'ajouter au tableau de lignes de la section
            if ($ligne -ne "" -and $ligne -match '\S') {
                $sectionLignes += $ligne
            }
        }
    }
}

# Écrivez les lignes de la section dans le fichier de sortie
$sectionLignes | Out-File -FilePath $cheminSortie -Append


$decoupageok = "Script 4 - Succès dans le découpage en différente partie du fichier d'audit "
$decoupageok | Out-File -FilePath $logs -Append










