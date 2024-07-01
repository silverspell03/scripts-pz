#Script d'installation permettant de dÃ©finir quelques parametres de base et l'installation des programmes essentiels 

#Autorise l'execution de scripts et tÃ©lÃ©charge chocolatey
if (-not (Test-Path -Path "C:\ProgramData\chocolatey")) {
    Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))
}
# Determine le dossier d'execution du script
$currentScriptDirectory = Split-Path -Path $MyInvocation.MyCommand.Path -Parent

try {
    # Recupere le lien du TeamViewerQS à copier et le dossier de destination
    $fileToCopy = "$currentScriptDirectory\TeamViewerQS.exe"
    $destinationDirectory = "C:\Program Files\TeamViewerQS"

    # Vérifie si le fichier source existe
    if (-not (Test-Path -Path $fileToCopy -PathType Leaf)) {
        throw "Le fichier source '$fileToCopy' n'existe pas."
    }

    # Crée le dossier de destination s'il n'existe pas
    if (-not (Test-Path -Path $destinationDirectory -PathType Container)) {
        New-Item -Path $destinationDirectory -ItemType Directory -Force -ErrorAction Stop
    }

    # Copie le fichier vers le dossier
    Copy-Item -Path $fileToCopy -Destination $destinationDirectory -Force -ErrorAction Stop

    # Vérifie si le fichier a été correctement copié
    if (-not (Test-Path -Path "$destinationDirectory\TeamViewerQS.exe" -PathType Leaf)) {
        throw "Le fichier n'a pas été correctement copié dans le dossier de destination."
    }

    # Prend le chemin du bureau public
    $publicDesktopPath = [Environment]::GetFolderPath('CommonDesktopDirectory')

    # Crée un lien du TeamViewerQS vers le bureau public
    $shortcutPath = Join-Path -Path $publicDesktopPath -ChildPath "TeamViewerQS.lnk"
    $targetPath = Join-Path -Path $destinationDirectory -ChildPath "TeamViewerQS.exe"

    $WScriptShell = New-Object -ComObject WScript.Shell
    $shortcut = $WScriptShell.CreateShortcut($shortcutPath)
    $shortcut.TargetPath = $targetPath
    $shortcut.Save()

    Write-Host "TeamViewerQS correctement installé."
}
catch {
    Write-Host "Problème d'installation du TeamViewerQS : $_"
}


# DÃ©sactive le fastboot avec une clÃ© de registre
$regPath = "HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Power"
$regName = "HiberbootEnabled"
Set-ItemProperty -Path $regPath -Name $regName -Value 0

Write-Host "Fastboot dÃ©sactivÃ©."

#Mise Ã  jour et installation des diffÃ©rents programmes avec chocolatey

choco upgrade chocolatey firefox adobereader eid-belgium eid-belgium-viewer notepadplusplus 7zip vlc xnviewmp office365business -y

#Met Ã  jour les packets winget

winget upgrade all

#Activation de WinRM
WinRM quickconfig