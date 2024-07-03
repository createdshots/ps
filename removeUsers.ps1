# Automatically remove the user from the Office 365 tenant, convert the mailbox to a shared mailbox, hide it from the address list, and remove any licenses assigned to the user.

$emailAddresses = @("")

Import-Module MSOnline
Import-Module Microsoft.Graph.Authentication

try {
    Connect-MsolService -ErrorAction Stop
    Connect-ExchangeOnline -ErrorAction Stop
    Connect-MgGraph
}

catch {
    Write-Host "Failed to connect. Error: $_"
    return
}

foreach ($email in $emailAddresses) {

    $user = Get-MsolUser -UserPrincipalName $email

    Set-Mailbox -Identity $email -Type Shared
    Set-MsolUser -UserPrincipalName $email -BlockCredential $true
    Set-Mailbox -Identity $email -HiddenFromAddressListsEnabled $true

    if ($user.Licenses.Count -gt 0) {
        $licenses = $user.Licenses.AccountSkuId
        Set-MsolUserLicense -UserPrincipalName $email -RemoveLicenses $licenses
    }
}