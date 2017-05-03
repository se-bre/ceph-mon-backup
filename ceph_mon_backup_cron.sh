#!/bin/bash
#
## Variables
LOGFOLDER=/var/log/ceph
LOGFILE=ceph-mon.backup.log
BACKUPFOLDER=/var/backups/ceph

### create a function to write script output to logfile!
do_backup() {

### check OS
if [ -f /etc/issue ]
  then
	OSVERS=$(cat /etc/issue | awk '{print $1}')
  else
	echo -e "NO issue file found - can´t detect OS\ngiving up...\n"
	exit 1
fi

### create start/stop commands
if [ "$OSVERS" == "Debian" ]
  then
	  DISTVERS=$(cat /etc/issue | awk '{print $3}')
	  if [ "$DISTVERS" == "7" ]
	    then
	  	# get ceph monitor service name
	  	SERVICENAME=$(service ceph status | grep -E ^mon\. | awk -F':' '{print $1}')
	  	stop_ceph() {
		  	for i in $SERVICENAME;do service ceph stop $i;done
	  	}
	  	start_ceph() {
		  	for i in $SERVICENAME;do service ceph start $i;done
	  	}
	    else
		echo -e "\nthis is not a Debian 7 System - untested!\n"
		exit 1
	    fi
  elif [ "$OSVERS" == "Ubuntu" ]
    then
	  DISTVERS=$(cat /etc/issue | awk '{print $2}' | cut -d'.' -f1,2)
	  if [ "$DISTVERS" == "14.04" ]
	    then
	  	stop_ceph() {
		  	stop ceph-mon-all
	  	}
	  	start_ceph() {
		  	start ceph-mon-all
	  	}
	    else
		echo -e "this is not Ubuntu 14.04 - untested!\n"
		exit 1
	  fi
  else
	  echo -e "\nNO debian or ubuntu OS detected - giving up...\n"
	  exit 1
fi

### print timestamp to logfile
echo -e "start: `date +%c`\n" 

### check LOG folder
if [ ! -d $LOGFOLDER ]
  then
    echo -e "creating LOG folder\n" 
    mkdir -p $LOGFOLDER
fi

### stop ceph-mon service
stop_ceph
#

### check backup folder
if [ ! -d $BACKUPFOLDER ]
  then
    echo -e "creating backup folder\n" 
    mkdir -p $BACKUPFOLDER
fi

### backup
tar czf $BACKUPFOLDER/ceph-mon-backup_$(date +'%Y%m%d').tar.gz /var/lib/ceph/mon
#
#### remove old LOG file
OLDLOG=$(find /var/lib/ceph/mon/ -name LOG.old | grep 'store.db/LOG.old')
if [ ! "$OLDLOG" == "" ]
  then 
        echo -e "\nremoving old LOG file = $OLDLOG\n" 
        rm $OLDLOG
  else 
        echo -e "\nno old LOG file found\n" 
fi

#
### remove old backups
find /var/backups/ceph/ -ctime +14 -print -exec rm {} \;
#
### start ceph mon
start_ceph

echo -e "\nend: `date +%c`"

}

### execute function
do_backup > $LOGFOLDER/$LOGFILE 2>&1

exit 0
