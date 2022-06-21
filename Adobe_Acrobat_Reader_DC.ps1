# Firstly, open and close the app. Then you may run the script, otherwise some registry key won'be created

if (Test-Path -Path "${env:ProgramFiles}\Adobe\Acrobat DC\Acrobat")
{
	Write-Warning -Message "Adobe Acrobat Reader DC x64 detected. Use script for Adobe Acrobat Pro DC due to they use the same engine. This is for Adobe Acrobat Reader DC x86 only"

	Start-Sleep -Seconds 3

	Start-Process -FilePath "https://github.com/farag2/Adobe-Acrobat-DC-Setup/blob/master/Adobe_Acrobat_Pro_DC.ps1"
	exit
}

#region Privacy & Telemetry
# Disable task
Get-ScheduledTask -TaskName AdobeGCInvoker-1.0 | Disable-ScheduledTask
#endregion Privacy & Telemetry

#region UI
# Do not show messages from Adobe when the product launches
# https://www.adobe.com/devnet-docs/acrobatetk/tools/PrefRef/Windows/index.html
if (-not (Test-Path -Path "HKCU:\Software\Adobe\Acrobat Reader\DC\IPM"))
{
	New-Item -Path "HKCU:\Software\Adobe\Acrobat Reader\DC\IPM" -Force
}
New-ItemProperty -Path "HKCU:\Software\Adobe\Acrobat Reader\DC\IPM" -Name bShowMsgAtLaunch -PropertyType DWord -Value 0 -Force

# Collapse all tips on the main page
New-ItemProperty -Path "HKCU:\Software\Adobe\Acrobat Reader\DC\HomeWelcomeFirstMileReader" -Name bFirstMileMinimized -PropertyType DWord -Value 1 -Force

# Always use page Layout Style: "Single Pages Continuous"
New-ItemProperty -Path "HKCU:\Software\Adobe\Acrobat Reader\DC\Originals" -Name iPageViewLayoutMode -PropertyType DWord -Value 2 -Force

# Turn on dark theme
New-ItemProperty -Path "HKCU:\Software\Adobe\Acrobat Reader\DC\AVGeneral" -Name aActiveUITheme -PropertyType String -Value DarkTheme -Force
New-ItemProperty -Path "HKCU:\Software\Adobe\Acrobat Reader\DC\AVGeneral" -Name bHonorOSTheme -PropertyType DWord -Value 0 -Force

# Hide "Share" button lable from Toolbar
New-ItemProperty -Path "HKCU:\Software\Adobe\Acrobat Reader\DC\AVGeneral" -Name bHideShareButtonLabel -PropertyType DWord -Value 1 -Force

# Remember Task Pane state after document closed
New-ItemProperty -Path "HKCU:\Software\Adobe\Acrobat Reader\DC\AVGeneral" -Name bRHPSticky -PropertyType DWord -Value 1 -Force

# Restore last view settings when reopening documents
if (-not (Test-Path -Path "HKCU:\Software\Adobe\Acrobat Reader\DC\RememberedViews"))
{
	New-Item -Path "HKCU:\Software\Adobe\Acrobat Reader\DC\RememberedViews" -Force
}
New-ItemProperty -Path "HKCU:\Software\Adobe\Acrobat Reader\DC\RememberedViews" -Name iRememberView -PropertyType DWord -Value 2 -Force
#endregion UI

#region Quick Tools
# Clear favorite Quick Tools (сommented out)
# Remove-ItemProperty -Path "HKCU:\Software\Adobe\Acrobat Reader\DC\AVGeneral\cFavoritesCommandsDesktop" -Name * -Force -ErrorAction Ignore

# Clear Quick Tools (сommented out)
# Remove-ItemProperty -Path "HKCU:\Software\Adobe\Acrobat Reader\DC\AVGeneral\cCommonToolsDesktop" -Name * -Force -ErrorAction Ignore

# Show Quick Tools in Toolbar
if (-not (Test-Path -Path "HKCU:\Software\Adobe\Acrobat Reader\DC\AVGeneral\cCommonToolsDesktop"))
{
	New-Item -Path "HKCU:\Software\Adobe\Acrobat Reader\DC\AVGeneral\cCommonToolsDesktop" -Force
}
$match = '^' + 'a' + '\d+'

# "Save file"
[int]$int = ((Get-Item -Path "HKCU:\Software\Adobe\Acrobat Reader\DC\AVGeneral\cCommonToolsDesktop").Property | Where-Object -FilterScript {$_ -match $match}).Count
$names = (Get-Item -Path "HKCU:\Software\Adobe\Acrobat Reader\DC\AVGeneral\cCommonToolsDesktop").Property
if ($names)
{
	if ((Get-ItemPropertyValue -Path "HKCU:\Software\Adobe\Acrobat Reader\DC\AVGeneral\cCommonToolsDesktop" -Name $names) -notcontains "Save")
	{
		New-ItemProperty -Path "HKCU:\Software\Adobe\Acrobat Reader\DC\AVGeneral\cCommonToolsDesktop" -Name "a$int" -PropertyType String -Value Save -Force
	}
}
else
{
	New-ItemProperty -Path "HKCU:\Software\Adobe\Acrobat Reader\DC\AVGeneral\cCommonToolsDesktop" -Name "a0" -PropertyType String -Value Save -Force
}

# "Print file"
[int]$int = ((Get-Item -Path "HKCU:\Software\Adobe\Acrobat Reader\DC\AVGeneral\cCommonToolsDesktop").Property | Where-Object -FilterScript {$_ -match $match}).Count
$names = (Get-Item -Path "HKCU:\Software\Adobe\Acrobat Reader\DC\AVGeneral\cCommonToolsDesktop").Property
if ((Get-ItemPropertyValue -Path "HKCU:\Software\Adobe\Acrobat Reader\DC\AVGeneral\cCommonToolsDesktop" -Name $names) -notcontains "Print")
{
	New-ItemProperty -Path "HKCU:\Software\Adobe\Acrobat Reader\DC\AVGeneral\cCommonToolsDesktop" -Name "a$int" -PropertyType String -Value Print -Force
}

# "Undo last change"
[int]$int = ((Get-Item -Path "HKCU:\Software\Adobe\Acrobat Reader\DC\AVGeneral\cCommonToolsDesktop").Property | Where-Object -FilterScript {$_ -match $match}).Count
$names = (Get-Item -Path "HKCU:\Software\Adobe\Acrobat Reader\DC\AVGeneral\cCommonToolsDesktop").Property
if ((Get-ItemPropertyValue -Path "HKCU:\Software\Adobe\Acrobat Reader\DC\AVGeneral\cCommonToolsDesktop" -Name $names) -notcontains "Undo")
{
	New-ItemProperty -Path "HKCU:\Software\Adobe\Acrobat Reader\DC\AVGeneral\cCommonToolsDesktop" -Name "a$int" -PropertyType String -Value Undo -Force
}

# "Redo last change"
[int]$int = ((Get-Item -Path "HKCU:\Software\Adobe\Acrobat Reader\DC\AVGeneral\cCommonToolsDesktop").Property | Where-Object -FilterScript {$_ -match $match}).Count
$names = (Get-Item -Path "HKCU:\Software\Adobe\Acrobat Reader\DC\AVGeneral\cCommonToolsDesktop").Property
if ((Get-ItemPropertyValue -Path "HKCU:\Software\Adobe\Acrobat Reader\DC\AVGeneral\cCommonToolsDesktop" -Name $names) -notcontains "Redo")
{
	New-ItemProperty -Path "HKCU:\Software\Adobe\Acrobat Reader\DC\AVGeneral\cCommonToolsDesktop" -Name "a$int" -PropertyType String -Value Redo -Force
}

# "Page number"
[int]$int = ((Get-Item -Path "HKCU:\Software\Adobe\Acrobat Reader\DC\AVGeneral\cCommonToolsDesktop").Property | Where-Object -FilterScript {$_ -match $match}).Count
$names = (Get-Item -Path "HKCU:\Software\Adobe\Acrobat Reader\DC\AVGeneral\cCommonToolsDesktop").Property
if ((Get-ItemPropertyValue -Path "HKCU:\Software\Adobe\Acrobat Reader\DC\AVGeneral\cCommonToolsDesktop" -Name $names) -notcontains "GoToPage")
{
	New-ItemProperty -Path "HKCU:\Software\Adobe\Acrobat Reader\DC\AVGeneral\cCommonToolsDesktop" -Name "a$int" -PropertyType String -Value GoToPage -Force
}
#endregion Quick Tools
