#!/bin/bash
##############################################################################################################
#  ____                                      _       
# | __ )  __ _ _ __ _ __ __ _  ___ _   _  __| | __ _ 
# |  _ \ / _` | `__| `__/ _` |/ __| | | |/ _` |/ _` |
# | |_) | (_| | |  | | | (_| | (__| |_| | (_| | (_| |
# |____/ \__,_|_|  |_|  \__,_|\___|\__,_|\__,_|\__,_|
#                                                    
# Backup script for the Barracuda NextGen Firewall F-Series.
# The backup destination is a FTP server.
#
##############################################################################################################

# Local logging adapt the LOGDIR variable to the directory where script is installed.
TODAY=`date +"%Y-%m-%d"`
LOGDIR="/root/backup"
LOG="$LOGDIR/backup-$TODAY.log"

# Email Notification
SMTPNOTIFICATION=true
SMTPSERVER='mail.barracuda.com'
FROM="jvanhoof@barracuda.com"
TO="jvanhoof@barracuda.com"
SUBJECT="Backup NextGen Firewall F-Series - $TODAY"

# Backup filename
FILENAME=NGF-box_`date +%Y_%m_%d_%H_%M`.par

# Creating the log directory
if [ ! -d "$LOGDIR" ];
then
  echo
  echo "Creating local log directory ($LOG) on Barracuda NextGen Firewall F-Series ..."
  mkdir -p $LOGDIR
fi

# FTP storage credentials
HOST="172.16.250.4" 
USER="barracuda" 
PASSWD="barracuda"
DSTPATH="/"

{
  echo "-------------------------------------------------------------------------" 
  echo " Backup script for Barracuda NextGen Firewall F-Series" 
  echo " Date: $TODAY"
  echo
  echo "-------------------------------------------------------------------------" 
  echo " Creating the backup files"
  if [ -d /opt/phion/config/configroot ];
  then
    cd /opt/phion/config/configroot/
    /opt/phion/bin/phionar cdl $LOGDIR/${FILENAME} *
  fi    
  echo

  echo "-------------------------------------------------------------------------"
  echo " Transfer to FTP server $HOST" 
  /usr/bin/curl -T $LOGDIR/${FILENAME} -u $USER:$PASSWD ftp://$HOST/${DSTPATH}/
  /usr/bin/curl -T $LOGDIR/ngfwbackup.sh -u $USER:$PASSWD ftp://$HOST/${DSTPATH}/

  echo "-------------------------------------------------------------------------"
  echo " Clean up" 
  rm -f $LOGDIR/${FILENAME}
  echo "-------------------------------------------------------------------------"
  echo " Done." 
  echo "-------------------------------------------------------------------------"
} >> $LOG 2>&1

if [ "$SMTPNOTIFICATION" = true ]; then
  mailclt -f "$FROM" -r "$TO" -s "$SUBJECT" -m "$SMTPSERVER" -t $LOG > /dev/null 2>&1
fi

exit 0
