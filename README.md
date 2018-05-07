# Incremental-differential-backup

Features:

1. Full and Differential
- Reservation is made both for the complete copy of the data, and for the differences between the backups
- During retransmission of full or differential data, existing data is not re-transmitted, only synchronized, providing less network load

2. Versatility:
- You can specify after the name of the script the type of backup (full or differential), the host address and folders that need to be backed-up (up to five)

3. Rotation and Archiving
- Backups are archived and rotated. Only the last five versions of the full backup and eight differentials are preserved

4. Login:
- All errors during the backup process are written to the log file during the full backup and are added at the time of the differential
- Logs are rotated, only the last 10 messages are stored

5. Informing:
- In the case of a failed process, the message will be sent by e-mail
- In case of success in the file, the time taken for the last backup process will be saved

6. Automation
- Creation of folders necessary for backup and, if necessary, clearing their contents realization parameters by name of the script

7. Restoration
- Implemented automated data recovery and overlay differential backup on full
- Each archive contains a file with the exact date and time spent on the backup process

Crontab

13 02 * * 1 /home/sergii/scripts/backup/backup.sh f backup@example.com:/root:/home/sergij

13 03 * * * /home/sergii/scripts/backup/backup.sh d backup@example.com:/root:/home/sergij
