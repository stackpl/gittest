#!/bin/bash
GIT_REPORT=`awk '/^__GIT_REPORT__/ {print NR+1; exit 0;}' $0`
# uncomment 1 line below to diagnose internal script
tail -n+$GIT_REPORT $0 > /tmp/gitreport.sh
#chmod u+x /tmp/gitreport.sh
#exec watch -c -t "sh /tmp/gitreport.sh"
# production stage
exec watch -c -t "echo $(tail -n+$GIT_REPORT $0);"
exit
__GIT_REPORT__
#!/bin/bash

git_branch_current() {
  git branch --points-at HEAD --color | \
  tr -d '\n'
  echo "  (current branch)"
  echo ""
}

git_branch_list() {
  echo "BRANCHES:"
  git branch --color
}

git_status() {
  git status -s -uall
}

git_status_tracked() {
  if [ `echo "$1" | grep ^[^?!][^?!] | wc -l` -gt 0 ]
  then
    echo "       Changes in tracked files:"
    echo "+---------+---------+------------------"
    echo "|  Staged | Unstaged|  File name"
    echo "+---------+---------+------------------"
    echo "$1" \
    | grep ^[^?!][^?!] \
    | sed -r 's/(.)(.)\s*(.+)/|    \1    |    \2    | \3/'
    echo ""
  fi
}

git_status_untracked() {
  if [ `echo "$1" | grep ^[?][?] | wc -l` -gt 0 ]
  then
    echo "+---------------------"
    echo "|  Untracked"
    echo "+---------------------"
    echo "$1" | \
    grep ^[?][?] | \
    sed -r 's/[?][?]\s*(.+)/| \1/'
    echo ""
  fi
}

git_log() {
  git log --all --graph --oneline --decorate -n 10 --abbrev=5 --color
}

STATUS=$(git_status)
if [ $(echo $STATUS | wc -w) -gt 0 ]  
then
  git_branch_current
  git_status_tracked "$STATUS"
  git_status_untracked "$STATUS"
else
  git_branch_list
fi
git_log
