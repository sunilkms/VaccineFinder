echo 0 > stop.cfg
powershell.exe -WindowStyle hidden -ExecutionPolicy Bypass -STA -NoProfile -File "Find_Covid_Vaccine_Centers.ps1"
