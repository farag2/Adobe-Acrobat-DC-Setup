# Firstly, open and close the app. Then you may run the script, otherwise some registry key won'be created
# Suitable for Adobe Acrobat Reader DC x64 too
# https://www.adobe.com/devnet-docs/acrobatetk/tools/PrefRef/Windows/endindex.html

Get-Service -Name AdobeARMservice -ErrorAction Ignore | Stop-Service -Force

# Uninstall Adobe Software Integrity Service
if (Test-Path -Path "${env:ProgramFiles(x86)}\Common Files\Adobe\AdobeGCClient\AdobeCleanUpUtility.exe")
{
	Start-Process -FilePath "${env:ProgramFiles(x86)}\Common Files\Adobe\AdobeGCClient\AdobeCleanUpUtility.exe" -Wait
}

# Accept EULA even it was accepted programmatically. Non-acceptance of the UELA may result in the 100700 (100600) error when you run the updater
if ((Get-ItemPropertyValue -Path "HKLM:\SOFTWARE\Adobe\Adobe Acrobat\DC\RDCNotificationAppx" -Name AppPackageName) -notmatch "Reader")
{
	if (-not (Test-Path -Path "HKCU:\Software\Adobe\Adobe Acrobat\DC\AdobeViewer"))
	{
		New-Item -Path "HKCU:\Software\Adobe\Adobe Acrobat\DC\AdobeViewer" -Force
	}
	New-ItemProperty -Path "HKCU:\Software\Adobe\Adobe Acrobat\DC\AdobeViewer" -Name EULA -PropertyType DWord -Value 1 -Force
}

#region UI
# Collapse all tips on the main page
New-ItemProperty -Path "HKCU:\Software\Adobe\Adobe Acrobat\DC\HomeWelcomeFirstMile" -Name bFirstMileMinimized -PropertyType DWord -Value 1 -Force

# Always use page Layout Style: "Single Pages Continuous"
# https://www.adobe.com/devnet-docs/acrobatetk/tools/PrefRef/Windows/Originals.html#idkeyname_1_17353
New-ItemProperty -Path "HKCU:\Software\Adobe\Adobe Acrobat\DC\Originals" -Name iPageViewLayoutMode -PropertyType DWord -Value 2 -Force

# Turn on dark theme
New-ItemProperty -Path "HKCU:\Software\Adobe\Adobe Acrobat\DC\AVGeneral" -Name aActiveUITheme -PropertyType String -Value DarkTheme -Force
New-ItemProperty -Path "HKCU:\Software\Adobe\Adobe Acrobat\DC\AVGeneral" -Name bHonorOSTheme -PropertyType DWord -Value 0 -Force

# Left "Edit PDF" and "Organize Pages" the only tools in the Task Pane
if ((Get-ItemPropertyValue -Path "HKLM:\SOFTWARE\Adobe\Adobe Acrobat\DC\RDCNotificationAppx" -Name AppPackageName) -notmatch "Reader")
{
	Remove-ItemProperty -Path "HKCU:\Software\Adobe\Adobe Acrobat\DC\AcroApp\cFavorites" -Name * -Force
	New-ItemProperty -Path "HKCU:\Software\Adobe\Adobe Acrobat\DC\AcroApp\cFavorites" -Name a0 -PropertyType String -Value EditPDFApp -Force
	New-ItemProperty -Path "HKCU:\Software\Adobe\Adobe Acrobat\DC\AcroApp\cFavorites" -Name a1 -PropertyType String -Value PagesApp -Force
}

# Restore last view settings when reopening documents
# https://www.adobe.com/devnet-docs/acrobatetk/tools/PrefRef/Windows/RememberedViews.html#idkeyname_1_18343
if ((Get-ItemPropertyValue -Path "HKLM:\SOFTWARE\Adobe\Adobe Acrobat\DC\RDCNotificationAppx" -Name AppPackageName) -notmatch "Reader")
{
	if (-not (Test-Path -Path "HKCU:\Software\Adobe\Adobe Acrobat\DC\RememberedViews"))
	{
		New-Item -Path "HKCU:\Software\Adobe\Adobe Acrobat\DC\RememberedViews" -Force
	}
	New-ItemProperty -Path "HKCU:\Software\Adobe\Adobe Acrobat\DC\RememberedViews" -Name iRememberView -PropertyType DWord -Value 2 -Force
}
#endregion UI
