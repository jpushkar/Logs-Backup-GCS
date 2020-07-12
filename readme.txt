
A script gcp-copy-metrics.sh is prepared to push the data from /source-folder to gcs bucket gs//gcs-bucket-name/folder-name

This script will do a check sfor new files if file is present will do checksum and delete file from source.

If file is not present it will copy it then do a check sum and then delete. We are also generating logs which will be pushed to gs//gcs-bucket-name/folder-name/copy-script-logs location with timestamp.

A prometeus metrics is pushed to check file copy failed logs, which is placed in git. 
