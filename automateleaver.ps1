# Automate Leaver Process - NOT COMPLETE

param(
    [Parameter(Mandatory=$true)]
    [string]$LeaverUPN,

    [string]$DelegateAccessEmails,

    [Parameter(Mandatory=$true)]
    [string]$RemoveGroups,

    [Parameter(Mandatory=$true)]
    [string]$RemoveLicences
)

Write-Output "Leaver Email: $LeaverUPN"
Write-Output "Delegate Access to: $DelegateAccessEmails"
Write-Output "Remove from Groups? $RemoveGroups"
Write-Output "Remove licences? $RemoveLicences"

if ($null -eq $Emails -or $Emails.Count -eq 0) {
    Write-Output "No emails provided"
} else {
    Write-Output "Emails: $($Emails -join ', ')"
}