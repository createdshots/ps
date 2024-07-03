# Ensure you are already connected to Active Directory before running this script

Import-Module ActiveDirectory

$sourceUser = Read-Host "Enter the source user's UserPrincipalName"
$destinationUser = Read-Host "Enter the destination user's UPN"

try {
    $sourceUserObj = Get-ADUser -Filter "UserPrincipalName -eq '$sourceUser'" -Properties MemberOf -ErrorAction Stop
    Write-Output "Source user found: $($sourceUserObj.Name)"
} catch {
    Write-Error "Failed to find source user: $_"
    exit
}

if ($sourceUserObj.MemberOf -eq $null -or $sourceUserObj.MemberOf.Count -eq 0) {
    Write-Output "No group memberships found for source user."
    exit
} else {
    Write-Output "Found $($sourceUserObj.MemberOf.Count) group(s) for source user."
}

$sourceUserGroups = $sourceUserObj.MemberOf

try {
    $destinationUserObj = Get-ADUser -Filter "UserPrincipalName -eq '$destinationUser'" -ErrorAction Stop
} catch {
    Write-Error "Failed to find destination user: $_"
    exit
}

foreach ($group in $sourceUserGroups) {
    try {
        Add-ADGroupMember -Identity $group -Members $destinationUserObj -ErrorAction Stop
        Write-Output "Added $($destinationUserObj.SamAccountName) to group: $group"
    } catch {
        Write-Error "Failed to add to group: $_"
    }
}