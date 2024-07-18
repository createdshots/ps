Import-Module ExchangeOnlineManagement

Connect-ExchangeOnline

$csvFilePath = Read-Host "Enter the path to the CSV file containing the email addresses to block"

$emails = Get-Content -Path $csvFilePath

foreach ($email in $emails) {
    New-TenantAllowBlockListItems -ListType Sender -Block -Entries $email
}

Get-TenantAllowBlockListItems -ListType Sender