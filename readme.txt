
A script veniso-gcp-copy-metrics.sh is prepared to push the data from /ca4/veniso to gcs bucket //veniso-backup/Veniso-log-backup-ca4/

This script will do a check sfor new files if file is present will do checksum and delete file from ca4.

If file is not present it will copy it then do a check sum and then delete. We are also generating logs which will be pushed to //veniso-backup/Veniso-log-backup-ca4/ca4-copy-script-logs location with timestamp.

A prometeus metrics is pushed to check file copy failed logs, which is placed in git. 
