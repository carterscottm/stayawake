#!/bin/bash

# If the output of this function changes between two successive runs of this
# script, we inhibit auto-suspend.
function check_activity()
{
  /usr/sbin/nfsstat -c -3
}

# Prevent the automatic suspend from kicking in.
function inhibit_suspend()
{
  # Slightly jiggle the mouse pointer about; we do a small step and
  # reverse step to try to stop this being annoying to anyone using the
  # PC. TODO: This isn't ideal, apart from being a bit hacky it stops
  # the screensaver kicking in as well, when all we want is to stop
  # the PC suspending. Can 'caffeine' help?
  export DISPLAY=:0.0
  xdotool mousemove_relative --sync --  10  10
  xdotool mousemove_relative --sync -- -10 -10
}

CWD=`dirname $(realpath $0)`
LOG="$CWD/stayawake.log"
ACTIVITYFILE1="$CWD/stayawake.1"
ACTIVITYFILE2="$CWD/stayawake.2"

TMP=$(tail -n 197 $LOG 2>/dev/null) && echo "${TMP}" > $LOG

echo "" >> $LOG
echo "Started run at $(date)" >> $LOG
if [ $(ss state established '( sport = 22 or sport = 445 )' | wc -l) -gt 1 ]; then
  echo "SSH and/or Samba session(s) active, inhibiting suspend." >> $LOG
  inhibit_suspend
  exit 1;
else
  if [ ! -f "$ACTIVITYFILE1" ]; then
    check_activity > "$ACTIVITYFILE1"
    exit 0;
  fi
  /bin/mv "$ACTIVITYFILE1" "$ACTIVITYFILE2"
  check_activity > "$ACTIVITYFILE1"
  if cmp --quiet "$ACTIVITYFILE1" "$ACTIVITYFILE2"; then
    echo "No activity detected since last run" >> $LOG
  else
    echo "Activity detected since last run; preventing suspend." >> $LOG
    inhibit_suspend
    exit 1;
  fi
  exit 0;
fi
