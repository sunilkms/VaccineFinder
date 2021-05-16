# VaccineFinder

### Find the Covid vaccine center in India.

This script uses the Cowin public APIs to fetch the vaccine availability, script checks for the available center every one minute, you can adjust the frequency in the script if need to increase.
Once the centers are available, the script will show system notification on available vaccine slot for the requested PINs in system Notification area and will play a sound.

### Usage

* update the pin codes in the "PINs.txt" file
* run the bat file "Start_Vaccine_center_Monitor.bat"
* list centers name in the "Exception_not_play_sound_for_these_centers.txt" file to disable the sound playing
* run the "Stop_Vaccine_center_Monitor.bat" to stop the script

*NOTE: Notification feature is supported on Windows 10*
