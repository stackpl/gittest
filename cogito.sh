#!/bin/bash

watch -t -n1 -c '
	STATUS=$(git status -s -u) ;
	if [ $(echo $STATUS | wc -w) -gt 0 ] ;
	then
		unbuffer git status -s -u --column;
		#unbuffer echo $STATUS;
		echo "________ ADD: git add <..>,  UDATE: git add -u,  RESET: git reset <..> ________" ;
		echo "\n";
	fi
	#git branch --all -vv --abbrev=5 --color;
	git branch --all --color;
	echo "\n";
	git log --graph --oneline --decorate=short -n 25 --abbrev=5 --color | 
	#sed -e "s/\x31\x68\x1B\x3D\x0D//;s/\x31\x6C\x1B\x3E//" |
	cat ;
	'

