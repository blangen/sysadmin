#!/bin/bash

mountpoint="$1"
date "+%Y%m%d-%H%M%S"
output=/data/backups/output-$date
echo ''
echo "INFO: Backing up ${DIR}" >> $output
echo ''
hostname=`uname -n`

if mountpoint -q ${mountpoint}/
  then
       echo "Filesystem mounted - running backups" >> $output
  else
       echo "filesystem not mounted - attempting to mount." >> $output
full_backup=/opt/full_backup
 if [ -d ${full_backup} ]
        then
          echo $full_backup" exists" >> $output
        else
          echo $full_backup" does not exist.. creating this for backing up Admin tools" >> $output
          mkdir $full_backup
 fi 

       /bin/mount <NFS Server>:</vol/partition> $mountpoint
       if ! mountpoint -q ${mountpoint}/
         then
	        echo "An error code was returned by mount command!" >> $output
		exit 5
	else echo "Mounted successfully." >> $output
	fi
#else echo "${mountpoint} is already mounted."
fi

# Target volume **must** be mounted by this point. If not, die screaming!
if ! mountpoint -q ${mountpoint}/; then
	echo "Mounting failed! Cannot run backup without backup volume!" >> $output
	exit 1
fi

admin=/$mountpoint/admin
 if [ -d ${admin} ]
        then
          echo $admin" exists" >> $output
        else
          echo $admin" does not exist.. creating this for backing up Admin tools" >> $output
          mkdir $admin
  fi

       /usr/bin/rsync -rlptDz $1 $mountpoint/admin/$hostname
