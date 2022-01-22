New-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Run" -Name AdobeAAMUpdater-1.0 -PropertyType String -Value "`"C:\Program Files (x86)\Common Files\Adobe\OOBE\PDApp\UWA\UpdaterStartupUtility.exe`"" -Force
New-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Run" -Name AdobeGCInvoker-1.0 -PropertyType String -Value "`"C:\Program Files (x86)\Common Files\Adobe\AdobeGCClient\AGCInvokerUtility.exe`"" -Force

$Services = @(
	# Adobe Genuine Monitor Service
	"AGMService",

	# Adobe Genuine Software Integrity Service
	"AGSService"
)
Get-Service -ServiceName $Services | Set-Service -StartupType Automatic
Get-Service -ServiceName $Services | Start-Service

Get-ScheduledTask -TaskName "Adobe Acrobat Update Task", AdobeGCInvoker-1.0* -ErrorAction Ignore | Enable-ScheduledTask
Unregister-ScheduledTask -TaskName "Acrobat Pro DC Cleanup" -Confirm:$false -ErrorAction Ignore

$Arguments = @"
	"/s" "${env:ProgramFiles(x86)}\Adobe\Acrobat DC\Acrobat Elements\ContextMenuShim64.dll"
"@
Start-Process -FilePath regsvr32.exe -ArgumentList $Arguments

Remove-ItemProperty -Path "HKCU:\Software\Adobe\Adobe Acrobat\DC\IPM" -Name bShowMsgAtLaunch -Force -ErrorAction Ignore
Remove-ItemProperty -Path "HKCU:\Software\Adobe\Adobe Acrobat\DC\HomeWelcomeFirstMile" -Name bFirstMileMinimized -Force -ErrorAction Ignore
Remove-ItemProperty -Path "HKCU:\Software\Adobe\Adobe Acrobat\DC\Originals" -Name iPageViewLayoutMode -Force -ErrorAction Ignore
Remove-ItemProperty -Path "HKCU:\Software\Adobe\Adobe Acrobat\DC\AVGeneral" -Name aActiveUITheme -Force -ErrorAction Ignore
New-ItemProperty -Path "HKCU:\Software\Adobe\Adobe Acrobat\DC\AVGeneral" -Name bHonorOSTheme -PropertyType DWord -Value 0 -Force -ErrorAction Ignore
Remove-ItemProperty -Path "HKCU:\Software\Adobe\Adobe Acrobat\DC\AVGeneral" -Name bHideShareButtonLabel -Force -ErrorAction Ignore
Remove-ItemProperty -Path "HKCU:\Software\Adobe\Adobe Acrobat\DC\AVGeneral" -Name aDefaultRHPViewModeL -Force -ErrorAction Ignore
Remove-ItemProperty -Path "HKCU:\Software\Adobe\Adobe Acrobat\DC\AVGeneral" -Name bRHPSticky -Force -ErrorAction Ignore
Remove-ItemProperty -Path "HKCU:\Software\Adobe\Adobe Acrobat\DC\AcroApp\cFavorites" -Name * -Force -ErrorAction Ignore
Remove-ItemProperty -Path "HKCU:\Software\Adobe\Adobe Acrobat\DC\RememberedViews" -Name iRememberView -Force -ErrorAction Ignore
Remove-ItemProperty -Path "HKCU:\Software\Adobe\Adobe Acrobat\DC\AcroApp\cFavorites" -Name * -Force -ErrorAction Ignore
Remove-ItemProperty -Path "HKCU:\Software\Adobe\Adobe Acrobat\DC\AVGeneral\cCommonToolsDesktop" -Name * - -ErrorAction Ignore
