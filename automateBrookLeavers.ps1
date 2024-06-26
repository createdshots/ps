# Automate Leaver Process for Brook Young People - NOT COMPLETED

param(
    [Parameter(Mandatory=$true)]
    [string]$LeaverUPN,

    [string]$DelegateAccessEmails,

    [Parameter(Mandatory=$true)]
    [bool]$RemoveGroups,

    [Parameter(Mandatory=$true)]
    [bool]$RemoveLicences,

    [string]$OutOfOfficeMessage
)

# Convert to Shared Mailbox
Update-MgUserMailboxSetting -UserId $LeaverUPN -IsResourceAccount $true

# Set Out of Office Message if provided
if ($null -ne $OutOfOfficeMessage) {
    Set-MgUserMailboxAutoReplySetting -UserId $LeaverUPN -AutoReplyState AlwaysEnabled -InternalReplyMessage $OutOfOfficeMessage -ExternalReplyMessage $OutOfOfficeMessage
}

# Remove from Groups
if ($RemoveGroups) {
    $groups = Get-MgGroupMember -UserId $LeaverUPN
    $groups | ForEach-Object {
        Remove-MgGroupMember -GroupId $_.Id -UserId $LeaverUPN
    }
}

# Grant Access to Delegate if requested
if ($null -ne $DelegateAccessEmails) {
    $DelegateAccessEmails.Split(',').Trim() | ForEach-Object {
        Add-MgUserMailFolderPermission -UserId $LeaverUPN -MailFolderId 'Inbox' -EmailAddress $_ -IsFolderOwner $true
    }
}

# Remove Licences
if ($RemoveLicences) {
    $licenses = Get-MgUserLicenseDetail -UserId $LeaverUPN
    $licenses | ForEach-Object {
        Remove-MgUserLicense -UserId $LeaverUPN -LicenseId $_.Id
    }
}