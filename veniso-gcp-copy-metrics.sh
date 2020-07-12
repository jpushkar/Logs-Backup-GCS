#!/bin/bash

pr=`cat /home/pushkar/files-failed-to-copy.txt | wc -l`

if [ "$pr" ]; then
	echo "File copy failed please check"
	echo "veniso_file_copy_error{instance=\"gcs_data_copy_1\",script_name=\"gcp_veniso_copy_del\",backup_error=\"file_copy_failed\"}" 1 >> /home/pushkar/metrics/mysql-metrics.txt
else
	echo "File copy is sucessfull"
	echo "veniso_file_copy_error{instance=\"gcs_data_copy_1\",script_name=\"gcp_veniso_copy_del\",backup_error=\"file_copy_failed\"}" 0 >> /home/pushkar/metrics/mysql-metrics.txt
fi


