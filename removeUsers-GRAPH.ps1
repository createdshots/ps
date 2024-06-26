# Remove all users with the specified emails from the 365

Import-Module Microsoft.Graph

Connect-MgGraph

$emails = @(
    "email1@test.com",
    "email2@test.com"
)


foreach ($email in $emails) {
    try {
        $user = Get-MgUser -Filter "mail eq '$email'"
        if ($user) {
            Remove-MgUser -UserId $user.Id -Confirm:$false
            Write-Host "User with email $email deleted successfully"
        } else {
            Write-Host "User with email $email not found"
        }
    } catch {
        Write-Host "Failed to delete user with email $email. Error: $_"
    }
}

Disconnect-MgGraph