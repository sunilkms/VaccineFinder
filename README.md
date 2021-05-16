# VaccineFinder

### Find the Covid vaccine center in India.

Download the full package, and update the pin codes in the "PINs.txt" file. 
Then run the bat file "Start_Vaccine_center_Monitor.bat" to run the program in the background.
Or you can run the ps1 script file directly in the Powershell session on your system.
The script will show system notification on availability of vaccine slot for the requested PINs in system Notification area and will play a sound.

by default script looks for slot every minute, you can adjust the frequency in script.

*NOTE: Notification feature is supported on Windows 10, by default script will show only the 18+ centres, to show for all run the script the -showall paramiters in the powershell session. or add "-showall" after the script name in cmd.*
