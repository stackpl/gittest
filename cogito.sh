#!/bin/bash

watch -t -n1 -c '
	STATUS=$(git status -s -uno);
	if [ $(echo $STATUS | wc -w) -gt 0 ] ;
	then
		echo "  .----- STAGED  (ready to \"git commit\")";
		#echo "|";	
		echo " / .--- UNSTAGED"; 
		echo "| /";
		echo "||";
		unbuffer git status -s -uno;
		#unbuffer echo $STATUS;
	else
	        #git branch --all -vv --abbrev=5 --color;
	        git branch --all --color;
	fi
	#git branch --all -vv --abbrev=5 --color;
	#git branch --all --color;
	echo "\n";
	git log --graph --oneline --decorate=short -n 50 --abbrev=5 --color;
	'

