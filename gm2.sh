#!/bin/bash

git_branch_current() {
  echo "CURRENT BRANCH:"
  #git branch --points-at HEAD | \
  CURRENT_BRANCH=$(git rev-parse --abbrev-ref HEAD 2>/dev/null | tr -d '\n')
  echo "* $CURRENT_BRANCH"
  echo ""
}

git_branch_list() {
  echo "BRANCHES:"
  git branch
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
    echo "| Staged  |Unstaged |  File name"
    echo "+---------+---------+------------------"
    echo "$1" \
    | grep ^[^?!][^?!] \
    | sed -r 's/(.)(.)\s*(.+)/|    \1    |    \2    | \3/'
    echo "+---------+---------+------------------"
    echo ""
  fi
}

git_status_untracked() {
  if [ `echo "$1" | grep ^[?][?] | wc -l` -gt 0 ]
  then
    echo "+---------------------"
    echo "|  Untracked files (use \"git add\" or update \".gitignore\")"
    echo "+---------------------"
    echo "$1" | \
    grep ^[?][?] | \
    sed -r 's/[?][?]\s*(.+)/| \1/'
    echo ""
  fi
}

git_diff_stat() {
  git diff --stat --color
  echo ""
}

git_flow_help() {
  W=$(tput setaf 7; tput sgr0;)
  #W=$(echo "\033[m")
  G=$(tput setaf 2;tput bold)
  Y=$(tput setaf 3;tput bold)

  split_slash $CURRENT_BRANCH

  if [ $(echo "$RP1" | grep master | wc -l) -gt 0 ]
  then
    echo "${W}--------------  git-flow helper:  --------------
A. Start a hotfix. New branch will be created from the
   corresponding tag on the 'master' branch that
   marks the production version. The <VERSION> argument
   hereby marks the new hotfix release name:
   ${Y}  $ git flow hotfix start <VERSION> ${W}
   or optionally you can specify a basename to start from:
   ${Y}  $ git flow hotfix start <VERSION> <basename> ${W}
B. Finish a hotfix. By finishing a hotfix it gets merged
   back into 'develop' and 'master'. Additionally
   the 'master' merge is tagged with the hotfix version.
   ${Y}  $ git flow hotfix finish <VERSION> ${W}
------------------------------------------------"
  fi

  if [ $(echo "$RP1" | grep develop | wc -l) -gt 0 ]
  then
    echo "${W}--------------  git-flow helper:  --------------
A. Start developing a new feature. This creates a new
   feature branch based on 'develop' and switches to it.
   ${G}  $ git flow feature start <feature-name>${W}
B. Start a release. It creates a release branch created 
   from the 'develop' and switches to it:
   ${Y}  $ git flow release start <release-name>${W} 
   or optionally supply a commit sha-1 hash to start
   the release from:
   ${Y}  $ git flow release start <release-name> <sha1> ${W}
------------------------------------------------"
  fi  

  if [ $(echo "$RP1" | grep feature | wc -l) -gt 0 ]
  then
    echo "${W}--------------  git-flow helper:  --------------
1. Finish up a feature:
   ${G}  $ git flow feature finish $RP2 ${W}
2. Publish a feature to the remote server, if you
   developing a feature in collaboration:
   ${Y}  $ git flow feature publish $RP2 ${W}
3. Get a feature published by another user:
   ${Y}  $ git flow feature pull origin $RP2 ${W}
4. Track a feature on origin:
   ${Y}  $ git flow feature track $RP2 ${W}
------------------------------------------------"
  fi  

   if [ $(echo "$RP1" | grep release | wc -l) -gt 0 ]
  then
    echo "${W}--------------  git-flow helper:  --------------
1. Publish the release branch after creating it
   to allow release commits by other developers:
   ${Y}  $ git flow release publish $RP2 ${W}
2. Track a remote release:
   ${Y}  $ git flow release track $RP2 ${W}
3. Finish up a release. It performs several actions:
   -merges the release branch back into 'master',
   -tags the release with its name ($RP2),
   -back-merges the release into 'develop',
   -removes the release branch.
   ${G}  $ git flow release finish $RP2 ${W}
4. Push your tags with:
   ${G}  $ git push --tags ${W}
------------------------------------------------"
  fi 

  if [ $(echo "$RP1" | grep hotfix | wc -l) -gt 0 ] 
  then
    echo "${W}--------------  git-flow helper:  --------------
1. Finish a hotfix. By finishing a hotfix it
   gets merged back into 'develop' and 'master'.
   Additionally the 'master' merge is tagged
   with the hotfix version:
   ${G}  $ git flow hotfix finish <VERSION> ${W} 
------------------------------------------------"
  fi 

  if [ $(echo "$RP1" | grep support | wc -l) -gt 0 ]
  then
    echo ""
  fi
}

split_slash() {
  RP1=$(echo "$1" | sed -r 's#(^[^/]+)\/(.+)#\1#') 
  RP2=$(echo "$1" | sed -r 's#(^[^/]+)\/(.+)#\2#')
}

git_log() {
  git log --all --graph --decorate --oneline -n 25 --color 
#\
#  | sed -e "s/\x31\x68\x1B\x3D\x0D//;s/\x31\x6C\x1B\x3E//" \
 # | cat ;
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


# TODO: remove function, move body into main loop
main() {
  STATUS=$(git_status)
  GITBRANCH=$(git branch)

  if [ $(echo "$STATUS" | wc -w) -gt 0 ]
  then
    git_branch_current
    git_status_tracked "$STATUS"
    git_diff_stat
    git_status_untracked "$STATUS"
  else
    git_branch_list
    isgitflow
    if [ $GITFLOW -gt 0 ]
    then
      git_flow_help
    fi
    git_log
  fi
  #git_log
}

BEG_LINE_NUMBER=1
END_LINE_NUMBER=$LINES

FIRST_LINE=1
MAX_LINE=$(tput lines)
(( SCREEN_LINES = MAX_LINE - 2 ))
EOF_LINE=1

FIRST_COL=1
MAX_COLS=$(tput cols)
#(( SCREEN_COLS = MAX_COLS - 2 ))
#(( LAST_COL = FIRST_COL + SCREEN_COLS ))

OLD_CONTENT_DIGEST=""

while : 
do
    read -rsn1 -t 0.5 ui
    case "$ui" in
    $'\x1b')    # Handle ESC sequence.
        # Flush read. We account for sequences for Fx keys as
        # well. 6 should suffice far more then enough.
        read -rsn1 -t 0.01 tmp
        if [[ "$tmp" == "[" ]]; then
            #$tmp=""
            read -rsn1 -t 0.01 tmp
            case "$tmp" in
            "A") 
                #printf "Up\n"
#echo "$FIRST_LINE"
#sleep 1
                if [[ FIRST_LINE -gt 1 ]]
                then
                 (( FIRST_LINE = FIRST_LINE - 1 ))
                 #(( LAST_LINE = LAST_LINE - 1 ))
                fi
            ;;
            "B") 
                #printf "Down\n"
                if [[ EOF_LINE -gt LAST_LINE ]]
                then
                  (( FIRST_LINE = FIRST_LINE + 1 ))
                
                  #(( LAST_LINE = LAST_LINE + 1 ))
        #          echo "LAST_LINE=$LAST_LINE  EOF_LINE=$EOF_LINE"
        #          sleep 1
                fi
            ;;
            "C")
                #printf "Right\n"
                FIRST_LINE=1
            ;;
            "D")
                #printf "Left\n"
                FIRST_LINE=1
            ;;
            esac
            #$tmp=""
        fi
        # Flush "stdin" with 0.1  sec timeout.
        read -rsn15 -t 0.1
        ;;
    # Other one byte (char) cases. Here only quit.
    q) 
      exit
    ;;
    p)
      # "space" move 1 page down
      for (( x=1; x < SCREEN_LINES; x += 1 ))
      do
        (( LAST_LINE = FIRST_LINE + SCREEN_LINES )) 
        if [[ EOF_LINE -gt LAST_LINE ]]
        then
          (( FIRST_LINE = FIRST_LINE + 1 ))
        fi
      done
    ;;
    esac
    #$ui=""

  # main job
  OUT=$(main)

  #FIRST_LINE=1
  #LAST_LINE=$((L - 1))

  # get current number of lines in the terminal
  MAX_LINE=$(tput lines)
  (( SCREEN_LINES = MAX_LINE - 2 ))
  (( LAST_LINE = FIRST_LINE + SCREEN_LINES ))

  # get current number of columns in the terminal
  MAX_COLS=$(tput cols)
  #(( SCREEN_COLS = MAX_COLS - 2 ))
  #(( LAST_COL = FIRST_COL + SCREEN_COLS ))

  # calculate number of lines 
  EOF_LINE=$(echo "$OUT" | wc -l) 
  
  # fix view if something happened
  if [ $LAST_LINE -gt $EOF_LINE ]
  then
    FIRST_LINE=1
    (( LAST_LINE = FIRST_LINE + SCREEN_LINES ))
  fi

  # print lines in range (FIRST_LINE, LAST_LINE)
  #echo "$OUT" | sed -ne "${FIRST_LINE},${LAST_LINE}p;${LAST_LINE}q"
  CONTENT=$(echo "$OUT" | awk "NR < $FIRST_LINE {next}; NR == $LAST_LINE {print;exit}; {print};") 
  NEW_CONTENT_DIGEST=$(echo "$CONTENT:$FIRST_LINE:$MAX_LINES:$MAX_COLS" | md5sum)
  if [ "$NEW_CONTENT_DIGEST" != "$OLD_CONTENT_DIGEST" ]
  then
    OLD_CONTENT_DIGEST=$NEW_CONTENT_DIGEST
    tput rmam
    clear
    echo "$CONTENT"
    tput smam
  fi

done

