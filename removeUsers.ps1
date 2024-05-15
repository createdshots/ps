$emailAddresses = @("")

Import-Module MSOnline
Import-Module Microsoft.Graph

try {
    Connect-MsolService -ErrorAction Stop
    Connect-ExchangeOnline -UserPrincipalName "localadmin@2rhm70.onmicrosoft.com" -ErrorAction Stop
    Connect-MgGraph
}

catch {
    Write-Host "Failed to connect. Error: $_"
    return
}

# Rest of your script...

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