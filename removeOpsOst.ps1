# Remove the largest OST file from the current user's Outlook folder

$profileFolder = [Environment]::GetFolderPath("UserProfile")

$outlookFolder = Join-Path -path $profileFolder -ChildPath "AppData\Local\Microsoft\Outlook"

$ostFiles = Get-ChildItem -Path $outlookFolder -Filter "*ops*.ost" | Sort-Object -Property Length -Descending

if ($ostFiles.Count -gt 0) {
    $largestOstFile = $ostFiles[0]
    Remove-Item -Path $largestOstFile.FullName -Force
    Write-Host "Removed $($largestOstFile.Name)"
} else {
    Write-Host "No OST files found"
    }
