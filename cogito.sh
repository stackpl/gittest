#!/bin/bash

watch -t -n1 -c '
	STATUS=$(git status -s -uno) ;
	if [ $(echo $STATUS | wc -w) -gt 0 ] ;
	then
		echo "+----- INDEX" ; 
		echo "|  +-- WORK TREE" ; 
		echo "| /";
		unbuffer git status -s -uno --column;
		#unbuffer echo $STATUS;
		echo "_______________________________________________________________________________" ;
	else
	        #git branch --all -vv --abbrev=5 --color;
	        git branch --all --color;
	fi
	#git branch --all -vv --abbrev=5 --color;
	#git branch --all --color;
	echo "\n";
	git log --graph --oneline --decorate=short -n 25 --abbrev=5 --color | 
	#sed -e "s/\x31\x68\x1B\x3D\x0D//;s/\x31\x6C\x1B\x3E//" |
	cat ;
	'

