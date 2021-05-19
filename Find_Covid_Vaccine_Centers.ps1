#---------------------------------------------------------------------------------------------------------------------------------------
#---------------------------------------------------------------------------------------------------------------------------------------
#
# COVID Vaccine Finder
# Author : Sunil Chauhan <sunilkms@gmail.com>
# THis code is provide as is without any warranty of any kind.
# <About> this script will find and show the avaiable covid vaccine slots every 5 min and will pop up a window with all available slots.
# Update: add multiple pins to search and play sound when there is availability.

# Usage:
# Show 18+ age group
# Find_Covid_Vaccnine_Centers.ps1 -PINs 201301",121001,110025
# #Show all age group
# Find_Covid_Vaccnine_Centers.ps1 -PINs 201301",121001,110025 -ShowAll
#
#----------------------------------------------------------------------------------------------------------------------------------------
#----------------------------------------------------------------------------------------------------------------------------------------

param (
        $PINs=(gc Pins.cfg),
        [switch]$showall,
        $CheckAgaininMin=1
      )

#Clear-Content logs.log 
Start-Transcript -Path $((Get-Location).Path + "\Logs.log") -Force

try {
        
        Add-Type -AssemblyName  System.Windows.Forms 
        $global:balloon = New-Object System.Windows.Forms.NotifyIcon
        [void](Register-ObjectEvent -InputObject $balloon -EventName MouseDoubleClick -SourceIdentifier IconClicked -ErrorAction SilentlyContinue -Action {  
        #Perform  cleanup actions on balloon tip
        $global:balloon.dispose()
        Unregister-Event  -SourceIdentifier IconClicked
        Remove-Job -Name IconClicked
        Remove-Variable -Name balloon -Scope Global
        }) 

} catch {""}

function ShowNotification {
    
    param ($msg,$title)

    $path = (Get-Process -id $pid).Path
    $balloon.Icon  = [System.Drawing.Icon]::ExtractAssociatedIcon($path)
    #[System.Windows.Forms.ToolTipIcon] | Get-Member -Static -Type Property 
    #$balloon.BalloonTipIcon  = [System.Windows.Forms.ToolTipIcon]::Info
    $balloon.BalloonTipText  = $msg
    $balloon.BalloonTipTitle  =$title
    $balloon.Visible  = $true 
    $balloon.ShowBalloonTip(2000)
    #$balloon.Dispose()

    }

function playsound {

         $PlayWav=New-Object System.Media.SoundPlayer
         $soundfileLocation="C:\Windows\Media\Ring03.wav"
         $PlayWav.SoundLocation=$soundfileLocation
         $PlayWav.Play()

}

ShowNotification -title "Starting Vaccine Center Finder" -msg "You will be notified once the slot for the $(($PINs) -join "," ) is available"
Write-Warning "By default only 18+ slots are visible to include 45+ use switch '-ShowAll'"

$y=1
# go in infinite loop
do {

#loop Variables
$exitloop=[int]$(Get-Content -Path stop.cfg) # -eq 1
$PINs=(gc Pins.cfg)
#search for each pin
foreach ($pin in $pins) 
    {

    $date=get-date -Format dd-MM-yyyy # get today's date.
    #$d=(get-date).AddDays(+1) # get next day date "No poing wasting one future slot"
    #$date=($d.day,$d.Month,$d.year -join "-")

    Write-Host " $(get-date) Checking available Centers for $pin from start date $date" -ForegroundColor Green
    # $pin=201301
    #Request url for the 7 days Calendar
    $RequestURl="https://cdn-api.co-vin.in/api/v2/appointment/sessions/public/calendarByPin?pincode=$PIN&date=$DATE"
    $webRequest=Invoke-WebRequest $RequestURl
    $centers=($webrequest.Content | ConvertFrom-Json).centers
   
    #$d=(get-date).AddDays(+7) # get next 8 to 14 days
    #$date=($d.day,$d.Month,$d.year -join "-")
    #$RequestURl="https://cdn-api.co-vin.in/api/v2/appointment/sessions/public/calendarByPin?pincode=$PIN&date=$DATE"
    #$webRequest=Invoke-WebRequest $RequestURl
    #$centers+=($webrequest.Content | ConvertFrom-Json).centers

    $c=0
    #All centers for posted Pin Code
    $AllCenters=$centers | % { $_.sessions | select @{n="Center Name";E={$($centers[$c].name)}}, Date,min_age_limit,vaccine,available_capacity ;$C++ } | sort date

        if ($showall) 
                {
                    #All centers no age limit
                    $available=$AllCenters | ? {$_.available_capacity -ne 0}
                } 
        else    {
                    #All centers with age limit 18+ 
                    $18plusAllcenters=$AllCenters | ? {$_.min_age_limit -eq 18}
                    #find available slots
                    $available=$18plusAllcenters | ? {$_.available_capacity -ne 0}
                }

                    if ($available)
                            {
                                Write-Host "Center Found $(Get-date) - PIN:$pin"
                                #[console]::beep(1000,500) #play beep
                                $available | ft -AutoSize                                 
                                $available | % {
                                if (!($_.'center name' -match ((gc Exclude_notification_for_centers.cfg) -join "|") )) {
                                if ([int](gc NoSound.cfg) -ne 1){playsound}
                                $preferredVac=ipcsv .\Vaccines.cfg | ? {$_.isPriority -eq "True"}                                                                
                                if  ($_.vaccine -match $($preferredVac.Name -join "|")) {playsound} 
                                $msg=$_.'center name' + " " + " " + $_.vaccine;
                                $Title="$($_.available_capacity) Slots found for $PIN on $($_.'date')" 
                                ShowNotification -msg $Msg -title $Title }
                                }                             
                                
                            }     
     }

    if ($exitloop -ne 1) 
            {
            Write-Host "Wating for 60 sec..." -ForegroundColor Yellow;
            sleep $(60*$CheckAgaininMin)
            }

} until ($exitloop -eq $y)

if ($exitloop -eq 1) {Stop-Transcript;ShowNotification -title "Good Bye <:) !!" -msg "Vaccine monitor is now stoped."}