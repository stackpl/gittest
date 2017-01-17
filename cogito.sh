#!/bin/bash

watch -t -n1 -c '
	STATUS=$(git status -s -u) ;
	if [ $(echo $STATUS | wc -w) -gt 0 ] ;
	then
		echo "___________________ WORKING TREE CHANGES SINCE INDEX __________________________" ; 
		unbuffer git status -s -u -b --column;
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

