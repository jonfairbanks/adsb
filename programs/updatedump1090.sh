#!/bin/bash
### BEGIN INIT INFO
#  version 1.0 20130421 1307
#
#  version 1.1 20141001 1709 modified as compile reported non empty
#                            dump1090 directory. Commented out cd ~ line in script
#
#  script written by Roger G7RUH
#
# Provides:		recompiled dump1090
#
# Assumptions:
#	1) this script file is installed and run in /home/pi
#	2) the dump1090 program is compiled and run from  /home/pi/dump1090
#	
#
#	There are two previous versions of the files in
#	/home/pi/dump1090-old and /home/pi/dump1090-oldest
#
#	The first time the script is run, it will error
#	as the backup directory does not exist. Just continue.
#
# Function:
#
# The script will stop the existing dump1090 process,
# check for a autostart script lockfile and if
# present, remove it. This way the script logic
# works for both manually started and autoscript
# started dump1090 options.
#
# Short-Description:	dump1090 update script
#
### END INIT INFO
PIDFILE="/var/run/dump1090.pid"
#
echo " "
echo "**************************************"
echo " "
echo "script version 1.1 updated 2014 Oct 01"
echo " "
echo "**************************************"
echo " " 
echo " This script will download and update dump1090 "
echo " input y to continue "
echo " "
#
read -p "Are you sure? " -n 1 -r
#
if [[ $REPLY =~ ^[Yy]$ ]];
then
    echo " "
    # can proceed, user said yes
else
    echo "   ... aborting script"
    exit 0
fi
#
# terminate dump1090
#
sudo killall dump1090
echo " process terminated if running"
#
#
# check that the autostart lock file does not exist
# if it does, remove it
if [ -f $PIDFILE ];
then
   echo "File " $FILE " exists"
	sudo rm /var/run/dump1090.pid
   echo " lockfile removed"
else
   echo "lockfile does not exist"
fi
echo " "
#
# backup current and previous versions
#
# check  for dump1090 program, if not present, may mean that
# the previous download and compile attempt failed. In this case we do
# not want to remove the older backups as we could end up with nothing
# to restore. This is not a desirable state.
#
# So we will detect the presence of the dump1090 directory.
# if not present, will present the user with the option to:
#
#		a) continue to download and compile
#		b) abort the script and allow the user to decide next action
#		c) copy the previous script back to the dump1090 directory
#
# Obviously the first few times the script is run, the backup directories
# do not exist so we need to continue past the missing file trap.
#
#
# test for  /home/pi/dump1090/dump1090 not present
#
if [ ! -f /home/pi/dump1090/dump1090 ]
then 
echo " "
echo "********************************************************"
echo "*                                                      *"
echo "* dump1090 program is missing                          *"
echo "* possible cause is previous download / compile failed *"
echo "* what do you want to do?                              *"
echo "*                                                      *"
echo "*         continue to run script:   y                  *"
echo "*         abort script:             a                  *"
echo "*         restore previous version: r                  *"
echo "*                                                      *"
echo "********************************************************"
echo " "
read -p "input option " -n 1 -r
#
  if [[ $REPLY =~ ^[Yy]$ ]];
  then
    echo " "
    echo "  continue to run script "
    # can proceed, user said yes
      elif [[ $REPLY =~ ^[Rr]$ ]];
      then    
	if [ -f /home/pi/dump1090-old/dump1090 ]
	then
        echo " ...   will now restore previous version"
	mkdir dump1090
	cp -r dump1090-old/* dump1090
	echo " restore complete "
	exit 0
      else
	echo " "
	echo "********************************"
	echo "*                              *"
	echo "* FATAL ERROR                  *"
	echo "*                              *"
	echo "*                              *"
	echo "* Backup directory missing     *"
	echo "* will now abort               *"
	echo "*                              *"
	echo "********************************"
	sleep 5
	exit 0
      fi
  else  echo " aborting script" 
      exit 0
  fi
else
echo " "
fi
#
echo "starting backups"
rm -r -f /home/pi/dump1090-oldest
mv /home/pi/dump1090-old dump1090-oldest
mv /home/pi/dump1090 dump1090-old
#
#
# download and compile update
#
echo "starting download and compile"
#cd ~
git clone git://github.com/MalcolmRobb/dump1090.git
cd dump1090
make
#
red='\e[0;31m'
NC='\e[0m' # No Color
#
echo " "
echo -e "${red} check compile completed OK, if not, remove dump1090 and${NC}"
echo -e "${red} copy back the dump1090-old directory to dump1090 ${NC}"
echo " "
echo -e "${red} if compile OK then start dump1090 and test new version${NC}"
echo " "

#
#
#
exit 0
#
# end of script

