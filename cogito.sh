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
	else
	        git branch --all --color;
	fi
	echo "\n";
	git log --graph --oneline --decorate=short -n 50 --abbrev=5 --color;
	'

