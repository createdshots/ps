
Import-Module Microsoft.Online.SharePoint -DisableNameChecking

# Connect to SharePoint Online
Connect-SPOService -Url "https://hspg1-admin.sharepoint.com"

# Get all SharePoint sites
$sites = Get-SPOSite

# List the names of all SharePoint sites
foreach ($site in $sites) {
    Write-Output $site.Title
}
