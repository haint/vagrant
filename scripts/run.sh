#!/bin/bash

# Environment setting
VAGRANT_HOME="/home/haint/java/vagrant"
SERVER="192.168.33.10"
VAGRANT_DELIVERY="$VAGRANT_HOME/delivery"
# End setting

# Cleanup delivery directory
rm "$VAGRANT_DELIVERY" -rf

git clone "vagrant@$SERVER:repository.git" "$VAGRANT_DELIVERY"

cd "$VAGRANT_DELIVERY"
branch=`git branch`
if [[ "$msg" != "master" ]]; then
	echo "repository need to initialize"
	touch init
	git add init
	git commit -m "Initialize repository master branch"
	git push origin master
fi

cd $OLDPWD

current="0"

echo "Listening ...."
while true; do
	list=`find "$VAGRANT_HOME/delivery" -name "*.tar.gz" -o -name "*.zip"`
	length="0"
	for item in $list; do
		length=$[$length+1]
	done

	if (($current < $length)); then
		for item in $list; do
			if [[ "$item" == *.tar.gz ]]; then
				echo "detected tar file: $item"
				cd "$VAGRANT_DELIVERY"
				elements=`tar xvzf $item`
				for e in $elements; do
					if [[ "$e" == *manifest.txt ]]; then
						echo "detected manifest file: $e"
						manifest=$e
						while read line
						do
							if [[ "$line" == \#* ]]; then
								continue
							else
								IFS=',' read -a segments <<< "$line"
								#for index in ${!segments[@]}
								#do
								#	echo "$index ${segments[index]}"
								#done
								branch=${segments[1]}
								echo "branch: $branch"
								git checkout -b "$branch"

								filename=${segments[0]}
								echo "file name: $filename"
								git add "$filename"

								comment=${segments[2]}
								echo "comment: $comment"
								git commit -m "$comment"

								CMD=`git push origin "$branch" 2>&1`
								if [ $? != 0 ]; then
									echo "Error"
									#echo $CMD
								fi
							fi
						done < "$manifest"
					fi
				done
			elif [[ "$item" == *.zip ]]; then
				echo "detected zip file: $item"
			fi
		done
		current="0"
	fi
	current=$length
done
