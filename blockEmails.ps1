Import-Module ExchangeOnlineManagement

Connect-ExchangeOnline

$csvFilePath = Read-Host "Enter the path to the CSV file containing the email addresses to block"

$emails = Import-Csv -Path $csvFilePath | Select-Object -ExpandProperty Email

$emails | ForEach-Object {
    $email = $_
    New-TenantAllowBlockListItems -ListType Sender -Block -Entries $email
}

Get-TenantAllowBlockListItems -ListType Sender