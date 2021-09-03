New-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Run" -Name AdobeGCInvoker-1.0 -PropertyType String -Value "`"C:\Program Files (x86)\Common Files\Adobe\AdobeGCClient\AGCInvokerUtility.exe`"" -Force
New-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Run" -Name AdobeAAMUpdater-1.0 -PropertyType String -Value "`"C:\Program Files (x86)\Common Files\Adobe\OOBE\PDApp\UWA\UpdaterStartupUtility.exe`"" -Force
New-ItemProperty -Path "HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Run" -Name "Acrobat Assistant 8.0" -PropertyType String -Value "`"C:\Program Files (x86)\Adobe\Acrobat DC\Acrobat\Acrotray.exe`"" -Force

$Services = @(
	# Adobe Acrobat Update Service
	"AdobeARMservice",

	# Adobe Genuine Monitor Service
	"AGMService",

	# Adobe Genuine Software Integrity Service
	"AGSService"
)
Get-Service -ServiceName $Services | Set-Service -StartupType Automatic
Get-Service -ServiceName $Services | Start-Service

Get-ScheduledTask -TaskName "Adobe Acrobat Update Task", AdobeGCInvoker-1.0* | Enable-ScheduledTask

Unregister-ScheduledTask -TaskName "Acrobat Pro DC Cleanup" -Confirm:$false

$Arguments = @"
	"/s" "${env:ProgramFiles(x86)}\Adobe\Acrobat DC\Acrobat Elements\ContextMenuShim64.dll"
"@
Start-Process -FilePath regsvr32.exe -ArgumentList $Arguments

Remove-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Adobe\Adobe Acrobat\DC\FeatureLockdown\cServices" -Name bUpdater -Force

Remove-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Adobe\Adobe Acrobat\DC\FeatureLockdown\cServices" -Name bToggleAdobeDocumentServices -Force

Remove-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Adobe\Adobe Acrobat\DC\FeatureLockdown\cServices" -Name bTogglePrefsSync -Force

Remove-ItemProperty -Path "HKCU:\Software\Adobe\Adobe Acrobat\DC\IPM" -Name bShowMsgAtLaunch -Force

Remove-ItemProperty -Path "HKCU:\Software\Adobe\Adobe Acrobat\DC\HomeWelcomeFirstMile" -Name bFirstMileMinimized -Force

Remove-ItemProperty -Path "HKCU:\Software\Adobe\Adobe Acrobat\DC\Originals" -Name iPageViewLayoutMode -Force

Remove-ItemProperty -Path "HKCU:\Software\Adobe\Adobe Acrobat\DC\AVGeneral" -Name aActiveUITheme -Force
New-ItemProperty -Path "HKCU:\Software\Adobe\Adobe Acrobat\DC\AVGeneral" -Name bHonorOSTheme -PropertyType DWord -Value 0 -Force

Remove-ItemProperty -Path "HKCU:\Software\Adobe\Adobe Acrobat\DC\AVGeneral" -Name bHideShareButtonLabel -Force

Remove-ItemProperty -Path "HKCU:\Software\Adobe\Adobe Acrobat\DC\AVGeneral" -Name aDefaultRHPViewModeL -Force

Remove-ItemProperty -Path "HKCU:\Software\Adobe\Adobe Acrobat\DC\AcroApp\cFavorites" -Name * -Force

New-ItemProperty -Path "HKCU:\Software\Adobe\Adobe Acrobat\DC\RememberedViews" -Name iRememberView -PropertyType DWord -Value 1 -Force

Remove-Item -Path "HKCU:\Software\Adobe\Adobe Acrobat\DC\AVGeneral\cCommonToolsDesktop" -Force
