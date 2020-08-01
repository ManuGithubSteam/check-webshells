#!/bin/bash
# v_3
# Script checks for common webshells
# 08-2020

# init
command="$1"
ip="$2"
filename=$(echo $ip | sed 's/\./_/g')

if [ "$1" == "" ]; then
 echo "IP missing"
 echo "exititing..." 
 exit 1
fi

oldpath=$PWD
spath=/opt/webshells/

function ProgressBar() {

 let _progress=$(((file_Count * 100 / total_Files * 100) / 100))
 let _done=$(((_progress * 4) / 10))
 let _left=$((40 - _done))
 _fill=$(printf "%${_done}s")
 _empty=$(printf "%${_left}s")
 printf "\rProgress : [${_fill// /\#}${_empty// /-}] ${_progress}%%"

}

function DownloadShells()
{
 cd $spath
 git clone https://github.com/JohnTroony/php-webshells.git
 git clone https://github.com/TheBinitGhimire/Web-Shells.git
 mv php-webshells/Collection/* php-webshells/
 cd $oldpath
}

function GrabMatch()
{
  match=$(cat *-shells_uniqe.txt | grep php | grep / | head -n 1)

  if cat $match | grep -q "pass"; then
   pass=$(cat "$match" | grep pass)
  else
   pass=$(cat "$match" | grep Pass)
  fi
  if cat $match | grep -q "user"; then
   user=$(cat "$match" | grep user)
  else
   user=$(cat "$match" | grep User)
  fi

  echo ""
  echo "Extracted data from: $match"
  echo ""
  echo "$user"
  echo "$pass"
  echo ""
}

function TestShells()
{
 shells=$(ls -1 $spath*/*.php | cut -d'/' -f5 | sed 's/ //g' | xargs)
 shellpaths=$(ls -1 $spath*/*.php)
 file_Count=0
 
 VAR=( $shells )
 total_Files=$(echo ${#VAR[@]})
 
 echo "Checking: $ip ...."
 
 for shell in $shells;
 do
 
  ((++file_Count))
  resp=$(curl -sS -X POST $ip/"$shell")

  ProgressBar
  if ! echo "$resp" | grep -q "was not found"; then
    
   echo "$ip" >> $oldpath/$filename-shells.txt
   echo "Match found for: $shell" >> $oldpath/$filename-shells.txt
   echo "$shellpaths" | grep "$shell" >> $oldpath/$filename-shells.txt 
    
  fi
 done

 cat $oldpath/$filename-shells.txt | awk '!seen[$0]++ {print}' > $filename-shells_uniqe.txt

 echo ""
 echo ""
 echo "Match found for: "
 cat  $oldpath/$filename-shells_uniqe.txt
 echo ""
}

case "$command" in


-t) echo "Testing Webshells..."
    TestShells
    ;;

-d) echo "Download Webshells..."
    DownloadShells
    ;;
  
-g) echo "Try to grab match data"
    GrabMatch
    ;;
 
*) echo "Invalid option"
   echo "use -t <ip> for testing"
   echo "use -g for grabbing info of matches"
   echo "use -d for downloading the webshells"
   ;;
esac

