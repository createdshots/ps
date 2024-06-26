<#

this script will ask for a source mailbox and a target mailbox and copy the permissions from the source to the target in case a client is looking to duplicate the permissions from a specific mailbox using ExchangeOnlineManagement
 
You will need PowerShell 7 to run this!
Install the script
Open PowerShell 7
CD to the folder the script is saved in and run it as normal (.\copymailboxperms.ps1)
the rest is pretty much self explanatory! (source is the mailbox copying from -> target is mailbox you're copying to)

#>

Import-Module ExchangeOnlineManagement

Write-Host "Connecting to Exchange Online..."

$UserPrincipalName = Read-Host -Prompt "Enter your User Principal Name"
Connect-ExchangeOnline -UserPrincipalName $UserPrincipalName

$sourceMailbox = Read-Host -Prompt "Enter the source mailbox"
$targetMailbox = Read-Host -Prompt "Enter the target mailbox"

Write-Host "Getting permissions from $sourceMailbox"
$permissions = Get-EXOMailboxPermission -Identity $sourceMailbox

Write-Host "Copying permissions to $targetMailbox..."
foreach ($permission in $permissions) {
    if ($permission.User.ToString() -ne "NT AUTHORITY\SELF") {
        Add-MailboxPermission -Identity $targetMailbox -User $permission.User.ToString() -AccessRights $permission.AccessRights
        Write-Host "User $($permission.User.ToString()) copied successfully."
    }
}

Write-Host "Copying Send As permissions..."
$sendAsPermissions = Get-RecipientPermission -Identity $sourceMailbox
foreach ($permission in $sendAsPermissions) {
    if ($permission.Trustee.ToString() -ne "NT AUTHORITY\SELF") {
        Add-RecipientPermission -Identity $targetMailbox -Trustee $permission.Trustee.ToString() -AccessRights 'SendAs' -Confirm:$false
        Write-Host "Send As permission for user $($permission.Trustee.ToString()) copied successfully."
    }
}

Write-Host "Permissions copied successfully."

pause