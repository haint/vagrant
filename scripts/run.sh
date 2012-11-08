#!/bin/bash

# Environment setting
VAGRANT_HOME="/home/haint/java/vagrant"
#SERVER="192.168.33.10"
VAGRANT_DELIVERY="$VAGRANT_HOME/delivery"
# End setting

# Cleanup delivery and logs directories
rm "$VAGRANT_DELIVERY" -rf
rm "$VAGRANT_HOME/logs" -rf

git clone "ssh://vagrant@localhost:2222/home/vagrant/repository.git" "$VAGRANT_DELIVERY"
mkdir "$VAGRANT_HOME/logs"

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

process()
{
	for e in $1; do
		if [[ "$e" == *manifest.txt ]]; then
			echo "detected manifest file: $e"
			manifest=$e
			while read line
			do
				if [[ "$line" == \#* ]]; then
					continue
				else
					IFS=',' read -a segments <<< "$line"

					#Begin commit
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
						error="[ERROR][`date`] Commit file $filename to branch $branch with commnet $comment occurs an error: \n $CMD \n"
						echo -e $error >> ../logs/delivery.txt
						echo -e $error
					else
						echo "[INFO]$CMD"
					fi
					#End commit

					#Begin deploy war
					if [[ "$filename" == *.war ]]; then
						appname=${filename%.*}
						echo "appName=$appname"
						CMD=`curl --upload-file "$filename" "http://tomcat:tomcat@localhost:8085/manager/deploy?path=/$branch-${filename%.*}&update=true"`
						if [ $? != 0 ]; then
							error="[ERROR][`date`] Deploy $filename to context path /$branch-${filename%.*} occurs an error: \n $CMD \n"
							echo -e $error >> ../logs/deployment.txt
							echo -e $error
						else
							info="[INFO][`date`]\n $CMD \n"
							echo -e $info >> ../logs/deployment.txt
							echo -e $info
						fi
					fi
					#End deploy war
				fi
			done < "$manifest"
		fi
	done
}

current="0"

echo "Started"
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
				rm $item
				process "$elements"
			elif [[ "$item" == *.zip ]]; then
				echo "detected zip file: $item"
			fi
		done
		current="0"
	fi
	current=$length
done

