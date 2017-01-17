#!/bin/bash

watch -t -n1 -c '
	STATUS=$(git status -s -uno);
	if [ $(echo $STATUS | wc -w) -gt 0 ] ;
	then
		echo "  .----- STAGED  (ready to \"git commit\")";
		echo " / .--- UNSTAGED";
		echo "| /";
		echo "||";
		unbuffer git status -s -uno;
	else
		echo ""
	        git branch --color;
	fi
	git log --all --graph --oneline --decorate -n 50 --abbrev=5 --color;
	'

