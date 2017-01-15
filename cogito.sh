#!/bin/bash

watch -d -t -n1 -c '
	STATUS=$(unbuffer git status -s -u) ;
	if [ $(echo $STATUS | wc -w) -gt 0 ] ;
	then
		unbuffer git status -s -u;
		#unbuffer echo $STATUS;
		unbuffer echo -e ---------------------------------;
	fi
	unbuffer git branch --all -vv;
	unbuffer echo -e \\n;
	unbuffer git log --graph --oneline --decorate=short | 
	sed -e "s/\x31\x68\x1B\x3D\x0D//;s/\x31\x6C\x1B\x3E//" | 
	cat ;
	'

