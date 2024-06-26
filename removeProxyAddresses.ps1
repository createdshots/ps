# Remove all proxy addresses from all security groups in the current domain.

Import-Module ActiveDirectory

$groups = Get-ADGroup -Filter {GroupCategory -eq 'Security'}

foreach ($group in $groups) {
    $proxyAddresses = Get-ADGroup $group | Select-Object -ExpandProperty ProxyAddresses

    $proxyAddresses | ForEach-Object {
        Set-ADGroup $group -Remove @{ProxyAddresses = $_}
    }

    Write-Host "Removed proxy addresses from group $($group.Name):"
    $proxyAddresses | ForEach-Object {
        Write-Host "- $_"
    }
}