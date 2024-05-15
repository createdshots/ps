$sourceUser = Read-Host "Enter the source user's email address: "
$sourceUserGroups = Get-AzureADUserMembership -ObjectId $sourceUser | Where-Object {$_.ObjectType -eq "Group"}

$targetUser = Read-Host "Enter the target user's email address: "
$targetUserObject = Get-AzureADUser -ObjectId $targetUser

foreach ($group in $sourceUserGroups) {
    Add-AzureADGroupMember -ObjectId $group.ObjectId -RefObjectId $targetUserObject.ObjectId
    Write-Output "Added $targetUser to $group"
}