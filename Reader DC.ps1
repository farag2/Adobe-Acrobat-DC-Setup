#region Privacy & Telemetry
# Turn off services
# Отключить службы
$services = @(
	# Adobe Acrobat Update Service
	"AdobeARMservice"
)
Get-Service -ServiceName $services | Stop-Service
Get-Service -ServiceName $services | Set-Service -StartupType Disabled

# Disable update tasks
# Отключить задачи по обновлению
Get-ScheduledTask -TaskName "Adobe Acrobat Update Task", AdobeGCInvoker-1.0* | Disable-ScheduledTask
#endregion Privacy & Telemetry

#region Addons
# Remove Firefox addons
# Удалить расширение в Firefox
Remove-ItemProperty HKLM:\SOFTWARE\Mozilla\Firefox\Extensions -Name *acrobat.adobe.com -Force -ErrorAction Ignore
Remove-Item -Path "${env:ProgramFiles(x86)}\Adobe\Acrobat Reader DC\Reader\Browser" -Recurse -Force -ErrorAction Ignore

# Remove COM Add-Ins for Office
# Удалить надстройки COM Adobe Acrobat Pro DC для Office
Remove-Item -Path HKLM:\SOFTWARE\Microsoft\Office\*\Addins\PDF* -Force -ErrorAction Ignore
Remove-Item -Path HKLM:\SOFTWARE\Microsoft\Office\*\Addins\Adobe* -Force -ErrorAction Ignore
Remove-Item -Path HKLM:\SOFTWARE\WOW6432Node\Microsoft\Office\*\Addins\PDF* -Force -ErrorAction Ignore
Remove-Item -Path HKLM:\SOFTWARE\WOW6432Node\Microsoft\Office\*\Addins\Adobe* -Force -ErrorAction Ignore
#endregion Addons

#region Task
# Create a task in the Task Scheduler to configure Adobe Acrobat Pro DC
# The task runs every 31 days
# Создать задачу в Планировщике задач по настройке Adobe Acrobat Pro DC
# Задача выполняется каждые 31 дней
$Argument = "
	Get-Service -Name AdobeARMservice | Set-Service -StartupType Disabled
	Get-Service -Name AdobeARMservice | Stop-Service
	Stop-Process -Name acrotray -Force
	Get-ScheduledTask -TaskName 'Adobe Acrobat Update Task' | Disable-ScheduledTask
	Remove-ItemProperty HKLM:\SOFTWARE\Mozilla\Firefox\Extensions -Name *acrobat.adobe.com -Force
	Remove-Item -Path '${env:ProgramFiles(x86)}\Adobe\Acrobat Reader DC\Reader\Browser' -Recurse -Force
	Remove-Item -Path HKLM:\SOFTWARE\Microsoft\Office\*\Addins\PDF* -Force
	Remove-Item -Path HKLM:\SOFTWARE\Microsoft\Office\*\Addins\Adobe* -Force
	Remove-Item -Path HKLM:\SOFTWARE\WOW6432Node\Microsoft\Office\*\Addins\PDF* -Force
	Remove-Item -Path HKLM:\SOFTWARE\WOW6432Node\Microsoft\Office\*\Addins\Adobe* -Force
"
$Action = New-ScheduledTaskAction -Execute powershell.exe -Argument $Argument
$Trigger = New-ScheduledTaskTrigger -Daily -DaysInterval 31 -At 9am
$Settings = New-ScheduledTaskSettingsSet -Compatibility Win8 -StartWhenAvailable
$Principal = New-ScheduledTaskPrincipal -UserID "NT AUTHORITY\SYSTEM" -RunLevel Highest
$Description = "Cleaning up Acrobat Reader DC after app's update"
$Parameters = @{
	"TaskName"		= "Acrobat Reader DC Cleanup"
	"TaskPath"		= "Setup Script"
	"Principal"		= $Principal
	"Action"		= $Action
	"Description"	= $Description
	"Settings"		= $Settings
	"Trigger"		= $Trigger
}
Register-ScheduledTask @Parameters -Force
#endregion Task

#region UI
# Turn off both updates to the product's web-plugin components as well as all services
# Отключить обновление компонентов веб-плагинов, всех сервисов Adobe и вход в учетную запись
if (-not (Test-Path -Path "HKLM:\SOFTWARE\Policies\Adobe\Acrobat Reader\DC\FeatureLockdown\cServices"))
{
	New-Item -Path "HKLM:\SOFTWARE\Policies\Adobe\Acrobat Reader\DC\FeatureLockdown\cServices" -Force
}
New-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Adobe\Acrobat Reader\DC\FeatureLockdown\cServices" -Name bUpdater -Value 0 -Force

# Turn off all Document Cloud service access
# Отключить все сервисы Adobe Document Cloud
New-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Adobe\Acrobat Reader\DC\FeatureLockdown\cServices" -Name bToggleAdobeDocumentServices -PropertyType DWord -Value 1 -Force

# Turn off preference synchronization across devices
# Отключить синхронизацию между устройствами
New-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Adobe\Acrobat Reader\DC\FeatureLockdown\cServices" -Name bTogglePrefsSync -PropertyType DWord -Value 1 -Force

# Do not show messages from Adobe when the product launches
# Не показывать сообщения от Adobe при запуске
if (-not (Test-Path -Path "HKCU:\Software\Adobe\Acrobat Reader\DC\IPM"))
{
	New-Item -Path "HKCU:\Software\Adobe\Acrobat Reader\DC\IPM" -Force
}
New-ItemProperty -Path "HKCU:\Software\Adobe\Acrobat Reader\DC\IPM" -Name bShowMsgAtLaunch -PropertyType DWord -Value 0 -Force

# Callapse all tips on the main page
# Свернуть подсказки на главной странице
New-ItemProperty -Path "HKCU:\Software\Adobe\Acrobat Reader\DC\HomeWelcomeFirstMileReader" -Name bFirstMileMinimized -PropertyType DWord -Value 1 -Force

# Always use page Layout Style: "Single Pages Continuous"
# Всегда использовать стиль макета страницы: "Постранично непрерывно"
New-ItemProperty -Path "HKCU:\Software\Adobe\Acrobat Reader\DC\Originals" -Name iPageViewLayoutMode -PropertyType DWord -Value 2 -Force

# Turn on dark theme
# Включить темную тему
New-ItemProperty -Path "HKCU:\Software\Adobe\Acrobat Reader\DC\AVGeneral" -Name aActiveUITheme -PropertyType String -Value DarkTheme -Force
New-ItemProperty -Path "HKCU:\Software\Adobe\Acrobat Reader\DC\AVGeneral" -Name bHonorOSTheme -PropertyType DWord -Value 0 -Force

# Hide "Share" button lable from Toolbar
# Скрыть значок кнопки "Общий доступ" с панели инструментов
New-ItemProperty -Path "HKCU:\Software\Adobe\Acrobat Reader\DC\AVGeneral" -Name bHideShareButtonLabel -PropertyType DWord -Value 1 -Force

# Remember Task Pane state after document closed
# Запоминать состояние области задач после закрытия документа
New-ItemProperty -Path "HKCU:\Software\Adobe\Acrobat Reader\DC\AVGeneral" -Name bRHPSticky -PropertyType DWord -Value 1 -Force

# Restore last view settings when reopening documents
# Восстанавливать при открытии документов прежние параметры просмотра
if (-not (Test-Path -Path "HKCU:\Software\Adobe\Acrobat Reader\DC\RememberedViews"))
{
	New-Item -Path "HKCU:\Software\Adobe\Acrobat Reader\DC\RememberedViews" -Force
}
New-ItemProperty -Path "HKCU:\Software\Adobe\Acrobat Reader\DC\RememberedViews" -Name iRememberView -PropertyType DWord -Value 2 -Force
#endregion UI

#region Quick Tools
# Clear favorite Quick Tools (сommented out)
# Очистить Избранное на панели инструментов (закомментировано)
# Remove-ItemProperty -Path "HKCU:\Software\Adobe\Acrobat Reader\DC\AVGeneral\cFavoritesCommandsDesktop" -Name * -Force -ErrorAction SilentlyContinue

# Clear Quick Tools (сommented out)
# Очистить панель инструментов (закомментировано)
# Remove-ItemProperty -Path "HKCU:\Software\Adobe\Acrobat Reader\DC\AVGeneral\cCommonToolsDesktop" -Name * -Force -ErrorAction SilentlyContinue

# Show Quick Tools in Toolbar
# Отобразить инструменты быстрого доступа на панели инструментов
if (-not (Test-Path -Path "HKCU:\Software\Adobe\Acrobat Reader\DC\AVGeneral\cCommonToolsDesktop"))
{
	New-Item -Path "HKCU:\Software\Adobe\Acrobat Reader\DC\AVGeneral\cCommonToolsDesktop" -Force
}
$match = '^' + 'a' + '\d+'

# "Save file"
# "Сохранить файл"
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
# "Печатать файл"
[int]$int = ((Get-Item -Path "HKCU:\Software\Adobe\Acrobat Reader\DC\AVGeneral\cCommonToolsDesktop").Property | Where-Object -FilterScript {$_ -match $match}).Count
$names = (Get-Item -Path "HKCU:\Software\Adobe\Acrobat Reader\DC\AVGeneral\cCommonToolsDesktop").Property
if ((Get-ItemPropertyValue -Path "HKCU:\Software\Adobe\Acrobat Reader\DC\AVGeneral\cCommonToolsDesktop" -Name $names) -notcontains "Print")
{
	New-ItemProperty -Path "HKCU:\Software\Adobe\Acrobat Reader\DC\AVGeneral\cCommonToolsDesktop" -Name "a$int" -PropertyType String -Value Print -Force
}

# "Undo last change"
# "Отменить последнее изменение"
[int]$int = ((Get-Item -Path "HKCU:\Software\Adobe\Acrobat Reader\DC\AVGeneral\cCommonToolsDesktop").Property | Where-Object -FilterScript {$_ -match $match}).Count
$names = (Get-Item -Path "HKCU:\Software\Adobe\Acrobat Reader\DC\AVGeneral\cCommonToolsDesktop").Property
if ((Get-ItemPropertyValue -Path "HKCU:\Software\Adobe\Acrobat Reader\DC\AVGeneral\cCommonToolsDesktop" -Name $names) -notcontains "Undo")
{
	New-ItemProperty -Path "HKCU:\Software\Adobe\Acrobat Reader\DC\AVGeneral\cCommonToolsDesktop" -Name "a$int" -PropertyType String -Value Undo -Force
}

# "Redo last change"
# "Повторить последнее изменение"
[int]$int = ((Get-Item -Path "HKCU:\Software\Adobe\Acrobat Reader\DC\AVGeneral\cCommonToolsDesktop").Property | Where-Object -FilterScript {$_ -match $match}).Count
$names = (Get-Item -Path "HKCU:\Software\Adobe\Acrobat Reader\DC\AVGeneral\cCommonToolsDesktop").Property
if ((Get-ItemPropertyValue -Path "HKCU:\Software\Adobe\Acrobat Reader\DC\AVGeneral\cCommonToolsDesktop" -Name $names) -notcontains "Redo")
{
	New-ItemProperty -Path "HKCU:\Software\Adobe\Acrobat Reader\DC\AVGeneral\cCommonToolsDesktop" -Name "a$int" -PropertyType String -Value Redo -Force
}

# "Page number"
# "Номер страницы"
[int]$int = ((Get-Item -Path "HKCU:\Software\Adobe\Acrobat Reader\DC\AVGeneral\cCommonToolsDesktop").Property | Where-Object -FilterScript {$_ -match $match}).Count
$names = (Get-Item -Path "HKCU:\Software\Adobe\Acrobat Reader\DC\AVGeneral\cCommonToolsDesktop").Property
if ((Get-ItemPropertyValue -Path "HKCU:\Software\Adobe\Acrobat Reader\DC\AVGeneral\cCommonToolsDesktop" -Name $names) -notcontains "GoToPage")
{
	New-ItemProperty -Path "HKCU:\Software\Adobe\Acrobat Reader\DC\AVGeneral\cCommonToolsDesktop" -Name "a$int" -PropertyType String -Value GoToPage -Force
}
#endregion Quick Tools