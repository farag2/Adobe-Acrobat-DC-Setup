# Improved PowerShell Script for Adobe Acrobat Reader/Pro DC Configuration
# Includes: Admin check, modular functions, logging, and error handling

# Check if the script is running with Administrator privileges
function Ensure-Admin {
    if (-not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
        Write-Warning "This script must be run as Administrator."
        exit 1
    }
}

# Stop Adobe ARM Service
function Stop-AdobeARMService {
    Write-Host "Stopping AdobeARMservice if running..."
    try {
        Get-Service -Name AdobeARMservice -ErrorAction Stop | Stop-Service -Force
    } catch {
        Write-Host "AdobeARMservice is not running or not found."
    }
}

# Run Adobe CleanUp Utility if available
function Run-AdobeCleanUpUtility {
    $utilityPath = "${env:ProgramFiles(x86)}\Common Files\Adobe\AdobeGCClient\AdobeCleanUpUtility.exe"
    if (Test-Path -Path $utilityPath) {
        Write-Host "Running Adobe CleanUp Utility..."
        Start-Process -FilePath $utilityPath -Wait
    } else {
        Write-Host "Adobe CleanUp Utility not found."
    }
}

# Accept EULA
function Accept-EULA {
    $viewerPath = "HKCU:\Software\Adobe\Adobe Acrobat\DC\AdobeViewer"
    if ((Get-ItemPropertyValue -Path "HKLM:\SOFTWARE\Adobe\Adobe Acrobat\DC\RDCNotificationAppx" -Name AppPackageName -ErrorAction SilentlyContinue) -notmatch "Reader") {
        if (-not (Test-Path -Path $viewerPath)) {
            New-Item -Path $viewerPath -Force
        }
        New-ItemProperty -Path $viewerPath -Name EULA -PropertyType DWord -Value 1 -Force
        Write-Host "EULA accepted."
    }
}

# Apply UI Preferences
function Set-UIPreferences {
    Write-Host "Configuring UI preferences..."

    # Suppress launch messages
    $ipmPath = "HKCU:\Software\Adobe\Adobe Acrobat\DC\IPM"
    if (-not (Test-Path -Path $ipmPath)) { New-Item -Path $ipmPath -Force }
    New-ItemProperty -Path $ipmPath -Name bShowMsgAtLaunch -PropertyType DWord -Value 0 -Force

    # Collapse tips
    New-ItemProperty -Path "HKCU:\Software\Adobe\Adobe Acrobat\DC\HomeWelcomeFirstMile" -Name bFirstMileMinimized -PropertyType DWord -Value 1 -Force

    # Set page layout mode
    New-ItemProperty -Path "HKCU:\Software\Adobe\Adobe Acrobat\DC\Originals" -Name iPageViewLayoutMode -PropertyType DWord -Value 2 -Force

    # Enable dark theme
    $avPath = "HKCU:\Software\Adobe\Adobe Acrobat\DC\AVGeneral"
    New-ItemProperty -Path $avPath -Name aActiveUITheme -PropertyType String -Value DarkTheme -Force
    New-ItemProperty -Path $avPath -Name bHonorOSTheme -PropertyType DWord -Value 0 -Force
    New-ItemProperty -Path $avPath -Name bHideShareButtonLabel -PropertyType DWord -Value 1 -Force

    # Determine Acrobat type and apply task pane settings
    $appType = Get-ItemPropertyValue -Path "HKLM:\SOFTWARE\Adobe\Adobe Acrobat\DC\RDCNotificationAppx" -Name AppPackageName -ErrorAction SilentlyContinue

    if ($appType -match "Reader") {
        New-ItemProperty -Path $avPath -Name bRHPSticky -PropertyType DWord -Value 1 -Force
    } else {
        New-ItemProperty -Path $avPath -Name aDefaultRHPViewModeL -PropertyType String -Value AppSwitcherOnly -Force

        # Set Task Pane favorites
        $favPath = "HKCU:\Software\Adobe\Adobe Acrobat\DC\AcroApp\cFavorites"
        Remove-ItemProperty -Path $favPath -Name * -Force -ErrorAction SilentlyContinue
        New-ItemProperty -Path $favPath -Name a0 -PropertyType String -Value EditPDFApp -Force
        New-ItemProperty -Path $favPath -Name a1 -PropertyType String -Value PagesApp -Force

        # Remember view settings
        $viewsPath = "HKCU:\Software\Adobe\Adobe Acrobat\DC\RememberedViews"
        if (-not (Test-Path -Path $viewsPath)) { New-Item -Path $viewsPath -Force }
        New-ItemProperty -Path $viewsPath -Name iRememberView -PropertyType DWord -Value 2 -Force
    }
}

# Run all setup steps
function Main {
    Ensure-Admin
    Stop-AdobeARMService
    Run-AdobeCleanUpUtility
    Accept-EULA
    Set-UIPreferences
    Write-Host "Adobe configuration completed."
}

# Start script
Main
