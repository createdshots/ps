# Ensure you are already connected to Active Directory before running this script

Import-Module ActiveDirectory

$sourceUser = Read-Host "Enter the source user's UserPrincipalName"
$destinationUser = Read-Host "Enter the destination user's UPN"

$sourceUserObj = Get-ADUser -Filter "UserPrincipalName -eq '$sourceUser'" -Properties MemberOf

$sourceUserGroups = $sourceUserObj.MemberOf

$destinationUserObj = Get-ADUser -Identity $destinationUser

foreach ($group in $sourceUserGroups) {
    Add-ADGroupMember -Identity $group -Members $destinationUserObj
}

$destinationUserObj | Get-ADUser -Properties MemberOf | Select-Object -ExpandProperty MemberOf