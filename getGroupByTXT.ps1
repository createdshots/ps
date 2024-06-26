<# ##############
Add group by reading a .txt file containing group and member information, and then add the members to their respective groups in Azure AD. Here's a guide on how to use this script:

Open a PowerShell console or terminal.

Navigate to the directory where the script is saved.

Run the script by executing the following command:
.\getGroupByTXT.ps1

The script will prompt you to enter the location of the .txt file. Provide the full path to the .txt file and press Enter.

The script will parse the file and display the changes that will be made. It will show the groups and their respective members.

Confirm whether you want to proceed with the changes by entering 'y' or 'n' when prompted.

If you choose to proceed, the script will add the users to their respective groups in Azure AD. It will display the status of each operation, indicating whether the user was successfully added or if there was an error.

The .TXT file should be formatted as:
GROUP: Group1
User1
User2
User3

GROUP: Group2
User1
User4
User5

etc...

############## #>

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