$filePath = Read-Host "Enter the location of the .txt file:"

$lines = Get-Content $filePath

$currentGroupName = $null
$users = @{}

# Parse the file
foreach ($line in $lines) {
    if ($line -like "GROUP:*") {
        if ($currentGroupName -ne $null) {
            $users[$currentGroupName] = $currentGroupMembers
        }
        $currentGroupName = $line -replace "GROUP: ", ""
        $currentGroupMembers = @()
    } elseif ($line.Trim() -ne "") {
        $currentGroupMembers += $line.Trim()
    }
}
if ($currentGroupName -ne $null) {
    $users[$currentGroupName] = $currentGroupMembers
}

# Display changes
Write-Host "The following changes will be made:"
foreach ($group in $users.Keys) {
    Write-Host "Group: $group"
    foreach ($member in $users[$group]) {
        Write-Host "`tMember: $member"
    }
}

$confirmation = Read-Host "Do you want to continue with these changes? (y/n)"
if ($confirmation -ne 'y') {
    Write-Host "Operation cancelled by the user."
    return
}

foreach ($group in $users.Keys) {
    $groupObjectId = (Get-AzureADGroup -Filter "DisplayName eq '$group'").ObjectId
    if (-not $groupObjectId) {
        Write-Host "Group '$group' not found in Azure AD."
        continue
    }

    foreach ($userName in $users[$group]) {
        $userObjectId = (Get-AzureADUser -Filter "DisplayName eq '$userName'").ObjectId
        if (-not $userObjectId) {
            Write-Host "User '$userName' not found in Azure AD."
            continue
        }

        try {
            Add-AzureADGroupMember -ObjectId $groupObjectId -RefObjectId $userObjectId
            Write-Host "Added '$userName' to '$group'."
        } catch {
            Write-Host "Failed to add '$userName' to '$group': $_"
        }
    }
}