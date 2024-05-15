#broke lol

<#
Created by Jack Tolley - 10/11/2023
#>

$version = "0.15"
$registeredto = ""

# Functions

# Check for updates
<#
function CheckUpdate {
    if $version -eq (Invoke-RestMethod -Uri "https://raw.githubusercontent.com/createdshots/powershell/main/version.txt?token=GHSAT0AAAAAACJ2FAJEIBBIHICWJQ24I762ZKOZXJQ") {
        Write-Output "Toolkit is up to date"
    } else {
        Write-Output "Toolkit is not up to date!"
    }
}
#>
# Check the licence key

Add-Type -AssemblyName System.Windows.Forms

function CheckLicence {
    $licencekey = $licencekeyBox.Text
    Write-Output "Checking licence key..."
    $licences = Get-Content -Path "C:\Users\jackt\Documents\licence\licences.json" | ConvertFrom-Json
    Write-Output "Licence key check completed."
    $found = $false
    foreach ($licence in $licences.licenses) {
        if ($licence.key -eq $licencekey) {
            Write-Output "Licence key found."
            # $registeredto = $licence.name
            $openMainPage
            $found = $true
            Write-Output "Licence key is valid."
            break
        }
    }
    if (-not $found) {
        $licencekeyBox.Text = "Incorrect licence key"
        Write-Output "Licence key is invalid."
    }
}

function openMainPage {
    $LocalGUI.Close()
    $MainPage.ShowDialog()
    Write-Output "Main page opened"
}

# Create the main form
$LocalGUI = New-Object System.Windows.Forms.Form

$LocalGUI.ClientSize = '500,380'
$LocalGUI.text = "PowerShell Toolkit v$version"
$LocalGUI.BackColor = "#ffffff"
$LocalGUI.FormBorderStyle = 'FixedDialog'

# Create the welcome label
$welcomeLabel = New-Object System.Windows.Forms.Label
$welcomeLabel.Text = "Welcome to the PowerShell Toolkit"
$welcomeLabel.Font = New-Object System.Drawing.Font("Helvetica", 20)
$welcomeLabel.AutoSize = $true
$welcomeLabel.Location = New-Object System.Drawing.Point(35,130)

# Create the licence key box

$licencekeyBox = New-Object System.Windows.Forms.TextBox
$licencekeyBox.Location = New-Object System.Drawing.Point(150,250)
$licencekeyBox.Size = New-Object System.Drawing.Size(200,20)
$licencekeyBox.Text = "Enter your licence key here"

$licencekeyText = New-Object System.Windows.Forms.Label
$licencekeyText.Text = "Licence key:"
$licencekeyText.AutoSize = $true
$licencekeyText.Location = New-Object System.Drawing.Point(150,200)
$licencekeyText.Font = New-Object System.Drawing.Font("Helvetica", 10)


# Create the close button
$closeButton = New-Object System.Windows.Forms.Button
$closeButton.Text = "Close"
$closeButton.Location = New-Object System.Drawing.Point(250,330)
$closeButton.DialogResult = [System.Windows.Forms.DialogResult]::Cancel

# Create the next button
$nextButton = New-Object System.Windows.Forms.Button
$nextButton.Text = "Next"
$nextButton.Location = New-Object System.Drawing.Point(150,330)
$nextButton.Add_Click({CheckLicence})

# Add the controls to the form
$LocalGUI.Controls.Add($welcomeLabel)
$LocalGUI.Controls.Add($closeButton)
$LocalGUI.Controls.Add($nextButton)
$LocalGUI.Controls.Add($licencekeyBox)

# Show the form and wait for a button to be clicked
$LocalGUI.ShowDialog()

# Create main page

$MainPage = New-Object System.Windows.Forms.Form
$MainPage.Text = "PowerShell Toolkit v$version - $registeredto"
$MainPage.Width = 600
$MainPage.Height = 400
$MainPage.FormBorderStyle = "FixedDialog"
$MainPage.StartPosition = "CenterScreen"

# Define other pages from Main Page

$MainPage.Controls.Add($closeButton)
$MainPage.Controls.Add($nextButton)

# Open main page

function openMainPage {
    $mainForm.Close()
    $MainPage.ShowDialog()
    Write-Output "Main page opened"
}