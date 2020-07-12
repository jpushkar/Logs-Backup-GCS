#!/bin/sh
cat /dev/null > nohup.out
cat /dev/null > files-failed-to-copy.txt
cat /dev/null > files-md5-matched.txt
cat /dev/null > files-copied.txt
cat /dev/null > files-need-to-copy.txt
cat /dev/null > file-list.txt
cat /dev/null > files-deleted.txt
cat /dev/null > files-delete-failed.txt
time=`date "+%d-%m-%Y-%H-%M-%S"`

du -a /source/folder/name | awk '{ print $2 }' > file-list.txt

while read line
do

if [ -d "$line" ] 
then
	echo "it is a dir"
else

	gcpfile=`echo $line | cut -d'/' -f3-`

	localCheck=$(md5sum $line | awk '{print $1}')

	gcpCheck=$(gsutil hash -h -m "gs://gcs-bucket-name/folder-name/$gcpfile" | grep md5 | awk '{print $3}')

	echo $localCheck
	echo "gcpcheck is $gcpCheck "
	echo "gcpfile is $gcpfile "
	if [ "$localCheck" == "$gcpCheck" ]
	then
		echo "Files already exist procedding for delete" 
		echo $line >> files-md5-matched.txt
                        echo "print rm -f $line"
			rm -f $line
                        if [ $? -eq 0 ]; then
                              echo "$line is deleted sucessfully $time" >> files-deleted.txt
                        else
                                echo " $line delete is failed $time"  >> files-delete-failed.txt
                        fi
	else 
		echo "File need to copy to bucket " 
		echo $line >> files-need-to-copy.txt
		trickle -s -d 20000 -u 20000 gsutil -m cp -r -c -L cp.log $line gs://gcs-bucket-name/folder-name/$gcpfile
		
#		nohup trickle -d 20000 -u 20000 gsutil -o GSUtil:parallel_composite_upload_threshold=150M rsync -rhv --progress /source/folder/name/ gs://veniso-backup/Veniso-log-backup-ca4/ &
		if [ $? -eq 0 ]; then
			echo "$line copied to gs://gcs-bucket-name/folder-name/$gcpfile" >> files-copied.txt
		else
   			echo " $line is failed $time"  >> files-copy-failed.txt
		fi

		gcpCheck2=$(gsutil hash -h -m "gs://gcs-bucket-name/folder-name/$gcpfile" | grep md5 | awk '{print $3}')
		if [ "$localCheck" == "$gcpCheck2" ]
		then	
			echo "Files copied and checksum matched reday to delete "
			echo $line >> files-md5-matched.txt
			echo "print rm -f $line"
			rm -f $line
			echo "print rm -f $line"
			if [ $? -eq 0 ]; then
                  	      echo "$line is deleted sucessfully $time" >> files-deleted.txt
               		else
                        	echo " $line delete is failed $time"  >> files-delete-failed.txt
                	fi

		else
			echo "Failed to copy file $line"
			echo $line >> files-failed-to-copy.txt
		fi
	fi
	fi
done < file-list.txt

echo "File transfer is completed at $time"

gsutil cp -p files-failed-to-copy.txt  gs://gcs-bucket-name/folder-name/copy-script-logs/files-failed-to-copy-$time.txt
gsutil cp -p files-md5-matched.txt  gs://gcs-bucket-name/folder-name/copy-script-logs/files-md5-matched-$time.txt
gsutil cp -p files-copied.txt  gs://gcs-bucket-name/folder-name/copy-script-logs/files-copied-$time.txt
gsutil cp -p files-need-to-copy.txt  gs://gcs-bucket-name/folder-name/copy-script-logs/files-need-to-copy-$time.txt
gsutil cp -p file-list.txt  gs://gcs-bucket-name/folder-name/copy-script-logs/file-list-$time.txt
gsutil cp -p files-deleted.txt  gs://gcs-bucket-name/folder-name/copy-script-logs/files-deleted-$time.txt
gsutil cp -p files-delete-failed.txt  gs://gcs-bucket-name/folder-name/copy-script-logs/files-delete-failed-$time.txt
gsutil cp -p nohup.out  gs://gcs-bucket-name/folder-name/copy-script-logs/script-log-$time.txt
