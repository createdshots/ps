# Prerequisite for running PowerShell TOOLKIT - Internal use, ignore.

if (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Start-Process powershell.exe -Verb RunAs -ArgumentList "-File","'$PSCommandPath'"
    Exit
}

$libraries = @("ExchangeOnlineManagement", "ADSync", "MSOnline", "Microsoft.Graph")

function Install-Library($library) {
    try {
        if (-not (Get-Module -ListAvailable -Name $library)) {
            Install-Module -Name $library -Force -ErrorAction Stop
            Write-Host "Successfully installed $library"
        } else {
            Write-Host "$library is already installed"
        }
    } catch {
        Write-Host "Failed to install $library : $_" -ForegroundColor Red
    }
}

$libraries | ForEach-Object {
    Install-Library $_
}