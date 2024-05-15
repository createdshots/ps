<#
Created by Jack Tolley - 04/11/2023 - 1.6
#>

# Check if the script is running as administrator
if (-NOT ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    # If not, relaunch the script as administrator
    Start-Process powershell.exe "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs
    exit
}

# By default, assign function to null
$Function = ""

# Check if ExchangeOnlineManagement module is installed, if not install it
if (Get-Module -Name ExchangeOnlineManagement -ListAvailable) {
    Import-Module -Name ExchangeOnlineManagement
} else {
    Install-Module ExchangeOnlineManagement -Force
    Import-Module -Name ExchangeOnlineManagement
}

Add-Type -AssemblyName System.Windows.Forms

function AddPermissions {
    Write-Host "Started AddPermissions Function"

    $TargetUser = $textBox2.Text
    $ExecutedUser = $textBox3.Text
    $AccessRight = $MCB.selectedItem

    Write-Host "Functions have been defined successfully"

    try {
        Add-MailboxFolderPermission -Identity ${TargetUser}:\Calendar -User $ExecutedUser -AccessRights $AccessRight -Confirm:$False
    }
    catch {
        Write-Host "Failed to add calendar permissions: $_"
        $Output.text = "Failed to add calendar permissions, check output!"
        return
    }

    Write-Host "$TargetUser has been granted $AccessRight permissions to $ExecutedUser's calendar"

    $Output.text = "Action completed sucesfully!"
}

function RemovePermissions {
    Write-Host "Started RemovePermissions Function"

    $TargetUser = $textBox2.Text
    $ExecutedUser = $textBox3.Text

    Write-Host "Functions have been defined successfully"

    try {
        Remove-MailboxFolderPermission -Identity "${TargetUser}:\Calendar" -User $ExecutedUser
    }
    catch {
        Write-Host "Failed to remove calendar permissions: $_"
        $Output.text = "Failed to remove calendar permissions, check output!"
        return
    }

    Write-Host "$TargetUser has been removed from $ExecutedUser's calendar permissions"

    $Output.text = "Action completed successfully!"
}
<# 
function Connect {
    param (
        [Parameter(Mandatory=$true)]
        [string]$Email
    )

    try {
        $Output.text = "Importing ExchangeOnlineManagement"
        Import-Module ExchangeOnlineManagement
    }
    catch {
        Write-Host "ExchangeOnline failed to import! $_"
        $Output.text = "ERROR: $_"
    }

    Start-Sleep -seconds 3
    
    $Output.text = "Imported ExchangeOnlineManagement"
    Write-Host "Imported ExchangeOnlineManagement module successfully"

    $Output.text = "Connecting to Exchange Online, please wait..."

    try {
        Connect-ExchangeOnline -UserPrincipalName $Email
    }
    catch {
        Write-Host "Failed to connect to Exchange Online: $_"
        $Output.text = "Failed to connect to Exchange Online, check output!"
        return
    }
    $Output.text = "Connected to Exchange Online"
    $EmailT.text = "$Email"
    $connected = $True
    $Connect.enabled = $False
    $Disonnect.enabled = $True
}
 #>

function Connect {
    param (
        [Parameter(Mandatory=$true)]
        [string]$Email
    )

    $Output.text = "Connecting to Exchange Online, please wait..."

    $job = Start-Job -ScriptBlock {
        param($Email)
        $session = Connect-EXOPSSession -UserPrincipalName $Email
        Import-PSSession $session -AllowClobber
    } -ArgumentList $Email

    while ($job.State -eq 'Running') {
        Start-Sleep -Seconds 1
    }

    if ($job.State -ne 'Completed') {
        Write-Host "Failed to connect to Exchange Online"
        $Output.text = "Failed to connect to Exchange Online, check output!"
        return
    }

    $Output.text = "Connected to Exchange Online"
    $EmailT.text = "$Email"
    $Connect.enabled = $False
}

function Disconnect {
    $Output.text = "Disconnecting from Exchange Online, please wait..."
    try {
        Disconnect-ExchangeOnline -Confirm:$False
    }
    catch {
        Write-Host "Failed to disconnect from Exchange Online: $_"
        $Output.text = "Failed to disconnect from Exchange Online, check output!"
        return
    }
    $Output.text = "Disconnected from Exchange Online"
    $EmailT.text = "Disconnected"
    Start-Sleep -seconds
    $EmailT.text = ""
}

function Test {
    Write-Output "Function tested successfully!"
}

function BeginDebounce {
    # Implementing Debounce to prevent multiple clicks
        param (
            [Parameter(Mandatory=$true)]
            [string]$Function,
            [Parameter(Mandatory=$false)]
            [string]$Email
        )
    Write-Host "BeginDebounce started with parameter: $Function & $Email"
    $AddPermissionButton.Enabled = $False
    $RemovePermissionButton.Enabled = $False
    $Connect.Enabled = $False
    $Disconnect.Enabled = $False
    $Output.text = "Starting function, please wait..."
    Start-Sleep -Seconds 1
    Invoke-Expression ("$Function $Email")
    $AddPermissionButton.Enabled = $True
    $RemovePermissionButton.Enabled = $True
    $Connect.Enabled = $True
    $Disconnect.Enabled = $True
}

$LocalGUI = New-Object System.Windows.Forms.Form

$LocalGUI.ClientSize = '500,380'
$LocalGUI.text = "Calendar Permissions"
$LocalGUI.BackColor = "#ffffff"
$LocalGUI.FormBorderStyle = 'FixedDialog'

# Defining GUI components

$Title = New-Object System.Windows.Forms.Label
$Title.Text = "Adding new permissions"
$Title.AutoSize = $true
$Title.location = New-Object System.Drawing.Point(20, 20)
$Title.Font = 'Microsoft Sans Serif,13'

$Description = New-Object System.Windows.Forms.Label
$Description.Text = "Add permisisons to another users calendar by connecting to Exchange Online"
$Description.AutoSize = $true
$Description.Location = New-Object System.Drawing.Point(20, 50)
$Description.Font = 'Microsoft Sans Serif,10'

$UserInput1 = New-Object System.Windows.Forms.Label
$UserInput1.Text = "Input account with Exchange Permissions (citadmin):"
$UserInput1.AutoSize = $true
$UserInput1.Location = New-Object System.Drawing.Point(20, 90)
$UserInput1.Font = 'Microsoft Sans Serif,10,style=Bold'

$textBox1 = New-Object System.Windows.Forms.TextBox
$textBox1.Location = New-Object System.Drawing.Point(20, 110)
$textBox1.Width = 180
$textBox1.height = 20

$UserInput2 = New-Object System.Windows.Forms.Label
$UserInput2.Text = "Input targeted email here: (Granting permissions to their calendar):"
$UserInput2.AutoSize = $true
$UserInput2.Location = New-Object System.Drawing.Point(20, 130)
$UserInput2.Font = 'Microsoft Sans Serif,10,style=Bold'

$textBox2 = New-Object System.Windows.Forms.TextBox
$textBox2.Location = New-Object System.Drawing.Point(20, 150)
$textBox2.Width = 180
$textBox2.height = 20

$UserInput3 = New-Object System.Windows.Forms.Label
$UserInput3.Text = "Input the executor's email (The user requiring the permissions):"
$UserInput3.AutoSize = $true
$UserInput3.Location = New-Object System.Drawing.Point(20, 180)
$UserInput3.Font = 'Microsoft Sans Serif,10,style=Bold'

$textBox3 = New-Object System.Windows.Forms.TextBox
$textBox3.Location = New-Object System.Drawing.Point(20, 200)
$textBox3.Width = 180
$textBox3.height = 20

$UserInput4 = New-Object System.Windows.Forms.Label
$UserInput4.Text = "Select the permissions they require"
$UserInput4.AutoSize = $true
$UserInput4.Location = New-Object System.Drawing.Point(20, 220)
$UserInput4.Font = 'Microsoft Sans Serif,10,style=Bold'

$MCB = New-Object System.Windows.Forms.ComboBox
$MCB.Location = New-Object System.Drawing.Point(20, 240)
$MCB.AutoSize = $true

@('Author', 'Contributor', 'Editor', 'NonEditingAuthor', 'Owner', 'PublishingAuthor', 'PublishingEditor', 'Reviewer') | ForEach-Object { [void] $MCB.Items.Add($_) }

$MCB.SelectedIndex = 0

$Output = New-Object System.Windows.Forms.Label
$Output.Text = ""
$Output.AutoSize = $true
$Output.Location = New-Object System.Drawing.Point(20, 270)
$Output.Font = 'Microsoft Sans Serif,10'

$EmailT = New-Object System.Windows.Forms.Label
$EmailT.Text = "$Email"
$EmailT.AutoSize = $true
$EmailT.Location = New-Object System.Drawing.Point(220, 300)
$EmailT.Font = 'Microsoft Sans Serif,10'

$AddPermissionButton = New-Object System.Windows.Forms.Button
$AddPermissionButton.BackColor = "#ffffff"
$AddPermissionButton.text = "Add Permissions"
$AddPermissionButton.Width = 90
$AddPermissionButton.height = 35
$AddPermissionButton.Location = New-Object System.Drawing.Point(10, 340)
$AddPermissionButton.forecolor = "#000000"
$AddPermissionButton.add_Click{(BeginDebounce "AddPermissions")}

$RemovePermissionButton = New-Object System.Windows.Forms.Button
$RemovePermissionButton.BackColor = "#ffffff"
$RemovePermissionButton.text = "Remove Permissions"
$RemovePermissionButton.Width = 90
$RemovePermissionButton.height = 35
$RemovePermissionButton.Location = New-Object System.Drawing.Point(120, 340)
$RemovePermissionButton.forecolor = "#000000"
$RemovePermissionButton.add_Click{(BeginDebounce "RemovePermissions")}

$cancel = New-Object System.Windows.Forms.Button
$cancel.BackColor = "#ffffff"
$cancel.text = "Cancel"
$cancel.Width = 90
$cancel.height = 35
$cancel.Location = New-Object System.Drawing.Point(230, 340)
$cancel.forecolor = "#000000"
$cancel.DialogResult = [System.Windows.Forms.DialogResult]::Cancel

$Connect = New-Object System.Windows.Forms.Button
$Connect.BackColor = "#ffffff"
$Connect.text = "Connect"
$Connect.Width = 90
$Connect.height = 35
$Connect.Location = New-Object System.Drawing.Point(10, 300)
$Connect.forecolor = "#000000"
$Connect.add_Click{(BeginDebounce 'Connect' $textBox1.Text)}

$Disconnect = New-Object System.Windows.Forms.Button
$Disconnect.BackColor = "#ffffff"
$Disconnect.text = "Disconnect"
$Disconnect.Width = 90
$Disconnect.height = 35
$Disconnect.Location = New-Object System.Drawing.Point(120, 300)
$Disconnect.forecolor = "#000000"
$Disconnect.add_Click{(BeginDebounce Disconnect)}

$LocalGUI.Controls.AddRange(@($Title, $Description, $UserInput1, $textBox1, $UserInput2, $textBox2, $UserInput3, $textBox3, $UserInput4, $MCB, $EmailT,$AddPermissionButton,$RemovePermissionButton,$cancel,$Output, $Connect, $Disconnect))

[void]$LocalGUI.ShowDialog()

Write-Host "Started importing Module"

try {
    Import-Module ExchangeOnlineManagement
}

catch {
    Write-Host "ExchangeOnline failed to import! $_"
    $Output.text = "ERROR: $_"
}