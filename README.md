# VaccineFinder

### Find the Covid vaccine center in India.

This script uses the Cowin public APIs to fetch the vaccine availability, script checks for the available center every one minute, you can adjust the frequency in the script if need to increase.
Once the centers are available, the script will show system notification on available vaccine slot for the requested PINs in system Notification area and will play a sound.

### Usage

* Update the pin codes in the "PINs.txt" file
* Run the bat file "Start_Vaccine_center_Monitor.bat"
* List centers name in the "Exclude_notification_for_centers.cfg" file to disable the sound playing
* Run the "Stop_Vaccine_center_Monitor.bat" to stop the script
* Run "Stop_sound.bat" to stop notification sound, *Sound is enabled bydefault with every run*

*NOTE: Notification feature is supported on Windows 10*
