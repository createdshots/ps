# Script to change the background of a machine automatically, for use with Intune

$bgImagePath = "C:\bg\background.png"

Set-ItemProperty -Path "HKCU:\Control Panel\Desktop" -Name "Wallpaper" -Value $bgImagePath

$signature = @"
[DllImport("user32.dll", SetLastError = true)]
public static extern int SystemParametersInfo(int uAction, int uParam, string lpvParam, int fuWinIni);
"@
$systemParametersInfo = Add-Type -MemberDefinition $signature -Name Win32Functions -Namespace SystemParametersInfo -PassThru
$result = $systemParametersInfo::SystemParametersInfo(0x0014, 0, $bgImagePath, 0x01)

if ($result -eq 0) {
    Write-Host "Failed to change background image. Error code: $($systemParametersInfo::GetLastError())"
} else {
    Write-Host "Background image changed successfully!"
}