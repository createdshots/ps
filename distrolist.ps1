$output_file = "user_distribution_groups1.csv"

# Get all distribution groups
$groups = Get-DistributionGroup -ResultSize Unlimited

$userGroups = @{}

foreach ($group in $groups) {
    $members = Get-DistributionGroupMember -Identity $group.Alias -ResultSize Unlimited

    foreach ($member in $members) {
        if (-not $userGroups.ContainsKey($member.PrimarySMTPAddress)) {
            $userGroups[$member.PrimarySMTPAddress] = @()
        }
        $userGroups[$member.PrimarySMTPAddress] += $group.DisplayName
    }
}

$userGroups.GetEnumerator() | ForEach-Object {
    [PSCustomObject]@{
        User = $_.Key
        Groups = $_.Value -join ","
    }
} | Export-Csv -Path $output_file -NoTypeInformation

Write-Host "User distribution group information exported to $output_file"
