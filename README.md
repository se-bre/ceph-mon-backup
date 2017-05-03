# ceph-mon-backup
bash script to create a ceph monitor backup  

**tested on:**  
- Ubuntu 14.04  
- Debian 7  

if you have other OS Versions the scripts will not work (scripts exit with exit code 1)  

### todo
put this script on any ceph monitor host  
make this script executable

### manual
for manual execution use `ceph_mon_backup.sh`  
it produces more output than the cron script

### cron
for a cronjob use `ceph_mon_backup_cron.sh`  
best practise is to let it run once a day  
it puts all output in a log file  

**don´t run this script on all hosts at the same time! this will stop your cluster!**  
create a cronjob


