# COVID Vaccine Finder
# 
# Author : Sunil Chauhan <sunilkms@gmail.com>
# THis code is provide as is without any warranty of any kind.
# <About> this script will find and show the avaiable covid vaccine slots every 5 min and will pop up a window with all available slots.
# Usage: Find_Covid_Vaccnine_Centers.ps1 -Pin 201301

param ($PIN='201301',[switch]$showall)
Write-Warning "NOTE: By default only 18+ slots are visible to include 45+ use switch '-ShowAll'"
do {

$date=get-date -Format dd-MM-yyyy
Write-Host "checking available Centers for $pin" -ForegroundColor Green

#$RequestURl="https://cdn-api.co-vin.in/api/v2/appointment/sessions/public/findByPin?pincode=$PIN&date=$DATE"
$RequestURl="https://cdn-api.co-vin.in/api/v2/appointment/sessions/public/calendarByPin?pincode=$PIN&date=$DATE"
$webRequest=Invoke-WebRequest $RequestURl
$centers=($webrequest.Content | ConvertFrom-Json).centers
#$centers[0]
$c=0
#centers including availability
$CIA=$centers | % { $_.sessions | select @{n="Center";E={$($centers[$c].name)}}, Date,min_age_limit,vaccine,available_capacity ;$C++ } | sort date

if ($showall) 
        {
        #All centers no age limit
        $available=$CIA | ? {$_.available_capacity -ne 0}
        } 
   else {
        #All centers with age limit 18+ 
        $18plusAllcenters=$CIA | ? {$_.min_age_limit -eq 18}
        #find available slots
        $available=$18plusAllcenters | ? {$_.available_capacity -ne 0}
        }

if ($available){$available | Out-GridView -Title "Available centers for $PIN" -PassThru} else {
Write-Host "Nothing found wating for 5 min..." -ForegroundColor Yellow
sleep 300
} 
} until ($available)
