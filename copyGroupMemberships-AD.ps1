Import-Module ActiveDirectory

$sourceUser = "rachael.thomas@birmingham-rep.co.uk"
$destinationUser = "destination_user"

$sourceUserObj = Get-ADUser -Filter "UserPrincipalName -eq '$sourceUser'" -Properties MemberOf

$sourceUserGroups = $sourceUserObj.MemberOf

$destinationUserObj = Get-ADUser -Identity $destinationUser

foreach ($group in $sourceUserGroups) {
    Add-ADGroupMember -Identity $group -Members $destinationUserObj
}

$destinationUserObj | Get-ADUser -Properties MemberOf | Select-Object -ExpandProperty MemberOf