<#
.SYNOPSIS
    Interactive ADB and scrcpy manager for wired and wireless hybrid server nodes.
.DESCRIPTION
    Lists raw connected devices and lets the user explicitly input the target ID manually.
.USAGE
    .\scrcpy-connector.ps1
.AUTHOR
    Shrigma and Skibidiboss
#>

param (
    [switch]$Help
)

# --- CONFIGURATION ---
$ADB_PATH    = "C:\Programming\Tools\scrcpy\adb.exe"
$SCRCPY_PATH = "C:\Programming\Tools\scrcpy\scrcpy.exe"

# --- HELP MENU DISPLAY ---
if ($Help) {
    Clear-Host
    Write-Host "====================================================================" -ForegroundColor Cyan
    Write-Host "                scrcpy-connector.ps1 - HELP & USAGE                 " -ForegroundColor Black -BackgroundColor Cyan
    Write-Host "====================================================================" -ForegroundColor Cyan
    Write-Host "1. WIRED MODE:" -ForegroundColor Yellow
    Write-Host "   Plug device in via USB, copy the serial shown, and paste it at the prompt."
    Write-Host ""
    Write-Host "2. WIRELESS ADB SET UP:" -ForegroundColor Yellow
    Write-Host "   Keep USB plugged in, choose Option [W]. Provide target serial and IP."
    Write-Host ""
    Write-Host "3. SYSTEM TELEMETRY PURGE:" -ForegroundColor Yellow
    Write-Host "   Choose Option [P] to execute the deep debloat package sequence manually."
    Write-Host "====================================================================" -ForegroundColor Cyan
    exit
}

Clear-Host
Write-Host "Starting script, v2 by Shrigma and Skibidiboss" -ForegroundColor Magenta
Write-Host "Man this took some time, but we are finally BACCCCCCK`n" -ForegroundColor Green

# --- RAW ADB OUTPUT LAYER ---
Write-Host "--- CURRENT ATTACHED ADB DEVICES (RAW) ---" -ForegroundColor Cyan
& $ADB_PATH devices
Write-Host "------------------------------------------`n" -ForegroundColor Cyan

# --- USER MANUAL IDENTIFICATION ---
Write-Host "Please enter or paste your Target Device ID / Network IP" -ForegroundColor White
$targetDevice = (Read-Host "(e.g., ZD2226PJKV or 192.168.1.50:5555)").Trim()

if (-not $targetDevice) {
    Write-Host "[!] No target entered. Exiting session." -ForegroundColor Red
    Start-Sleep -Seconds 2
    exit
}

# --- ACTION MANAGER ---
Write-Host "`nTarget Locked: $targetDevice" -ForegroundColor Yellow
Write-Host "Choose action: [S]tart scrcpy | [W]ireless Handshake | [P]urge Telemetry | [E]xit: " -NoNewline
$action = Read-Host

switch ($action.ToUpper()) {
    "S" {
        Write-Host "`nLaunching scrcpy remote viewport window..." -ForegroundColor Green
        Write-Host "Keep this console window open. Closing it will disconnect your stream." -ForegroundColor DarkGray
        
        Start-Process $SCRCPY_PATH -ArgumentList "-s $targetDevice --always-on-top --video-bit-rate=4M" -NoNewWindow -Wait
        
        Write-Host "`nStream viewport closed." -ForegroundColor Yellow
        Write-Host "Press any key to exit the script..." -ForegroundColor Gray
        $null = [Console]::ReadKey($true)
    }
    "W" {
        Write-Host "Enabling device network listening protocol..." -ForegroundColor Cyan
        & $ADB_PATH -s $targetDevice tcpip 5555
        $phoneIP = Read-Host "Enter your Phone's Wi-Fi IP address (Check Settings -> About -> Status)"
        Write-Host "Establishing standalone network socket link..." -ForegroundColor Green
        & $ADB_PATH connect "${phoneIP}:5555"
        Write-Host "You can now safely pull the USB cable out!" -ForegroundColor Yellow
        Start-Sleep -Seconds 4
    }
    "P" {
        Write-Host "Executing clean environment telemetry purge on $targetDevice..." -ForegroundColor Yellow
        $purgeList = @(
            "com.tmobile.echolocate.system", "com.inmobi.installer", "com.aura.oobe.motorola",
            "com.motorola.appforecast", "com.motorola.motocare", "com.motorola.bug2go",
            "com.motorola.genie", "com.motorola.discovery", "com.motorola.spaces",
            "com.motorola.brapps", "com.motorola.demo", "com.lenovo.lsf.user",
            "com.motorola.help.extlog", "com.motorola.mototour", "com.motorola.android.nativedropboxagent",
            "com.motorola.lifetimedata", "com.facebook.appmanager", "com.facebook.services", "com.facebook.system"
        )
        foreach ($pkg in $purgeList) {
            Write-Host "Uninstalling $pkg..." -ForegroundColor Gray
            & $ADB_PATH -s $targetDevice shell pm uninstall -k --user 0 $pkg | Out-Null
        }
        # Freeze stubborn stubs
        & $ADB_PATH -s $targetDevice shell cmd appops set com.amazon.appmanager RUN_IN_BACKGROUND ignore | Out-Null
        & $ADB_PATH -s $targetDevice shell cmd appops set com.payjoy.access RUN_IN_BACKGROUND ignore | Out-Null
        & $ADB_PATH -s $targetDevice shell am force-stop com.amazon.appmanager | Out-Null
        & $ADB_PATH -s $targetDevice shell am force-stop com.payjoy.access | Out-Null
        & $ADB_PATH -s $targetDevice shell pm clear com.amazon.appmanager | Out-Null
        & $ADB_PATH -s $targetDevice shell pm clear com.payjoy.access | Out-Null
        Write-Host "Purge phase completed successfully!" -ForegroundColor Green
        Start-Sleep -Seconds 3
    }
    Default {
        Write-Host "Exiting session." -ForegroundColor Red
    }
}

exit
