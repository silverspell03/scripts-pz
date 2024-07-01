#Script d'installation permettant de définir quelques parametres de base et l'installation des programmes essentiels 

#Autorise l'execution de scripts et télécharge chocolatey
if (-not (Test-Path -Path "C:\ProgramData\chocolatey")) {
    Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))
}
# Determine le dossier d'execution du script
$currentScriptDirectory = Split-Path -Path $MyInvocation.MyCommand.Path -Parent

try {
    # Recupere le lien du TeamViewerQS � copier et le dossier de destination
    $fileToCopy = "$currentScriptDirectory\TeamViewerQS.exe"
    $destinationDirectory = "C:\Program Files\TeamViewerQS"

    # V�rifie si le fichier source existe
    if (-not (Test-Path -Path $fileToCopy -PathType Leaf)) {
        throw "Le fichier source '$fileToCopy' n'existe pas."
    }

    # Cr�e le dossier de destination s'il n'existe pas
    if (-not (Test-Path -Path $destinationDirectory -PathType Container)) {
        New-Item -Path $destinationDirectory -ItemType Directory -Force -ErrorAction Stop
    }

    # Copie le fichier vers le dossier
    Copy-Item -Path $fileToCopy -Destination $destinationDirectory -Force -ErrorAction Stop

    # V�rifie si le fichier a �t� correctement copi�
    if (-not (Test-Path -Path "$destinationDirectory\TeamViewerQS.exe" -PathType Leaf)) {
        throw "Le fichier n'a pas �t� correctement copi� dans le dossier de destination."
    }

    # Prend le chemin du bureau public
    $publicDesktopPath = [Environment]::GetFolderPath('CommonDesktopDirectory')

    # Cr�e un lien du TeamViewerQS vers le bureau public
    $shortcutPath = Join-Path -Path $publicDesktopPath -ChildPath "TeamViewerQS.lnk"
    $targetPath = Join-Path -Path $destinationDirectory -ChildPath "TeamViewerQS.exe"

    $WScriptShell = New-Object -ComObject WScript.Shell
    $shortcut = $WScriptShell.CreateShortcut($shortcutPath)
    $shortcut.TargetPath = $targetPath
    $shortcut.Save()

    Write-Host "TeamViewerQS correctement install�."
}
catch {
    Write-Host "Probl�me d'installation du TeamViewerQS : $_"
}


# Désactive le fastboot avec une clé de registre
$regPath = "HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Power"
$regName = "HiberbootEnabled"
Set-ItemProperty -Path $regPath -Name $regName -Value 0

Write-Host "Fastboot désactivé."

#Mise à jour et installation des différents programmes avec chocolatey

choco upgrade chocolatey firefox adobereader eid-belgium eid-belgium-viewer notepadplusplus 7zip vlc xnviewmp office365business -y

#Met à jour les packets winget

winget upgrade all

#Activation de WinRM
WinRM quickconfig