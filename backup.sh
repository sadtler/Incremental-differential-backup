#!/bin/bash

# logic is this: the script runs cron on the backup server, connects to another server and copies the necessary folders
# Full-backup is started once a week
# Diff-backup is started every day

set -x
bdir=/var/backup	# The directory where the backups are stored. Contains 6 folders: dbase, diff, fbase, full, log, restore

sdir1=`echo $2`		# Folders on a remote server, backup objects 
sdir2=`echo $3`
sdir3=`echo $4`
sdir4=`echo $5`
sdir5=`echo $6`

slog=/var/backup/savelog		# Message sent in case of failure by email
elog=/var/backup/log/errorlog		# Write errors during backup
rlog=/var/backup/restorelog		# Recording errors during recovery

email=root@localhost			# Mailbox
rotate="/usr/sbin/logrotate -f"		# Rotation of archives of backup and logs

case $1 in

#FULL
[f])
	date=`date +%a_%d-%m-%Y_%T`
	echo "Full backup started: " $date > $slog
	echo "Full backup " $date >> $elog

	tar --numeric-owner -czpf $bdir/full/fbackup.tar.gz $bdir/fbase/ 2>> $elog
	sleep 2
	$rotate /etc/logrotate_full.conf 2>> $elog
	sleep 2
	rsync -avz --delete -e ssh $sdir1 $sdir2 $sdir3 $sdir4 $sdir5 $bdir/fbase/ 2>> $elog

	if [ $? -eq 0 ]; then
		echo "Backup $sdir1 $sdir2 $sdir3 $sdir4 $sdir5 success" >> $slog
	else
		echo "Backup $sdir1 $sdir2 $sdir3 $sdir4 $sdir5 not processed" >> $slog
		cat $slog | mail $email
	fi
	
	$rotate /etc/logrotate_log.conf 2>>$elog
	echo "Full backup finished: " `date +%a_%d-%m-%Y_%T` >> $slog
	cp -f $slog $bdir/fbase/
	;;
#DIFF
[d])
	date=`date +%a_%d-%m-%Y_%T`
	echo "Diff backup started: " $date > $slog
	echo "Diff backup " $date >> $elog

	tar --numeric-owner -czpf $bdir/diff/dbackup.tar.gz $bdir/dbase/ 2>> $elog
	sleep 2
	$rotate /etc/logrotate_diff.conf 2>> $elog
	sleep 2
	rsync -avz --delete --compare-dest=$bdir/fbase/ $sdir1 $sdir2 $sdir3 $sdir4 $sdir5 $bdir/dbase 2>> $elog

	if [ $? -eq 0 ]; then
		echo "Backup $sdir1 $sdir2 $sdir3 $sdir4 $sdir5 success" >> $slog
	else
		echo "Backup $sdir1 $sdir2 $sdir3 $sdir4 $sdir5 NOT processed" >> $slog
		cat $slog | mail $email
	fi
	
	echo "-------" >> $elog
	echo "Diff backup finished: " `date +%a_%d-%m-%Y_%T` >> $slog
	cp -f $slog $bdir/dbase/
	;;
#CREATE BACKUP DIRS
[c])
	mkdir $bdir
	mkdir $bdir/dbase
	mkdir $bdir/diff
	mkdir $bdir/fbase
	mkdir $bdir/full
	mkdir $bdir/log
	mkdir $bdir/restore
	echo "Created!"
	;;
#REMOVE BACKUP FILES
[r])
	rm -rf $bdir/dbase/*
	rm -rf $bdir/diff/*
	rm -rf $bdir/fbase/*
	rm -rf $bdir/full/*
	rm -rf $bdir/log/*
	rm -rf $bdir/restore/*
	echo " " > $slog
	echo " " > $rlog
	echo "Success!"
	;;
#RESTORE FULL BACRUP
"rf")
	echo "Full restore " `date +%a_%d-%m-%Y_%T` > $rlog
	if [ $2 = 1 ]; then
		rsync -a $bdir/fbase/ $bdir/restore/ >> $rlog
	elif [ $2 = 2 ]; then
		tar -xpf $bdir/full/*.1 -C $bdir/restore/ --strip-components=3 >> $rlog
	elif [ $2 = 3 ]; then
		tar -xpf $bdir/full/*.2 -C $bdir/restore/ --strip-components=3 >> $rlog
	elif [ $2 = 4 ]; then
		tar -xpf $bdir/full/*.3 -C $bdir/restore/ --strip-components=3 >> $rlog
	elif [ $2 = 5 ]; then
		tar -xpf $bdir/full/*.4 -C $bdir/restore/ --strip-components=3 >> $rlog
	fi
	echo "-------" >> $rlog
;;
#RESTORE DIFF BACKUP
"rd")
	echo "Diff restore " `date +%a_%d-%m-%Y_%T` >> $rlog
	if [ $2 = 1 ]; then
		rsync -au $bdir/dbase/ $bdir/restore/ >> $rlog
	elif [ $2 = 2 ]; then
		tar -xpf $bdir/diff/*.1 -C $bdir/restore/ --strip-components=3 >> $rlog
	elif [ $2 = 3 ]; then
		tar -xpf $bdir/diff/*.2 -C $bdir/restore/ --strip-components=3 >> $rlog
	elif [ $2 = 4 ]; then
		tar -xpf $bdir/diff/*.3 -C $bdir/restore/ --strip-components=3 >> $rlog
	elif [ $2 = 5 ]; then
		tar -xpf $bdir/diff/*.4 -C $bdir/restore/ --strip-components=3 >> $rlog
	elif [ $2 = 6 ]; then
		tar -xpf $bdir/diff/*.5 -C $bdir/restore/ --strip-components=3 >> $rlog
	elif [ $2 = 7 ]; then
		tar -xpf $bdir/diff/*.6 -C $bdir/restore/ --strip-components=3 >> $rlog
	elif [ $2 = 8 ]; then
		tar -xpf $bdir/diff/*.7 -C $bdir/restore/ --strip-components=3 >> $rlog
	fi
;;
esac
