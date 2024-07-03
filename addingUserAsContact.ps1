Import-Module AzureAD
Import-Module ImportExcel

Connect-AzureAD

$excelFilePath = "C:\Users\jack.tolley\staff.xlsx"

$excelData = Import-Excel -Path $excelFilePath

$verifiedDomains = Get-AzureADDomain | Where-Object { $_.IsVerified -eq $true } | Select-Object -ExpandProperty Name

foreach ($row in $excelData) {
    $emailAddress = $row.'Email Addres'  
    $emailGroup = $row.'Email Group' 

    if ($emailGroup -eq "Rep2") {
        $emailGroup = "Rep Staff 2"
    }

    if ([string]::IsNullOrWhiteSpace($emailAddress)) {
        Write-Warning "Email Address is null or empty. Skipping..."
        continue
    }

    $emailDomain = $emailAddress.Split('@')[1]

    if ($emailDomain -in $verifiedDomains) {
        Write-Warning "Cannot invite user with email `$emailAddress` because the domain is a verified domain of this directory."
        continue
    }

    $firstName = $emailAddress.Split('@')[0]
    $lastName = "-"

    $inviteRedirectUrl = "http://myapps.microsoft.com/"

    $externalContact = New-AzureADMSInvitation -InvitedUserDisplayName "$firstName $lastName" -InvitedUserEmailAddress $emailAddress -SendInvitationMessage $false -InviteRedirectUrl $inviteRedirectUrl

    if (![string]::IsNullOrWhiteSpace($emailGroup)) {
        $emailGroupObject = Get-AzureADGroup -Filter "displayName eq '$emailGroup'"
        if ($emailGroupObject) {
            Add-AzureADGroupMember -ObjectId $emailGroupObject.ObjectId -RefObjectId $externalContact.InvitedUser.Id
        } else {
            Write-Warning "Email Group '$emailGroup' not found. Skipping..."
        }
    }
}

Disconnect-AzureAD