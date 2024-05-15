$bgImagePath = "C:\bg\background.png"

Set-ItemProperty -Path "HKCU:\Control Panel\Desktop" -Name "Wallpaper" -Value $bgImagePath

$signature = @"
[DllImport("user32.dll", SetLastError = true)]
public static extern int SystemParametersInfo(int uAction, int uParam, string lpvParam, int fuWinIni);
"@
$systemParametersInfo = Add-Type -MemberDefinition $signature -Name SystemParametersInfo -Namespace Win32Functions -PassThru
$systemParametersInfo::SystemParametersInfo(0x0014, 0, $null, 0x01)

Write-Host "Background image changed successfully!"