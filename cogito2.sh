#!/bin/bash

git_branch_current() {
	git branch --points-at HEAD --color | \
	tr -d '\n';
	echo "  (current branch)";
	echo "";
}

git_branch_list() {
	echo "BRANCHES:";
	git branch --color
}

git_status() {
	git status -s -uall
}

git_status_tracked() {
	if [ `echo "$1" | grep ^[^?!][^?!] | wc -l` -gt 0 ]
	then
		echo "       Changes in tracked files:";
        	echo "+---------+---------+------------------";
        	echo "|  Staged | Unstaged|  File name";
        	echo "+---------+---------+------------------";
        	echo "$1" \
		| grep ^[^?!][^?!] \
		| sed -r 's/(.)(.)\s*(.+)/|    \1    |    \2    | \3/' ;
		echo "";
	fi
}

git_status_untracked() {
        if [ `echo "$1" | grep ^[?][?] | wc -l` -gt 0 ]
	then
		echo "+---------------------"
        	echo "|  Untracked";
        	echo "+---------------------";
        	echo "$1" | \
        	grep ^[?][?] | \
        	sed -r 's/[?][?]\s*(.+)/| \1/' ;
		echo "";
	fi
}

STATUS=$(git_status)
if [ $(echo $STATUS | wc -w) -gt 0 ]  
then
	git_branch_current;
	git_status_tracked "$STATUS";
	git_status_untracked "$STATUS";
else
        git_branch_list;
fi
echo "";
git log --all --graph --oneline --decorate -n 50 --abbrev=5 --color | cat;


