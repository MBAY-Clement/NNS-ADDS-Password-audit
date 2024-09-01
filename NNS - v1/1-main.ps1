########################################
###    NNS - AUDIT PASSWORD AD DS    ###
########################################


# Script "Main" seul script a lancer pour effectuer l'audit. Pensez à bien configurer les autres fichiers (voir documentation) avant de lancer ce script !

# Rappel de configuration : 
# Dans le fichier « 2-lancement-audit.ps1 », à la ligne 12 et 13, modifier les variables et ajoutez votre domaine AD à auditer
# Dans le fichier « 4-decoupage-audit.ps1 » ligne 33 rajouter votre domaine sous la forme : "  DOMAINE\" bien garder les 2 espaces avant la saisi du domaine.
# Dans le fichier « 6-export-zip.ps1 », à la ligne 32, nous vous invitons à entrer le mot de passe souhaité pour chiffrer le fichier .zip contenant le rapport d’audit final.

# Prérequis : 
# Autoriser le lancement de scripts non signés (vous êtes libre de les signer si vous le souhaitez).
# Il est obligatoire de lancer le script avec un compte AD disposant des droits de réplication et d'accès au NTDS de votre AD.
# Nous vous conseillons fortement d’ouvrir le rapport final (fichier .html) sur un ordinateur ayant accès à Internet (un rapport ne nécessitant pas d'accès à Internet sera prochainement créé).


$timer = [System.Diagnostics.Stopwatch]::StartNew()


#Utiles pour le fichier logs

$logs = Join-Path $PSScriptRoot "logs-audit-passwd-ad.txt"
$date = Get-Date
$espace = "`r`n"
$br = "####################################################################################################"
$start = " ↓ Lancement du script : $date ↓ "

$espace, $start, $espace, $br | Out-File -FilePath $logs -Append

$date2 = Get-Date -Format "yyyy-MM-dd"


################################################################################################

#Importation des modules nécessaires pour executer le script

#Détection présence du module DSInternals indispensable pour l'audit AD
if (Get-Module -ListAvailable -Name DSInternals) {
    #Write-Host "Présence du module DSInternals. Lancement du script en cours." -ForegroundColor Green 
    $mode1ok = "Présence du module DSInternals. Lancement du script en cours."
    $mode1ok | Out-File -FilePath $logs -Append 
} else {
    #Write-Host "Module DSINternals inexistant installation en cours" -ForegroundColor Red
    $mode1ko = "Module DSINternals inexistant installation en cours"
    $mode1ko | Out-File -FilePath $logs -Append 
    [System.Net.ServicePointManager]::SecurityProtocol=[System.Net.SecurityProtocolType]::Tls12
    Install-PackageProvider -Name NuGet -Force -Scope CurrentUser
    if($null -eq (Get-PSRepository -Name PSGallery -ErrorAction SilentlyContinue)) { Register-PSRepository -Default }
    Install-Module -Name DSInternals -Force  
     
}
#Détection présence du module ActiveDirectory necessaire pour la partie 5 du script.

if (Get-Module -ListAvailable -Name ActiveDirectory) {
    $mode2ok = "Présence du module ActiveDirectory" 
    $mode2ok | Out-File -FilePath $logs -Append 
    
  
} else {
    $mode2ko = "Le module ActiveDirectory n'est pas installé, installation en cours."
    $mode2ko | Out-File -FilePath $logs -Append 
    # Installe le module ActiveDirectory
    Install-Module -Name ActiveDirectory -Force -Scope CurrentUser
    }

#Détection présence du module 7Zip4Powershell necessaire pour la partie 6 du script permettant de chiffrer le rapport .txt d'audit et de l'envoyer par mail

if (Get-Module -ListAvailable -Name 7Zip4Powershell) {
    $mode2ok = "Présence du module 7Zip4Powershelly" 
    $mode2ok | Out-File -FilePath $logs -Append 
    
  
} else {
    $mode3ko = "Le module 7Zip4Powershell n'est pas installé, installation en cours."
    $mode3ko | Out-File -FilePath $logs -Append 
    # Installe le module ActiveDirectory
    Install-Module -Name 7Zip4Powershell -Force -Scope CurrentUser
    
    }

################################################################################################

$rapportaudittxt = Join-Path $PSScriptRoot ("Rapport-Audit-AD-" + $date2 + ".txt")
$rapportaudit = Join-Path $PSScriptRoot ("Audit-results.txt")

# Déclenchement de l'Audit

# Point de contrôle pour surveiller si le script doit s'arrêter

$scripts = @(
    "2-lancement-audit.ps1"
    "3-fichiertxt.ps1", #initialisation du fichier rapport .txt
    "4-decoupage-audit.ps1", #decoupage du rapport de l'etape 2 en plusieurs fichiers en fonction de la categorie
    "5-structuration-txt.ps1" #ajout des deffirentes partis decoupées et structuration du rapport
    
    
)

foreach ($scriptPath in $scripts) {
    if (Test-Path -Path $scriptPath) {
        try {
            # Execution des scripts
            $process = Start-Process -FilePath "powershell.exe" -ArgumentList "-File", $scriptPath -Wait -PassThru

            # Vérifiez le code de sortie du script
            if ($process.ExitCode -eq 0) {
                $logscript = "Le script $scriptPath s'est terminé avec succès."
                Write-Host $logscript -ForegroundColor Green
                $logscript | Out-File -FilePath $logs -Append  # Écrit le message de succès dans un fichier
            } else {
                $errorMessage = "Le script $scriptPath a échoué avec le code de sortie $($process.ExitCode).Le script main a été arreté."
                Write-Host $errorMessage -ForegroundColor Red
                $errorMessage | Out-File -FilePath $logs -Append  # Écrit le message d'erreur dans un fichier
                Remove-Item $rapportaudittxt -Force
                Remove-Item $rapportaudit -force
                # Liste des noms de fichiers .txt que vous souhaitez supprimer
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

                # Parcourez la liste des fichiers à supprimer et vérifiez s'ils existent, puis supprimez-les
                foreach ($fichier in $fichiersASupprimer) {
                    $cheminComplet = Join-Path -Path $repertoire -ChildPath $fichier
                    if (Test-Path $cheminComplet) {
                        Remove-Item $cheminComplet
                        "Suite à l'arret du script main, le fichier $cheminComplet a été supprimé." | Out-File -FilePath $logs -Append
                    }
                    else {
                        Write-Host "Le fichier $cheminComplet n'existe pas dans le répertoire."
                        #$fileko = "Script 4 - Le fichier $cheminComplet n'existe pas dans le répertoire temp."
                        #$fileko | Out-File -FilePath $logs -Append
        
        
                    }
                }

                exit
                
                
            }
        } catch {
            $errorMessage = "Une exception s'est produite lors de l'exécution du script $scriptPath : $_"
            Write-Host $errorMessage -ForegroundColor Red
            $errorMessage | Out-File -FilePath $logs -Append  # Écrit le message d'erreur dans un fichier
            exit
        }
    } else {
        $errorMessage = "Le chemin du script $scriptPath est invalide ou le fichier n'existe pas.Le script main c'est interrompu"
        Write-Host $errorMessage -ForegroundColor Red
        $errorMessage | Out-File -FilePath $logs -Append  # Écrit le message d'erreur dans un fichier
        exit
    }
    }


$timer.Stop()
$elapsedTime = $timer.Elapsed

# Afficher la durée d'exécution

#Write-Host "Tous les scripts ont été exécutés." -ForegroundColor Green
"! - Toutes les scripts ont été exécutés avec succès - !" | Out-File -FilePath $logs -Append
$durationMessage = "Duree totale d'execution du script : {0:hh\:mm\:ss}" -f $elapsedTime
#Write-Host $durationMessage -ForegroundColor Yellow
$durationMessage | Out-File -FilePath $logs -Append

#Nom du compte ayant executé le script utile pour le rapport final
$NomUtilisateur = $env:USERNAME
#Write-Output "Le script a été exécuté par : $NomUtilisateur"

#Variables utiles pour le rapport final

$fichierZip = Join-Path $PSScriptRoot ("Rapport-Audit-MDP-AD-" + $date2 +".zip")
$rapportaudittxt = Join-Path $PSScriptRoot ("Rapport-Audit-AD-" + $date2 + ".txt")
$rapportaudit = Join-Path $PSScriptRoot ("Audit-results.txt")

#Recuperation des comptes never expire dans le fichier "neverexpire-temp.txt" utile pour le rapport final
$neverexpire = Join-Path $PSScriptRoot (".\temp\neverexpire-temp.txt")
$contentneverexpire = Get-Content $neverexpire -Encoding UTF8
#Write-Host $content

#############################################################################################
# Generer le rapport final au format HTML 

# Définir les chemins des fichiers
$txtFilePath = $rapportaudittxt
$htmlFilePath = Join-Path $PSScriptRoot ("RAP-" + $date2 + ".html")
$rapportbrute = $rapportaudit

# Lire le contenu du fichier texte avec l'encodage approprié
$content = Get-Content $txtFilePath -Encoding UTF8

# Définir les phrases de début et de fin pur le tableau wordlist
$startPhrase = "elephant"
$endPhrase = "bravo"

#nb de ligne dans wordlist
$startPhrase2 = "alpha"
$endPhrase2 = "elephant"

#tableau same password extract
$startPhrase3 = "charlie"
$endPhrase3 = "monstrueux"

#neverexpire total critique count
$startPhrase4 = "bravo"
$endPhrase4 = "biberon"

#neverexpire total accont
$startPhrase5 = "biberon"
$endPhrase5 = "bravo3"

#tableaucomtpecritique
$startPhrase6 = "bravo4"
$endPhrase6 = "charlie"


# Fonction pour extraire les lignes entre deux phrases
function Extract-Lines($content, $start, $end) {
    $extractedLines = @()
    $insideSection = $false
    foreach ($line in $content) {
        if ($line -match [regex]::Escape($start)) {
            $insideSection = $true
            continue
        }
        if ($insideSection -and $line -match [regex]::Escape($end)) {
            break
        }
        if ($insideSection) {
            $extractedLines += $line
        }
    }
    return $extractedLines
}

# Extraire les lignes pour les deux sections
$extractedLines = Extract-Lines $content $startPhrase $endPhrase
$extractedLines2 = Extract-Lines $content $startPhrase2 $endPhrase2
$extractedLines3 = Extract-Lines $content $startPhrase3 $endPhrase3
$extractedLines4 = Extract-Lines $content $startPhrase4 $endPhrase4
$extractedLines5 = Extract-Lines $content $startPhrase5 $endPhrase5
$extractedLines6 = Extract-Lines $content $startPhrase6 $endPhrase6


#fichier brut
function Convert-NewlinesToBR {
    param (
        [string]$filePath
    )
    
    # Lire le contenu du fichier en préservant les sauts de ligne
    $content = Get-Content -Path $filePath -Raw
    
    # Remplacer les sauts de ligne CR/LF ou LF par <br>
    $formattedContent = $content -replace "`r`n", "<br>"  # Pour les CR/LF
    $formattedContent = $formattedContent -replace "`n", "<br>"  # Pour les LF restants
    
    return $formattedContent
}

# Définir la variable avec le chemin du fichier
$rapportbrute = $rapportaudit

# Utiliser la fonction pour convertir les sauts de ligne en <br> pour bien afficher le rapport brut dans le rapport final
$formattedText = Convert-NewlinesToBR -filePath $rapportbrute

# Afficher ou utiliser le texte formaté
#Write-Output $formattedText

# Compte le nombre de fois qu'il y'a le mot "Group" dans extractedLines3 et le stocker dans une variable

$extractedLines3count = $extractedLines3 | Select-String -Pattern "Group " -AllMatches | Select-Object -ExpandProperty Matches | Measure-Object | Select-Object -ExpandProperty Count


# Créer une structure de base pour le fichier HTML 
$htmlContent = @"
<!DOCTYPE html>
<html lang='fr'>
<head>
    <meta charset='UTF-8'>
    <meta name='viewport' content='width=device-width, initial-scale=1.0'>
    <title>NNS - Rapport Audit Password </title>
    <!-- Lien vers le CSS de Bootstrap -->
    <link href='https://stackpath.bootstrapcdn.com/bootstrap/4.5.2/css/bootstrap.min.css' rel='stylesheet'>
    <style>
        .hidden {
            display: none;
        }
        body {
            background-color: #212121;
        }
            #content-1 {
    color: white;
}
    #content-1, #content-1 pre {
    color: white;
}
    #content-2, #content-2 pre {
    color: white;
}
       #content-3, #content-3 pre {
    color: white;
}
    #content-3, #content-3 pre {
    color: white;
}

    hr {
    border-top: 6px solid #dc3545;
    border-radius: 5px;
}

.fixed-bottom-right {
    position: fixed;
    bottom: 20px;
    right: 20px;
    z-index: 1000;
}

   .introduction h1 {
            font-size: 2.5em;
            text-align: center;
            color: white;
        }

        .introduction p {
            text-align: center;
            color: white;

        }
    .custom-tile {
            border-radius: 8px;
            box-shadow: 0 2px 4px rgba(0, 0, 0, 0.1);
            background-color: black;
        }

        .custom-tile .card-header {
            background-color: #dc3545;
            border-radius: 5px;
            text-align: center;
        }

        .custom-tile .btn-link {
            color: white;
            text-decoration: none;
        }

        .custom-tile .card-body {
            padding: 15px;
            color: white;
        }

        .extracted-lines-content {
            max-height: 300px;
            overflow-y: auto;
            border: 1px solid #ddd;
            border-radius: 4px;
            padding: 10px;

        }

        .extracted-lines-content pre {
            margin: 0;
            white-space: pre-wrap;
            word-wrap: break-word;
        }

        /* CI-dessous le CSS pour la fenêtre pop up */
        .overlay {
            display: none;
            position: fixed;
            top: 0;
            left: 0;
            width: 100%;
            height: 100%;
            background-color: rgba(0, 0, 0, 0.5);
            z-index: 1000;
        }
        .popup {
            position: absolute;
            top: 50%;
            left: 50%;
            transform: translate(-50%, -50%);
            background-color: white;
            padding: 20px;
            border-radius: 5px;
            max-width: 80%;
            max-height: 80%;
            overflow: auto;
        }
        #content {
            white-space: pre-wrap;
            text-align: left;
            margin-bottom: 20px;
        }
    
    </style>
</head>
<body>
    <div class='container my-4' id='card-container'>
    <div class='introduction ' id='introduction'>
            <h1>Rapport d'Audit Password - AD DS</h1>
            <p>
                 Date de l'audit : $date <br>
                Durée de l'audit : $elapsedTime <br>
                 Audit réalisé par : $NomUtilisateur<br>
            </p>
        </div>
        <br>
        <div class="rapportbrute">
        <button type="button" class="btn btn-primary" onclick="openReport()">Rapport brut</button>
    </div>

    <div id="reportOverlay" class="overlay">
        <div class="popup">
            $formattedText
            <div id="content"></div>
            <button type="button" class="btn btn-primary" onclick="closeReport()">Fermer</button>
        </div>
    </div>
    <br>
        <div class='row'>
            <!-- Carte 1 -->
            <div class='col-md-4'>
                <div class='card mb-4'>
                   
                    <h5 class='card-header'>Find in Wordlist     <span class="badge badge-danger" title="Nombre de compte trouvé dans la wordlist">$extractedLines2</span></h5>
                    <div class='card-body'>
                        <p class='card-text'>
                         Liste des comptes avec un mot de passe trouvé dans la wordlist utilisée pour l'audit.
                        </p>
                        <a href='#' class='btn btn-primary' onclick='showContent(1)'>Voir plus</a>
                    </div>
                </div>
            </div>
            <!-- Carte 2 -->
            <div class='col-md-4'>
                <div class='card mb-4'>
                    <h5 class='card-header'>Same Password     <span class="badge badge-danger" title="Nombre de groupes avec le même mot de passe utilisateur">
                    $extractedLines3count</span>
                    </h5>
                    <div class='card-body'>
                        <p class='card-text'>Affichage de groupe composé de compte ayant le même mot de passe utilisateur.</p>
                        </p>
                        <a href='#' class='btn btn-primary' onclick='showContent(2)'>Voir plus</a>
                    </div>
                </div>
            </div>
            <!-- Carte 3 -->
            <div class='col-md-4'>
                <div class='card mb-4'>
                    <h5 class='card-header'>Never Expire     <span class="badge badge-danger" title="Nombre de compte qui n'expire jamais">$extractedLines5</span>     <span class="badge badge-danger" title="Nombre de compte critique qui n'expire jamais">$extractedLines4</span></h5></h5>
                    <div class='card-body'>
                        <p class='card-text'>Liste des compte ayant un mot de passe qui n'expire jamais.</p>
                        <a href='#' class='btn btn-primary' onclick='showContent(3)'>Voir plus</a>
                    </div>
                </div>
            </div>
        </div>
        <div class='row'>
            <!-- carte 4 et 5 et 6 SOON :)
            <div class='col-md-4'>
                <div class='card mb-4'>
                    <h5 class='card-header'>Featured</h5>
                    <div class='card-body'>
                        <h5 class='card-title'>Special title treatment 4</h5>
                        <p class='card-text'>With supporting text below as a natural lead-in to additional content.</p>
                        <a href='#' class='btn btn-primary' onclick='showContent(4)'>Voir plus</a>
                    </div>
                </div>
            </div>

            <div class='col-md-4'>
                <div class='card mb-4'>
                    <h5 class='card-header'>Featured</h5>
                    <div class='card-body'>
                        <h5 class='card-title'>Special title treatment 5</h5>
                        <p class='card-text'>With supporting text below as a natural lead-in to additional content.</p>
                        <a href='#' class='btn btn-primary' onclick='showContent(5)'>Voir plus</a>
                    </div>
                </div>
            </div>
            
            <div class='col-md-4'>
                <div class='card mb-4'>
                    <h5 class='card-header'>Featured</h5>
                    <div class='card-body'>
                        <h5 class='card-title'>Special title treatment 6</h5>
                        <p class='card-text'>With supporting text below as a natural lead-in to additional content.</p>
                        <a href='#' class='btn btn-primary' onclick='showContent(6)'>Voir plus</a>
                    </div>
                </div>
            </div> -->
        </div>
    </div>

    <!-- Contenu spécifique à la carte 1 -->
    <!-- cacher le contenu de la div introduction -->

    <div class='container my-4 hidden' id='content-1'>
        <h2>Find in Wordlist</h2>
        <br>
        <p> 
         Cette partie du rapport affiche les comptes ayant un mot de passe trouvé dans la wordlist utilisée pour l'audit.<br>
         Recommandation : Il est préférable de changer le mot de passe de ces comptes. Un mot de passe trouvé dans une wordlist est un mot de passe faible et facilement crackable.
        <br>
        <p>Au total il y'a <span style="color:#dc3545;">$extractedLines2 comptes</span> avec un mot de passe trouvé dans la wordlist utilisée pour l'audit.
         </p>
        <hr>
           <pre>
"@

# Ajout des lignes extraites au contenu HTML dans la première carte
foreach ($line in $extractedLines) {
    $htmlContent += "$line`n"
}

$htmlContent += @"
                            </pre>
        <button class='btn btn-secondary fixed-bottom-right' onclick='goBack()'>Retour</button>

    </div>

    <!-- Contenu spécifique à la carte 2 -->
    <div class='container my-4 hidden' id='content-2'>
        <h2>Same Password</h2>
        <br>
        <p>
            Cette partie du rapport affiche les groupes composés de comptes ayant le même mot de passe utilisateur.
            Chaque compte d'un groupe partage le même mot de passe. <br>
            Recommandation : Il est préférable de changer le mot de passe de ces comptes. Un mot de passe partagé par plusieurs comptes est un risque de sécurité.
            <br>
            <p>Au total il y'a <span style="color:#dc3545;">$extractedLines3count groupes</span> de comptes ayant le même mot de passe utilisateur.</p>

        </p>
        
        <hr>
        <pre>
"@

foreach ($line in $extractedLines3) {
    $htmlContent += "$line`n"
}

$htmlContent += @"
        </pre>
        <button class='btn btn-secondary fixed-bottom-right' onclick='goBack()'>Retour</button>
    </div>

<!-- Contenu spécifique à la carte 3 -->
<div class='container my-4 hidden' id='content-3'>
    <h2>Never Expire</h2>
    <br>
    <p>
        Cette partie du rapport affiche les comptes ayant un mot de passe qui n'expire jamais.
        Un mot de passe qui n'expire jamais est un risque de sécurité car il peut être utilisé indéfiniment.
        <br>
        Recommandation : Il est préférable de configurer les comptes pour que le mot de passe expire après une certaine durée.
        <br>
        <p>Au total il y'a <span style="color:#dc3545;">$extractedLines5 comptes</span> ayant un mot de passe qui n'expire jamais.</p>
        <p>Dans ces $extractedLines5 comptes, il y'a <span style="color:#dc3545;">$extractedLines4 comptes critiques</span> ayant un mot de passe qui n'expire jamais.
        Le tableau des comptes critiques se base sur le filtre suivant : *admin* ; *-T* pour les comptes tiering.</p>
    </p>
    <hr>
    <br>
    <!-- Nouvelle tuile interactive  -->
    <div class="card mb-3 custom-tile">
        <div class="card-header" id="extractedLinesHeader">
            <h5 class="mb-0">
                <button class="btn btn-link" type="button" onclick="toggleExtractedLines()">
                    Afficher/masquer les $extractedLines5 comptes qui n'expirent jamais
                </button>
            </h5>
        </div>
        <div id="extractedLinesContent" style="display: none;">
            <div class="card-body">
                <div class="extracted-lines-content">
                    <pre>
"@
foreach ($line in $contentneverexpire) {
    $htmlContent += "$line`n"
}
$htmlContent += @"
                    </pre>
                </div>
            </div>
        </div>
    </div>
    <p> <strong> Voici le tableau des comptes critiques qui n'expirent jamais : </strong> </p>
    <br>
    <pre>
"@
foreach ($line in $extractedLines6) {
    $htmlContent += "$line`n"
}
$htmlContent += @"
    </pre>
    <button class='btn btn-secondary fixed-bottom-right' onclick='goBack()'>Retour</button>
</div>



<script>
function toggleExtractedLines() {
    var content = document.getElementById('extractedLinesContent');
    var button = document.querySelector('#extractedLinesHeader button');
    if (content.style.display === 'none') {
        content.style.display = 'block';
    } else {
        content.style.display = 'none';
    }
}
let powershellContent = ""; // Cette variable sera remplie par PowerShell

        function openReport() {
            document.getElementById('reportOverlay').style.display = 'block';
            document.getElementById('content').textContent = powershellContent;
        }

        function closeReport() {
            document.getElementById('reportOverlay').style.display = 'none';
        }


        // Cette fonction sera appelée par PowerShell pour définir le contenu
        function setPowershellContent(content) {
            powershellContent = content;
        }
</script>




    <!-- Script JS de Bootstrap -->
    <script src='https://code.jquery.com/jquery-3.5.1.slim.min.js'></script>
    <script src='https://cdn.jsdelivr.net/npm/@popperjs/core@2.5.3/dist/umd/popper.min.js'></script>
    <script src='https://stackpath.bootstrapcdn.com/bootstrap/4.5.2/js/bootstrap.min.js'></script>

    <!-- Script JS pour le contenu dynamique -->
    <script>
        function showContent(cardNumber) {
            document.getElementById('card-container').classList.add('hidden');
            document.getElementById('content-' + cardNumber).classList.remove('hidden');
        }

        function goBack() {
            document.querySelectorAll('[id^="content-"]').forEach(function(content) {
                content.classList.add('hidden');
            });
            document.getElementById('card-container').classList.remove('hidden');
        }
        
        
    </script>
     <div class="footer" style="text-align: center; color :white">
        <p> NNS - Créé par @MBAY-Clement  | <a
                href="https://creativecommons.org/licenses/by-nc-sa/4.0/deed.fr">CC BY-NC-SA</a></p>
    </div>
    
</body>
</html>
"@
# Fin de la cration du rapport HTML

#Écrire le contenu HTML dans le fichier de sortie en UTF-8 pour que les accents soient correctement affichés
$htmlContent | Set-Content $htmlFilePath -Encoding UTF8 

"Le fichier HTML a été créé avec succès : $htmlFilePath" | Out-File -FilePath $logs -Append


#############################################################################################
#Partie bonus envoi du rapport par mail

#$bodymail = "<h1>Rapport AUDIT des mots de passe effectuee.</h1> <br> $durationMessage <br><br>"

#$BAL_BACKUP = "ADRESSE MAIL A SAISIR ICI"
#$BAL_from="RAPPORT-AUDIT-AD@demo.local"

    #Exportation AUDIT dans un fichier txt 
            #Send-MailMessage -From $BAL_from -To $BAL_BACKUP -SmtpServer smtp.demo.local -Subject "Rapport Audit Passwd AD - $date" -Attachments $fichierZip -BodyAsHtml $bodymail 
            
#"Mail contenant le rapport dans le dossier .zip envoyé avecs succès." | Out-File -FilePath $logs -Append

#############################################################################################

#Execution du script 6 aprsès génération du rapport HTML. Permettant de mettre le rapport HTML dans un zip chiffré.

$scriptPath2 = ".\6-export-zip.ps1"

# Exécution du script
$process = Start-Process -FilePath "powershell.exe" -ArgumentList "-File $scriptPath2" -Wait -PassThru

# Vérification du code de sortie du script
if ($process.ExitCode -eq 0) {
    $logscript = "Le script $scriptPath2 s'est terminé avec succès."
    Write-Host $logscript -ForegroundColor Green
    $logscript | Out-File -FilePath $logs -Append  
} else {
    $errorMessage = "Le script $scriptPath2 a échoué avec le code de sortie $($process.ExitCode). Le script principal a été arrêté."
    Write-Host $errorMessage -ForegroundColor Red
    $errorMessage | Out-File -FilePath $logs -Append  
}

#Deplacer le .zip dans un repertoire si deja existant il ne pourra pas le deplacer et un message d'erreur sera retourné.
$destinationPath = Join-Path -Path $PWD.Path -ChildPath "Historique-Scan"
#extrait que le fichier .zip du chemin (Split-Path)
$destinationFile = Join-Path -Path $destinationPath -ChildPath ($fichierZip | Split-Path -Leaf)

    # Vérifie si le fichier existe déjà à la destination
    if (Test-Path $destinationFile) {

       "Un dossier zip de ce jour existe deja dans le dossier Historique-Scan, deplacement impossible." | Out-File -FilePath $logs -Append
       Write-Host "Un dossier zip de ce jour existe deja dans le dossier Historique-Scan, deplacement impossible." -BackgroundColor Red
    }
    else {
    Move-Item $fichierZip -Destination $destinationPath
    "Le dossier zip a été déplacé avec succès dans le dossier Historque-scan." | Out-File -FilePath $logs -Append

    }


#############################################################################################

#Suppresion des fichiers temp / audit avant fin du script

Remove-Item $rapportaudittxt 
Remove-Item $rapportaudit 
Remove-Item $htmlFilePath

# Liste des noms de fichiers .txt que vous souhaitez supprimer
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

# Parcourez la liste des fichiers à supprimer et vérifiez s'ils existent, puis supprimez-les
foreach ($fichier in $fichiersASupprimer) {
    $cheminComplet = Join-Path -Path $repertoire -ChildPath $fichier
    if (Test-Path $cheminComplet) {
        Remove-Item $cheminComplet
        "Le fichier $cheminComplet a été supprimé." | Out-File -FilePath $logs -Append
    }
    else {
        Write-Host "Le fichier $cheminComplet n'existe pas dans le répertoire."
        $fileko = "Script 4 - Le fichier $cheminComplet n'existe pas dans le répertoire temp."
        $fileko | Out-File -FilePath $logs -Append
        
        
    }
}

"Suppression des fichiers d'audit réussie." | Out-File -FilePath $logs -Append

"-- Fin du script --" | Out-File -FilePath $logs -Append
Write-Host "-- Fin du script --" -ForegroundColor Red

EXIT

#Fin du script main