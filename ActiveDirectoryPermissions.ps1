<#
Created by Jack Tolley - 09/11/2023 - 0.2
#>
<# 
# Check if the script is running as administrator
if (-NOT ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    # If not, relaunch the script as administrator
    Start-Process powershell.exe "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs
    exit
}

# Check if Windows Capability is installed
if (Get-WindowsCapability -Name Rsat.ActiveDirectory.DS-LDS.Tools~~~~0.0.1.0 -Online -ErrorAction SilentlyContinue) {
    Write-Output "Windows Capability Found - Rsat.ActiveDirectory.DS-LDS.Tools~~~~0.0.1.0"
} else {
    Write-Output "Windows Capability Not Found, installing"
    Add-WindowsCapability -Name Rsat.ActiveDirectory.DS-LDS.Tools~~~~0.0.1.0 -Online
    Write-Output "Windows Capability Installed"
}
 #>
Write-Output "Active Directory Module Loaded"

# Set Variables

$TargetUser = $TextBox.Text
$Group = $TextBox2.Text
$Time = $TextBox3.Text

# Define function to add user to group

function AddUserToGroup {
    Param (
        [Parameter(Mandatory=$true)]
        [string]$TargetUser,
        [Parameter(Mandatory=$true)]
        [string]$Group
    )
    Add-ADGroupMember -Identity $Group -Members $TargetUser
}

# Define function to remove user from group

function Remove-UserFromGroup {
    Param (
        [Parameter(Mandatory=$true)]
        [string]$TargetUser,
        [Parameter(Mandatory=$true)]
        [string]$Group
    )
    Remove-ADGroupMember -Identity $Group -Members $TargetUser
}

# Define function to schedule a task to remove the user from the group after specified time

function ScheduledRemove {
    Param (
        [Parameter(Mandatory=$true)]
        [string]$TargetUser,
        [Parameter(Mandatory=$true)]
        [string]$Group,
        [Parameter(Mandatory=$true)]
        [string]$Time
    )
    $Action = New-ScheduledTaskAction -Execute "Powershell.exe" -Argument "Remove-UserFromGroup -TargetUser $TargetUser -Group $Group -Credentials $Credentials"
    $Trigger = New-ScheduledTaskTrigger -Once -At $Time
    $Settings = New-ScheduledTaskSettingsSet -StartWhenAvailable
    Register-ScheduledTask -Action $Action -Trigger $Trigger -Settings $Settings -TaskName "Remove $TargetUser from $Group"
}

# Define group check

function CheckUserInGroup {
    param (
        [Parameter(Mandatory=$true)]
        [string]$TargetUser,
        [Parameter(Mandatory=$true)]
        [string]$Group
    )
    if (Get-ADGroupMember -Identity $Group -Recursive | Where-Object {$_.SamAccountName -eq $TargetUser}) {
        Write-Output "User is in Group - $Group"
    } else {
        Write-Output "User is not in Group - $Group"
    }
}

# Define function to check if user exists

function userCheck {
    param (
        [Parameter(Mandatory=$true)]
        [string]$TargetUser
    )
    if (Get-ADUser -Identity $TargetUser) {
        Write-Output "User Exists"
    } else {
        Write-Output "User Does Not Exist, check username"
}
}

# Check if user already has permissions

function permissionCheck {
    param (
        [Parameter(Mandatory=$true)]
        [string]$Target,
        [Parameter(Mandatory=$true)]
        [string]$Permission
    )
    if (Get-ADUser -Identity $TargetUser -Properties MemberOf | Select-Object -ExpandProperty MemberOf | Where-Object {$_ -eq $Permission}) {
        Write-Output "User already has permissions"
    } else {
        Write-Output "User does not have permissions"
    }
}

# Define GUI Components

Add-Type -AssemblyName System.Windows.Forms

$Form = New-Object system.Windows.Forms.Form
$Form.Text = "Active Directory Permissions"
$Form.Size = New-Object System.Drawing.Size(300,450)
$Form.FormBorderStyle = 'FixedDialog'

$Label = New-Object system.Windows.Forms.Label
$Label.Text = "Active Directory Permissions"
$Label.AutoSize = $true
$Label.Location = New-Object System.Drawing.Point(10,10)
$Label.Font = 'Microsoft Sans Serif,10'

$Label2 = New-Object system.Windows.Forms.Label
$Label2.Text = "Add User to Group"
$Label2.AutoSize = $true
$Label2.Location = New-Object System.Drawing.Point(10,30)
$Label2.Font = 'Microsoft Sans Serif,10'

$Label3 = New-Object system.Windows.Forms.Label
$Label3.Text = "Remove User from Group"
$Label3.AutoSize = $true
$Label3.Location = New-Object System.Drawing.Point(10,190)
$Label3.Font = 'Microsoft Sans Serif,10'

# Text Boxes

$TextBox = New-Object system.Windows.Forms.TextBox
$TextBox.Text = "Enter Target User (username)"
$TextBox.Location = New-Object System.Drawing.Point(10,70)
$TextBox.Size = New-Object System.Drawing.Size(260,30)
$TextBox.Font = 'Microsoft Sans Serif,10'

$TextBox2 = New-Object system.Windows.Forms.TextBox
$TextBox2.Text = "Enter Group Name"
$TextBox2.Location = New-Object System.Drawing.Point(10,100)
$TextBox2.Size = New-Object System.Drawing.Size(260,30)
$TextBox2.Font = 'Microsoft Sans Serif,10'

# Schedule a task to remove the user from the group after specified time

$TextBox3 = New-Object system.Windows.Forms.TextBox
$TextBox3.Text = "Enter Time to Remove User from Group"
$TextBox3.Location = New-Object System.Drawing.Point(10,300)
$TextBox3.Size = New-Object System.Drawing.Size(260,30)
$TextBox3.Font = 'Microsoft Sans Serif,10'

# Buttons

# Prompt for Domain Admin Creds

$ConnectButton = New-Object system.Windows.Forms.Button
$ConnectButton.Text = "Connect to Active Directory"
$ConnectButton.Location = New-Object System.Drawing.Point(10,330)
$ConnectButton.Size = New-Object System.Drawing.Size(260,30)
$ConnectButton.Font = 'Microsoft Sans Serif,10'
$ConnectButton.Add_Click{Get-Credential -Message "Enter Domain Admin Credentials"}

# Disconnect Button

$DisconnectButton = New-Object system.Windows.Forms.Button
$DisconnectButton.Text = "Disconnect from Active Directory"
$DisconnectButton.Location = New-Object System.Drawing.Point(10,360)
$DisconnectButton.Size = New-Object System.Drawing.Size(260,30)
$DisconnectButton.Font = 'Microsoft Sans Serif,10'
$DisconnectButton.Add_Click{Remove-Variable -Name Credentials}

$Button = New-Object system.Windows.Forms.Button
$Button.Text = "Add User to Group"
$Button.Location = New-Object System.Drawing.Point(10,140)
$Button.Size = New-Object System.Drawing.Size(260,30)
$Button.Font = 'Microsoft Sans Serif,10'
$Button.Add_Click{(AddUserToGroup $Credentials)}

$RemoveButton = New-Object system.Windows.Forms.Button
$RemoveButton.Text = "Remove User from Group"
$RemoveButton.Location = New-Object System.Drawing.Point(10,230)
$RemoveButton.Size = New-Object System.Drawing.Size(260,30)
$RemoveButton.Font = 'Microsoft Sans Serif,10'
$RemoveButton.Add_Click{(Remove-UserFromGroup $Credentials)}

$Form.Controls.AddRange(@($Label,$Label2,$Label3,$TextBox,$TextBox2,$TextBox3,$Button,$ConnectButton,$DisconnectButton,$RemoveButton))

[void]$Form.ShowDialog()