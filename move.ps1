# this script was made to automatically move default font files, this is complicated to explain but if you really want to know, message me lol

Set-Location $PSScriptRoot

# Get the current user
$currentUser = [Environment]::UserName

$source1 = ".\Normal.dotm"
$destination1 = "C:\Users\$currentUser\AppData\Roaming\Microsoft\Templates\Normal.dotm"

$source2 = ".\default theme.potx"
$destination2 = "C:\Users\$currentUser\AppData\Roaming\Microsoft\Templates\Document Themes\default theme.potx"

# Copy the files
Copy-Item -Path $source1 -Destination $destination1
Copy-Item -Path $source2 -Destination $destination2