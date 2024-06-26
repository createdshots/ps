Connect-HVServer -Server desktopsx.ashmere.co.uk -User ashmerederbys\administrator -Password -Force
Connect-VIServer -Server hovcenter.ashmerederbys.local -Force
$VMs = Get-HVMachineSummary | Select *
foreach ($VM In $VMs) {
    $Date = Get-Date
    $VMName = $VM.Base.Name

    If ($VM.Base.Name -eq "BethanyPrice") {
        $VMName = "BethanyHarrison"
    }
    If ($VM.Base.Name -eq "LauraStone") {
        $VMName = "LauraDavenport"
    }

    If ($VM.Base.BasicState -eq "AGENT_ERR_DISABLED") {
        Write-Output $VMName
        Restart-VM -VM $VMName -Confirm:$False -ErrorAction SilentlyContinue
        Add-Content -Path "C:\Users\administrator\Documents\Sharp Logs\VMWare.txt" -Value "[$Date] - We've identified $VMName has crashed and in a unresponsive state, $VMName has been rebooted."
    }
    If ($VM.Base.BasicState -eq "AGENT_UNREACHABLE") {
        Start-VM -VM $VMName -ErrorAction SilentlyContinue
        Add-Content -Path "C:\Users\administrator\Documents\Sharp Logs\VMWare.txt" -Value "[$Date] - We've identified $VMName has crashed and shutdown, $VMName has been restarted."
    }
}
Disconnect-HVServer -Confirm:$False
Disconnect-VIServer -Confirm:$False