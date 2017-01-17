#!/bin/bash


watch -t -n1 -c '
	STATUS=$(git status -s -uno);
	if [ $(echo $STATUS | wc -w) -gt 0 ] ;
	then
		git branch --points-at HEAD --color;
		echo "";
		echo ".----------- STAGED  (ready to commit)";
		echo "|  .------- UNSTAGED";
		echo "| /";
		unbuffer git status -s -uno;
		echo "";
	else
	        git branch --color;
	fi
	echo "";
	git log --all --graph --oneline --decorate -n 50 --abbrev=5 --color;
	'

