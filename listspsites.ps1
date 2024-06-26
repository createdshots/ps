# This will list all SharePoint sites in a SharePoint Online tenant

Import-Module Microsoft.Online.SharePoint -DisableNameChecking

# Connect to SharePoint Online
Connect-SPOService -Url "https://site.sharepoint.com"

# Get all SharePoint sites
$sites = Get-SPOSite

# List the names of all SharePoint sites
foreach ($site in $sites) {
    Write-Output $site.Title
}
