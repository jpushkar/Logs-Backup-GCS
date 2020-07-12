#!/bin/sh
cat /dev/null > files-md5-matched.txt
cat /dev/null > files-copied.txt
cat /dev/null > files-need-to-copied.txt
cat /dev/null > logs.txt
time=`date "+%d-%m-%Y-%H-%M-%S"`

du -a /folder-name-to-be-backed-up | awk '{ print $2 }' > logs.txt

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
		echo "Files already exist " 
		echo $line >> files-md5-matched.txt
		#rm -f $line
	else 
		echo "File need to copy to bucket " 
		echo $line >> files-need-to-copy.txt
		trickle -d 20000 -u 20000 gsutil -m cp -r -c -L cp.log $line gs://gcs-bucket-name/folder-name/$gcpfile
		
#		nohup trickle -d 20000 -u 20000 gsutil -o GSUtil:parallel_composite_upload_threshold=150M rsync -rhv --progress /folder-name-to-be-backed-up gs://gcs-bucket-name/folder-name/ &
		echo "$line copied to gs://gcs-bucket-name/folder-name/$gcpfile" >> files-copied.txt
		gcpCheck2=$(gsutil hash -h -m "gs://gcs-bucket-name/folder-name/$gcpfile" | grep md5 | awk '{print $3}')
		if [ "$localCheck" == "$gcpCheck2" ]
		then	
			echo "Files copied and checksum matched reday to delete "
			echo $line >> files-md5-matched.txt
			#rm -f $line
		else
			echo "Failed to copy file $line"
			echo $line >> files-failed-to-copy.txt
		fi
	fi
fi
done < logs.txt

echo "File transfer is completed at $time"

