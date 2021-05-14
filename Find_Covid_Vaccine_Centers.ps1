# COVID Vaccine Finder
# 
# Author : Sunil Chauhan <sunilkms@gmail.com>
# THis code is provide as is without any warranty of any kind.
# <About> this script will find and show the avaiable covid vaccine slots every 5 min and will pop up a window with all available slots.
# Update: add multiple pins to search and play sound when there is availability.
# Usage:
# Show 18+ age group
# Find_Covid_Vaccnine_Centers.ps1 -Pin 201301",121001,110025
# #Show all age group
# Find_Covid_Vaccnine_Centers.ps1 -Pin 201301",121001,110025

param (
        $PINs=(201301,203207,201310),
        [switch]$showall
      )

Add-Type -AssemblyName  System.Windows.Forms 
$global:balloon = New-Object System.Windows.Forms.NotifyIcon
[void](Register-ObjectEvent  -InputObject $balloon  -EventName MouseDoubleClick  -SourceIdentifier IconClicked  -Action {
  #Perform  cleanup actions on balloon tip
  $global:balloon.dispose()
  Unregister-Event  -SourceIdentifier IconClicked
  Remove-Job -Name IconClicked
  Remove-Variable  -Name balloon  -Scope Global
})

function ShowNotification {
param ($msg=,$title)
$path = (Get-Process -id $pid).Path
  $balloon.Icon  = [System.Drawing.Icon]::ExtractAssociatedIcon($path)
  #[System.Windows.Forms.ToolTipIcon] | Get-Member -Static -Type Property 
  $balloon.BalloonTipIcon  = [System.Windows.Forms.ToolTipIcon]::Info
  $balloon.BalloonTipText  = $msg
  $balloon.BalloonTipTitle  =$title
  $balloon.Visible  = $true 
  $balloon.ShowBalloonTip(100000)
  #$balloon.Dispose()
}

Write-Warning "By default only 18+ slots are visible to include 45+ use switch '-ShowAll'"

$x=1
$y=2

# go in infinite loop
do {

#search for each pin

foreach ($pin in $pins) 
    {

    $date=get-date -Format dd-MM-yyyy # get today's date.
    #$d=(get-date).AddDays(+1) # get next day date "No poing wasting one future slot"
    #$date=($d.day,$d.Month,$d.year -join "-")

    Write-Host " $(get-date) Checking available Centers for $pin from start date $date" -ForegroundColor Green

    #url for a single day
    #$RequestURl="https://cdn-api.co-vin.in/api/v2/appointment/sessions/public/findByPin?pincode=$PIN&date=$DATE"

    #Request url for the 7 days
    $RequestURl="https://cdn-api.co-vin.in/api/v2/appointment/sessions/public/calendarByPin?pincode=$PIN&date=$DATE"
    $webRequest=Invoke-WebRequest $RequestURl
    $centers=($webrequest.Content | ConvertFrom-Json).centers

    $c=0
    #centers including availability
    $CIA=$centers | % { $_.sessions | select @{n="Center Name";E={$($centers[$c].name)}}, Date,min_age_limit,vaccine,available_capacity ;$C++ } | sort date

        if ($showall) 
                {
                    #All centers no age limit
                    $available=$CIA | ? {$_.available_capacity -ne 0}
                } 
        else    {
                    #All centers with age limit 18+ 
                    $18plusAllcenters=$CIA | ? {$_.min_age_limit -eq 18}
                    #find available slots
                    $available=$18plusAllcenters | ? {$_.available_capacity -ne 0}
                }

                    if ($available)
                            {
                                Write-Host "Center Found $(Get-date)"
                                #[console]::beep(1000,500) #play beep
                                $PlayWav=New-Object System.Media.SoundPlayer
                                $soundfileLocation="C:\Windows\Media\Ring03.wav"
                                $PlayWav.SoundLocation=$soundfileLocation
                                $PlayWav.Play()
                                $available | ft -AutoSize                                
                                $Title="Slots Found for $PIN"
                                $msg=$available | % { $_.'center name' + " "  + $_.'date' + " " + $_.vaccine + " " + $_.available_capacity }                             
                                ShowNotification -msg $Msg -title $Title
                            }     
     }

    Write-Host "Wating for 60 sec..." -ForegroundColor Yellow
    sleep 60

} until ($x -eq $y)
