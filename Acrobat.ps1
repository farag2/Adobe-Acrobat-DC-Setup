# Remove Adobe Acrobat Pro DC update tasks from startup
# Удалить из автозагрузки задачи Adobe Acrobat Pro DC по обновлению
Remove-ItemProperty -Path HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Run -Name AdobeAAMUpdater-1.0 -Force -ErrorAction SilentlyContinue
Remove-ItemProperty -Path HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Run -Name AdobeGCInvoker-1.0 -Force -ErrorAction SilentlyContinue
Remove-ItemProperty -Path HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Run -Name "Acrobat Assistant 8.0" -Force -ErrorAction SilentlyContinue
Remove-ItemProperty -Path HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Run -Name "Acrobat Assistant 8.0" -Force -ErrorAction SilentlyContinue
# Remove Adobe Acrobat Pro DC from context menu
# Удалить пункты Adobe Acrobat Pro DC из контекстного меню
Start-Process -FilePath regsvr32.exe -ArgumentList "/u /s `"${env:ProgramFiles(x86)}\Adobe\Acrobat DC\Acrobat Elements\ContextMenuShim64.dll`""
# Turn off services
# Отключить службы
$services = @(
	"AdobeARMservice",
	"AGMService",
	"AGSService"
)
foreach ($service in $services)
{
	Get-Service -ServiceName $service | Stop-Service
	Get-Service -ServiceName $service | Set-Service -StartupType Disabled
}
# Disable update tasks
# Отключить задачи по обновлению
Get-ScheduledTask -TaskName "Adobe Acrobat Update Task" | Disable-ScheduledTask
Get-ScheduledTask -TaskName AdobeGCInvoker* | Disable-ScheduledTask
# Create a scheduled task to configure Adobe Acrobat Pro DC in Task Scheduler. The task runs every 31 days
# Создать в Планировщике задач задачу по настройке Adobe Acrobat Pro DC. Задача выполняется каждые 31 дней
$action = New-ScheduledTaskAction -Execute powershell.exe -Argument @"
	Get-Service -ServiceName AdobeARMservice | Stop-Service
	Get-Service -ServiceName AdobeARMservice | Set-Service -StartupType Disabled
	Stop-Process -Name acrotray -Force
	Get-ScheduledTask -TaskName "Adobe Acrobat Update Task" | Disable-ScheduledTask
	Get-ScheduledTask -TaskName AdobeGCInvoker* | Disable-ScheduledTask
	Remove-ItemProperty -Path HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Run -Name AdobeAAMUpdater-1.0 -Force
	Remove-ItemProperty -Path HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Run -Name AdobeGCInvoker-1.0 -Force
	Remove-ItemProperty -Path HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Run -Name "Acrobat Assistant 8.0" -Force
	Remove-ItemProperty -Path HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Run -Name "Acrobat Assistant 8.0" -Force
	regsvr32.exe /u /s '${env:ProgramFiles(x86)}\Adobe\Acrobat DC\Acrobat Elements\ContextMenuShim64.dll'
	Remove-ItemProperty HKLM:\SOFTWARE\Mozilla\Firefox\Extensions -Name "*acrobat.adobe.com" -Force
	Remove-Item -Path "${env:ProgramFiles(x86)}\Adobe\Acrobat DC\Acrobat\Browser" -Recurse -Force
	Remove-Item -Path "HKLM:\SOFTWARE\Microsoft\Office\Excel\Addins\PDFMaker.OfficeAddin" -Force
	Remove-Item -Path "HKLM:\SOFTWARE\Microsoft\Office\Outlook\Addins\AdobeAcroOutlook.SendAsLink" -Force
	Remove-Item -Path "HKLM:\SOFTWARE\Microsoft\Office\Outlook\Addins\PDFMOutlook.PDFMOutlook" -Force
	Remove-Item -Path "HKLM:\SOFTWARE\Microsoft\Office\PowerPoint\Addins\PDFMaker.OfficeAddin" -Force
	Remove-Item -Path "HKLM:\SOFTWARE\Microsoft\Office\Word\Addins\PDFMaker.OfficeAddin" -Force
	Remove-Item -Path "HKLM:\SOFTWARE\WOW6432Node\Microsoft\Office\Excel\Addins\PDFMaker.OfficeAddin" -Force
	Remove-Item -Path "HKLM:\SOFTWARE\WOW6432Node\Microsoft\Office\MS Project\Addins\PDFMaker.OfficeAddin" -Force
	Remove-Item -Path "HKLM:\SOFTWARE\WOW6432Node\Microsoft\Office\Outlook\Addins\AdobeAcroOutlook.SendAsLink" -Force
	Remove-Item -Path "HKLM:\SOFTWARE\WOW6432Node\Microsoft\Office\Outlook\Addins\PDFMOutlook.PDFMOutlook" -Force
	Remove-Item -Path "HKLM:\SOFTWARE\WOW6432Node\Microsoft\Office\PowerPoint\Addins\PDFMaker.OfficeAddin" -Force
	Remove-Item -Path "HKLM:\SOFTWARE\WOW6432Node\Microsoft\Office\Word\Addins\PDFMaker.OfficeAddin" -Force
"@
$trigger = New-ScheduledTaskTrigger -Daily -DaysInterval 31 -At 9am
$settings = New-ScheduledTaskSettingsSet -Compatibility Win8 -StartWhenAvailable
$principal = New-ScheduledTaskPrincipal -UserID System -RunLevel Highest
$params = @{
	"TaskName"	= "Acrobat Pro DC"
	"Action"	= $action
	"Trigger"	= $trigger
	"Settings"	= $settings
	"Principal"	= $principal
}
Register-ScheduledTask @params -Force
# Remove Firefox addons
# Удалить расширение в Firefox
Remove-ItemProperty HKLM:\SOFTWARE\Mozilla\Firefox\Extensions -Name "*acrobat.adobe.com" -Force -ErrorAction SilentlyContinue
Remove-Item -Path "${env:ProgramFiles(x86)}\Adobe\Acrobat DC\Acrobat\Browser" -Recurse -Force -ErrorAction SilentlyContinue
# Turn off both updates to the product's web-plugin components as well as all services
# Отключить обновление компонентов веб-плагинов, всех сервисов Adobe и вход в учетную запись
IF (-not (Test-Path -Path "HKLM:\SOFTWARE\Policies\Adobe\Adobe Acrobat\DC\FeatureLockdown\cServices"))
{
	New-Item -Path "HKLM:\SOFTWARE\Policies\Adobe\Adobe Acrobat\DC\FeatureLockdown\cServices" -Force
}
New-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Adobe\Adobe Acrobat\DC\FeatureLockdown\cServices" -Name bUpdater -Value 0 -Force
# Turn off all Document Cloud service access
# Отключить все сервисы Adobe Document Cloud
New-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Adobe\Adobe Acrobat\DC\FeatureLockdown\cServices" -Name bToggleAdobeDocumentServices -Value 1 -Force
# Turn off preference synchronization across devices
# Отключить синхронизацию между устройствами
New-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Adobe\Adobe Acrobat\DC\FeatureLockdown\cServices" -Name bTogglePrefsSync -Value 1 -Force
# Hide "Share" button lable from Toolbar
# Скрыть значок кнопки "Общий доступ" с панели инструментов
New-ItemProperty -Path "HKCU:\Software\Adobe\Adobe Acrobat\DC\AVGeneral" -Name bHideShareButtonLabel -Value 1 -Force
# Do not show messages from Adobe when the product launches
# Не показывать сообщения от Adobe при запуске
IF (-not (Test-Path -Path "HKCU:\Software\Adobe\Adobe Acrobat\DC\IPM"))
{
	New-Item -Path "HKCU:\Software\Adobe\Adobe Acrobat\DC\IPM" -Force
}
New-ItemProperty -Path "HKCU:\Software\Adobe\Adobe Acrobat\DC\HomeWelcomeFirstMile" -Name bShowMsgAtLaunch -Value 0 -Force
# Callapse all tips on the main page
# Свернуть подсказки на главной странице
IF (-not (Test-Path -Path "HKCU:\Software\Adobe\Adobe Acrobat\DC\HomeWelcomeFirstMile"))
{
	New-Item -Path "HKCU:\Software\Adobe\Adobe Acrobat\DC\HomeWelcomeFirstMile" -Force
}
New-ItemProperty -Path "HKCU:\Software\Adobe\Adobe Acrobat\DC\HomeWelcomeFirstMile" -Name bFirstMileMinimized -Value 1 -Force
# Always use page Layout Style: Single Pages Contininuous
# Всегда использовать стиль макета страницы: "Постранично непрерывно"
IF (-not (Test-Path -Path "HKCU:\Software\Adobe\Adobe Acrobat\DC\Access"))
{
	New-Item -Path "HKCU:\Software\Adobe\Adobe Acrobat\DC\Access" -Force
}
New-ItemProperty -Path "HKCU:\Software\Adobe\Adobe Acrobat\DC\Access" -Name bOverridePageLayout -Value 1 -Force
New-ItemProperty -Path "HKCU:\Software\Adobe\Adobe Acrobat\DC\Access" -Name iPageLayout -Value 2 -Force
# Remove Adobe Acrobat Pro DC shortcuts
# Удалить ярлыки Adobe Acrobat Pro DC
Remove-Item -Path "$env:PUBLIC\Desktop\*Acrobat*.lnk" -Force -ErrorAction SilentlyContinue
Remove-Item -Path "$env:ProgramData\Microsoft\Windows\Start Menu\Programs\Adobe Acrobat Distiller DC.lnk" -Force -ErrorAction SilentlyContinue
# Remove COM Add-Ins for Office
# Удалить надстройки COM Adobe Acrobat Pro DC для Office
Remove-Item -Path "HKLM:\SOFTWARE\Microsoft\Office\Excel\Addins\PDFMaker.OfficeAddin" -Force -ErrorAction SilentlyContinue
Remove-Item -Path "HKLM:\SOFTWARE\Microsoft\Office\Outlook\Addins\AdobeAcroOutlook.SendAsLink" -Force -ErrorAction SilentlyContinue
Remove-Item -Path "HKLM:\SOFTWARE\Microsoft\Office\Outlook\Addins\PDFMOutlook.PDFMOutlook" -Force -ErrorAction SilentlyContinue
Remove-Item -Path "HKLM:\SOFTWARE\Microsoft\Office\PowerPoint\Addins\PDFMaker.OfficeAddin" -Force -ErrorAction SilentlyContinue
Remove-Item -Path "HKLM:\SOFTWARE\Microsoft\Office\Word\Addins\PDFMaker.OfficeAddin" -Force -ErrorAction SilentlyContinue
Remove-Item -Path "HKLM:\SOFTWARE\WOW6432Node\Microsoft\Office\Excel\Addins\PDFMaker.OfficeAddin" -Force -ErrorAction SilentlyContinue
Remove-Item -Path "HKLM:\SOFTWARE\WOW6432Node\Microsoft\Office\MS Project\Addins\PDFMaker.OfficeAddin" -Force -ErrorAction SilentlyContinue
Remove-Item -Path "HKLM:\SOFTWARE\WOW6432Node\Microsoft\Office\Outlook\Addins\AdobeAcroOutlook.SendAsLink" -Force -ErrorAction SilentlyContinue
Remove-Item -Path "HKLM:\SOFTWARE\WOW6432Node\Microsoft\Office\Outlook\Addins\PDFMOutlook.PDFMOutlook" -Force -ErrorAction SilentlyContinue
Remove-Item -Path "HKLM:\SOFTWARE\WOW6432Node\Microsoft\Office\PowerPoint\Addins\PDFMaker.OfficeAddin" -Force -ErrorAction SilentlyContinue
Remove-Item -Path "HKLM:\SOFTWARE\WOW6432Node\Microsoft\Office\Word\Addins\PDFMaker.OfficeAddin" -Force -ErrorAction SilentlyContinue
# Collapse Task Pane
# Свернуть область задач
New-ItemProperty -Path "HKCU:\Software\Adobe\Adobe Acrobat\DC\AVGeneral" -Name aDefaultRHPViewModeL -Value AppSwitcherOnly -Force
# Left "Edit PDF" and "Organize Pages" only tools in the Task Pane
# Оставить в области задач только кнопки "Редактировать PDF" и "Систематизировать страницы"
Remove-ItemProperty -Path "HKCU:\Software\Adobe\Adobe Acrobat\DC\AcroApp\cFavorites" -Name * -Force
New-ItemProperty -Path "HKCU:\Software\Adobe\Adobe Acrobat\DC\AcroApp\cFavorites" -Name a0 -Value EditPDFApp -Force
New-ItemProperty -Path "HKCU:\Software\Adobe\Adobe Acrobat\DC\AcroApp\cFavorites" -Name a1 -Value PagesApp -Force
# Clear favorite Quick Tools
# Очистить Избранное на панели инструментов
Remove-ItemProperty -Path "HKCU:\Software\Adobe\Adobe Acrobat\DC\AVGeneral\cFavoritesCommandsDesktop" -Name * -Force -ErrorAction SilentlyContinue
# Clear Quick Tools
# Очистить панель инструментов
# Remove-ItemProperty -Path "HKCU:\Software\Adobe\Adobe Acrobat\DC\AVGeneral\cCommonToolsDesktop" -Name * -Force -ErrorAction SilentlyContinue
# Add Quick Tools:
# Добавить инструменты быстрого доступа:
IF (-not (Test-Path -Path "HKCU:\Software\Adobe\Adobe Acrobat\DC\AVGeneral\cCommonToolsDesktop"))
{
	New-Item -Path "HKCU:\Software\Adobe\Adobe Acrobat\DC\AVGeneral\cCommonToolsDesktop" -Force
}
$match = '^' + 'a' + '\d+'
# "Save file"
# "Сохранить файл"
[int]$int = ((Get-Item -Path "HKCU:\Software\Adobe\Adobe Acrobat\DC\AVGeneral\cCommonToolsDesktop").Property | Where-Object -FilterScript {$_ -match $match}).Count
$names = (Get-Item -Path "HKCU:\Software\Adobe\Adobe Acrobat\DC\AVGeneral\cCommonToolsDesktop").Property
IF ($names)
{
	IF ((Get-ItempropertyValue -Path "HKCU:\Software\Adobe\Adobe Acrobat\DC\AVGeneral\cCommonToolsDesktop" -Name $names) -notcontains "Save")
	{
		New-ItemProperty -Path "HKCU:\Software\Adobe\Adobe Acrobat\DC\AVGeneral\cCommonToolsDesktop" -Name "a$int" -PropertyType String -Value Save -Force
	}
}
Else
{
	New-ItemProperty -Path "HKCU:\Software\Adobe\Adobe Acrobat\DC\AVGeneral\cCommonToolsDesktop" -Name "a0" -PropertyType String -Value Save -Force
}
# "Print file"
# "Печатать файл"
[int]$int = ((Get-Item -Path "HKCU:\Software\Adobe\Adobe Acrobat\DC\AVGeneral\cCommonToolsDesktop").Property | Where-Object -FilterScript {$_ -match $match}).Count
$names = (Get-Item -Path "HKCU:\Software\Adobe\Adobe Acrobat\DC\AVGeneral\cCommonToolsDesktop").Property
IF ((Get-ItempropertyValue -Path "HKCU:\Software\Adobe\Adobe Acrobat\DC\AVGeneral\cCommonToolsDesktop" -Name $names) -notcontains "Print")
{
	New-ItemProperty -Path "HKCU:\Software\Adobe\Adobe Acrobat\DC\AVGeneral\cCommonToolsDesktop" -Name "a$int" -PropertyType String -Value Print -Force
}
# "Undo last change"
# "Отменить последнее изменение"
[int]$int = ((Get-Item -Path "HKCU:\Software\Adobe\Adobe Acrobat\DC\AVGeneral\cCommonToolsDesktop").Property | Where-Object -FilterScript {$_ -match $match}).Count
$names = (Get-Item -Path "HKCU:\Software\Adobe\Adobe Acrobat\DC\AVGeneral\cCommonToolsDesktop").Property
IF ((Get-ItempropertyValue -Path "HKCU:\Software\Adobe\Adobe Acrobat\DC\AVGeneral\cCommonToolsDesktop" -Name $names) -notcontains "Undo")
{
	New-ItemProperty -Path "HKCU:\Software\Adobe\Adobe Acrobat\DC\AVGeneral\cCommonToolsDesktop" -Name "a$int" -PropertyType String -Value Undo -Force
}
# "Redo last change"
# "Повторить последнее изменение"
[int]$int = ((Get-Item -Path "HKCU:\Software\Adobe\Adobe Acrobat\DC\AVGeneral\cCommonToolsDesktop").Property | Where-Object -FilterScript {$_ -match $match}).Count
$names = (Get-Item -Path "HKCU:\Software\Adobe\Adobe Acrobat\DC\AVGeneral\cCommonToolsDesktop").Property
IF ((Get-ItempropertyValue -Path "HKCU:\Software\Adobe\Adobe Acrobat\DC\AVGeneral\cCommonToolsDesktop" -Name $names) -notcontains "Redo")
{
	New-ItemProperty -Path "HKCU:\Software\Adobe\Adobe Acrobat\DC\AVGeneral\cCommonToolsDesktop" -Name "a$int" -PropertyType String -Value Redo -Force
}
# "Page number"
# "Номер страницы"
[int]$int = ((Get-Item -Path "HKCU:\Software\Adobe\Adobe Acrobat\DC\AVGeneral\cCommonToolsDesktop").Property | Where-Object -FilterScript {$_ -match $match}).Count
$names = (Get-Item -Path "HKCU:\Software\Adobe\Adobe Acrobat\DC\AVGeneral\cCommonToolsDesktop").Property
IF ((Get-ItempropertyValue -Path "HKCU:\Software\Adobe\Adobe Acrobat\DC\AVGeneral\cCommonToolsDesktop" -Name $names) -notcontains "GoToPage")
{
	New-ItemProperty -Path "HKCU:\Software\Adobe\Adobe Acrobat\DC\AVGeneral\cCommonToolsDesktop" -Name "a$int" -PropertyType String -Value GoToPage -Force
}
# "Rotate counterclockwise; change is saved"
# "Повернуть текущий вид против часовой стрелке; изменение сохранено"
IF (-not (Test-Path -Path "HKCU:\Software\Adobe\Adobe Acrobat\DC\AVGeneral\cFavoritesCommandsDesktop"))
{
	New-Item -Path "HKCU:\Software\Adobe\Adobe Acrobat\DC\AVGeneral\cFavoritesCommandsDesktop" -Force
}
[int]$int = ((Get-Item -Path "HKCU:\Software\Adobe\Adobe Acrobat\DC\AVGeneral\cFavoritesCommandsDesktop").Property | Where-Object -FilterScript {$_ -match $match}).Count
$names = (Get-Item -Path "HKCU:\Software\Adobe\Adobe Acrobat\DC\AVGeneral\cFavoritesCommandsDesktop").Property
IF ($names)
{
	IF ((Get-ItempropertyValue -Path "HKCU:\Software\Adobe\Adobe Acrobat\DC\AVGeneral\cFavoritesCommandsDesktop" -Name $names) -notcontains "RotatePagesCCW")
	{
		New-ItemProperty -Path "HKCU:\Software\Adobe\Adobe Acrobat\DC\AVGeneral\cFavoritesCommandsDesktop" -Name "a$int" -PropertyType String -Value RotatePagesCCW -Force
	}
}
Else
{
	New-ItemProperty -Path "HKCU:\Software\Adobe\Adobe Acrobat\DC\AVGeneral\cFavoritesCommandsDesktop" -Name "a0" -PropertyType String -Value RotatePagesCCW -Force
}
# "Rotate clockwise; change is saved"
# "Повернуть текущий вид по часовой стрелке; изменение сохранено"
[int]$int = ((Get-Item -Path "HKCU:\Software\Adobe\Adobe Acrobat\DC\AVGeneral\cFavoritesCommandsDesktop").Property | Where-Object -FilterScript {$_ -match $match}).Count
$names = (Get-Item -Path "HKCU:\Software\Adobe\Adobe Acrobat\DC\AVGeneral\cFavoritesCommandsDesktop").Property
IF ((Get-ItempropertyValue -Path "HKCU:\Software\Adobe\Adobe Acrobat\DC\AVGeneral\cFavoritesCommandsDesktop" -Name $names) -notcontains "RotatePagesCW")
{
	New-ItemProperty -Path "HKCU:\Software\Adobe\Adobe Acrobat\DC\AVGeneral\cFavoritesCommandsDesktop" -Name "a$int" -PropertyType String -Value RotatePagesCW -Force
}
