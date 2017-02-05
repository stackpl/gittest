#!/bin/bash

GIT_REPORT=$(awk '/^__GIT_REPORT__/ {print NR+1; exit 0;}' $0)
#tail -n+$GIT_REPORT $0 > /tmp/gitreport.sh  # uncomment this lines to diagnose internal script
#chmod u+x /tmp/gitreport.sh; exec watch -c -t "sh /tmp/gitreport.sh"

#export GITFLOW=$(cat ./.git/config 2>/dev/null | grep "^\[gitflow" | wc -l)
exec watch -c -t -n 0.3 "echo $(tail -n+$GIT_REPORT $0)"
exit
__GIT_REPORT__
#!/bin/bash

git_branch_current() {
  #git branch --points-at HEAD | \
  CURRENT_BRANCH=$(git rev-parse --abbrev-ref HEAD 2>/dev/null | tr -d '\n')
  echo "  (current branch)"
  echo ""
}

git_branch_list() {
  echo "BRANCHES:"
  git branch --no-color
  CURRENT_BRANCH=$(git rev-parse --abbrev-ref HEAD 2>/dev/null | tr -d '\n')
  echo
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

git_flow_help() {
  split_slash $CURRENT_BRANCH

  if [ $(echo "$RP1" | grep master | wc -l) -gt 0 ]
  then
    echo "--------------  git-flow helper:  --------------
A. Start a hotfix. New branch will be created from the
   corresponding tag on the 'master' branch that
   marks the production version. The <VERSION> argument
   hereby marks the new hotfix release name:
     $ git flow hotfix start <VERSION>
   or optionally you can specify a basename to start from:
     $ git flow hotfix start <VERSION> <basename>
B. Finish a hotfix. By finishing a hotfix it gets merged
   back into 'develop' and 'master'. Additionally
   the 'master' merge is tagged with the hotfix version.
     git flow hotfix finish <VERSION>
------------------------------------------------"
  fi

  if [ $(echo "$RP1" | grep develop | wc -l) -gt 0 ]
  then
    echo "--------------  git-flow helper:  --------------
A. Start developing a new feature. This creates a new
   feature branch based on 'develop' and switches to it.
     $ git flow feature start <feature-name>
B. Start a release. It creates a release branch created 
   from the 'develop' and switches to it.
     $ git flow release start <release-name>
   or optionally supply a commit sha-1 hash to start
   the release from:
     $ git flow release start <release-name> <sha1>
------------------------------------------------"
  fi  

  if [ $(echo "$RP1" | grep feature | wc -l) -gt 0 ]
  then
    echo "--------------  git-flow helper:  --------------
1. Finish up a feature:
     $ git flow feature finish $RP2
2. Publish a feature to the remote server:
     $ git flow feature publish $RP2
3. Get a feature published by another user:
     $ git flow feature pull origin $RP2
4. Track a feature on origin:
     $ git flow feature track $RP2
------------------------------------------------"
  fi  

   if [ $(echo "$RP1" | grep release | wc -l) -gt 0 ]
  then
    echo "--------------  git-flow helper:  --------------
1. Publish the release branch after creating it
   to allow release commits by other developers:
     $ git flow release publish $RP2
2. Track a remote release:
     $ git flow release track $RP2
3. Finish up a release. It performs several actions:
   -merges the release branch back into 'master',
   -tags the release with its name ($RP2),
   -back-merges the release into 'develop',
   -removes the release branch.
     $ git flow release finish $RP2
4. Push your tags with:
     $ git push --tags
------------------------------------------------"
  fi 

  if [ $(echo "$RP1" | grep hotfix | wc -l) -gt 0 ] 
  then
    echo "--------------  git-flow helper:  --------------
1. Finish a hotfix. By finishing a hotfix it
   gets merged back into 'develop' and 'master'.
   Additionally the 'master' merge is tagged
   with the hotfix version:
     $ git flow hotfix finish <VERSION> 
------------------------------------------------"
  fi 

  if [ $(echo "$RP1" | grep support | wc -l) -gt 0 ]
  then
    echo "SUPPORT"
  fi
}

split_slash() {
  RP1=$(echo "$1" | sed -r 's#(^[^/]+)\/(.+)#\1#') 
  RP2=$(echo "$1" | sed -r 's#(^[^/]+)\/(.+)#\2#')
}

git_log() {
  git log --all --graph --oneline --decorate -n 10 --abbrev=5 --color
}

controller() {
    # SIGUSR1 and SIGUSR2 are ignored
    trap '' SIGUSR1 SIGUSR2
    local cmd commands

    while 1; do           # run while showtime variable is true, it is changed to false in cmd_quit function
        read -s -n 1 cmd          # read next command from stdout
        echo "$cmd"         # run command
    done
}

isgitflow() {
  if [ $(cat ./.git/config 2>/dev/null | grep "^\[gitflow" | wc -l) -gt 0 ]
  then
    GITFLOW=1
    :
  else
    GITFLOW=0
    :
  fi
}

STATUS=$(git_status)
GITBRANCH=$(git branch)

(
bash -c "read -n 1 -t 0.2 KEY"
echo "$KEY" | tr -d '\n' >> /tmp/key111
)

#(controller)

KEY=`cat /tmp/key111` 

if [ $(echo "$STATUS" | wc -w) -gt 0 ]
then
  git_branch_current
  git_status_tracked "$STATUS"
  git_status_untracked "$STATUS"
else
  git_branch_list
  isgitflow
  if [ $GITFLOW -gt 0 ]
  then
    git_flow_help
  fi
fi
git_log
echo $KEY

