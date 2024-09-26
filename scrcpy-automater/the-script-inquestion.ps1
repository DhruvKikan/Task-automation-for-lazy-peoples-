Write-Host "Starting script, v2 by Shrigma and Skibidiboss"
# $output = bash -c "/mnt/c/Programming/Tools/scrcpy/adb.exe devices | tail -n 2 | head -n 1 | awk '{print \`$1}'"
$out = C:\Programming\Tools\scrcpy\adb.exe devices | Select-Object -Last 2  | Select-Object -Skiplast 1
$output = ($out -split "\s")[0]
Write-Host "Man this took some time, but we are finally BACCCCCCK"
if ($output -eq "162e71aa") {
    Write-Host "Device Found, starting scrcpy"
    Start-Sleep -Seconds 3
    Start-Process "C:\Programming\Tools\scrcpy\scrcpy.exe" -ArgumentList "-s 162e71aa"
} else {
    Write-Host "Device not found yet. Retry bitch"
    Start-Sleep -Seconds 3
}
exit
