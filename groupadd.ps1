
Import-Module ExchangeOnlineManagement

Connect-ExchangeOnline

$distributionList = Read-Host "Enter the name of the distribution list"

$fileType = Read-Host "Enter the file type (csv or txt)"

$filePath = Read-Host "Enter the path to the file"

if ($fileType -eq "csv") {
    $emails = Import-Csv -Path $filePath | Select-Object -ExpandProperty Email
} elseif ($fileType -eq "txt") {
    $emails = Get-Content -Path $filePath
} else {
    Write-Host "Invalid file type. Please provide a valid file type (csv or txt)."
    return
}

foreach ($email in $emails) {
    Add-DistributionGroupMember -Identity $distributionList -Member $email

    Write-Host "Added $email to $distributionList"
}

Disconnect-ExchangeOnline
