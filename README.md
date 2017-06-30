# stayawake
Linux power management only considers local keyboard/mouse activity when configured to suspend/hibernate.  Cron runs this script every minute (or whatever interval you decide) and uses `xdotool` to perform small mouse movements if any SSH, Samba, or NFS activty is detected.

Please note that the script must be run as the user account normally logged onto the computer, as xdotool requires access to that users' desktop.

Example:
```
* * * * * scott /opt/scripts/stayawake/stayawake.sh > /dev/null 2>&1
```
