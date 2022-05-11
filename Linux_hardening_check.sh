#!/bin/bash

#       Name:           Linux_hardening_check.sh
#       Author:         Sushant Goswami
#       Creation:       04-may-2022
#       Version_No:     0.01
#       Purpose:        The script is intended to check server hardening
#       Todo:
#       NOTE:

# Revisions
################################
# 0. version 0.01 written by Sushant Goswami Dated 04-may-2022
# 1.
# 2.
#=======================================
######################## Scope ######################
# The script is intended check server hardening
######################## End Scope ######################

#### User defined variables ####
##
######## Emails ids where reports need to send ########
PRIMARY_EMAIL=goswami_sushant@network.lilly.com
SECONDARY_EMAIL=sushantgoswami.del@gmail.com
######## END Emails ids where reports need to send ########

######## Enable email sending to above recipients ########
PRIMARY_EMAIL_SEND=1
SECONDARY_EMAIL_SEND=1
######## End Enable email sending to above recipients ########

######## Qualification mode HARD or NORMAL ########
TEST_MODE=HARD
######## End Qualification mode HARD or NORMAL ########

###### more variables ######
SCRIPT_NAME=$0
WORKDIR=/tmp
LOGDIR=Linux_hardening_check
LOGFILE=Linux_hardening_check.log
WHITE_LOGFILE=Linux_hardening_check.white.log
RED_LOGFILE=Linux_hardening_check.red.log
YELLOW_LOGFILE=Linux_hardening_check.yellow.log
GREEN_LOGFILE=Linux_hardening_check.green.log

#### End User defined variables ####

##################### Do not edit the lines below, please use variables above #####################

###################### Pre Fixed Variables ##############################
SERVER_NAME=`hostname`
CURRENTDATE=`date | awk '{print $3"-"$2"-"$6}'`
CURRENTTIMESTAMP=`date | awk '{print $4}' | sed '$ s/:/./g'`
CURRENT_HOUR=`date | awk '{print $4}' | awk -F ":" '{print $1$2}'`
PATH=$PATH:/bin:/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/usr/local/sbin
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

############################## Workdir creation #############################################
if [ ! -d $WORKDIR/$LOGDIR ]; then
 mkdir -p $WORKDIR/$LOGDIR
fi

###################### Help Menu ##########################################
if [ -z $1 ]; then
 echo "(MSG ARG 000): No arguments passed, continuing to regular task" | sed -e "s/^/$(date | awk '{print $3"-"$2"-"$6"-"$4}') /" >> $WORKDIR/$LOGDIR/$LOGFILE
else
 if [ $1 == "-help" ]; then
  echo "(MSG HELP 000): The script is intended to check the server hardening and qualification"
  exit 0;
 fi
fi

######################## Duplicate instance check ######################################
DUPLICATE_INSTANCE=2
DUPLICATE_INSTANCE=`ps -ef | grep $SCRIPT_NAME | grep -v grep | wc -l`
if [ $DUPLICATE_INSTANCE -ge 4 ]; then
 echo "(MSG DUP 000): Duplicate instance found, .. exiting." | sed -e "s/^/$(date | awk '{print $3"-"$2"-"$6"-"$4}') /" >> $WORKDIR/$LOGDIR/$LOGFILE
 exit 0;
fi
########################################################################################

test_normal()

{
echo -e "${YELLOW}#################################${NC}\n"
echo -e "${GREEN}Starting qualification test${NC}"
echo -e "${YELLOW}#################################${NC}\n"

sleep 1

VERSION_NUMBER=`cat $SCRIPT_NAME | grep -i version_n | head -1 | awk '{print $3}'`
echo -e "${GREEN}Script version number is $VERSION_NUMBER${NC}"
echo -e "${YELLOW}#################################${NC}\n"

sleep 1

REDHAT_RELEASE=`cat /etc/redhat-release`
echo -e "${GREEN}Linux Version: $REDHAT_RELEASE${NC}"
echo -e "${YELLOW}#################################${NC}\n"

sleep 1

echo -e "${YELLOW}######${NC} Starting NORMAL tests ${YELLOW}######${NC}\n"
GRUB_PASSWD_CHECK=0
GRUB_PASSWD_CHECK=`cat /boot/grub2/grub.cfg| grep -i password | grep sha | wc -l`
if [ $GRUB_PASSWD_CHECK == 1 ]; then
 echo -e "${GREEN}PASSED:: ${NC}Password is set in the Grub /boot/grub2/grub.cfg"
else
 echo -e "${RED}FAILED:: ${NC}Password is not set in the Grub /boot/grub2/grub.cfg"
fi
echo -e "${YELLOW}#################################${NC}\n"

sleep 1

GRUB_FILE_PERM_CHECK=0
GRUB_FILE_PERM_CHECK=`ls -l /boot/grub2/grub.cfg | grep "rw-------" | wc -l`
if [ $GRUB_FILE_PERM_CHECK == 1 ]; then
 echo -e "${GREEN}PASSED:: ${NC}600 permission is set on /boot/grub2/grub.cfg"
else
 echo -e "${RED}FAILED:: ${NC}600 permission is not set on /boot/grub2/grub.cfg"
fi
echo -e "${YELLOW}#################################${NC}\n"

sleep 1

DEVICE1=`mount | grep " / " | awk '{print $1}'`
DEVICE2=`mount | grep " /tmp " | awk '{print $1}'`
if [ $DEVICE1 == $DEVICE2 ]; then
 echo -e "${RED}FAILED:: ${NC}/tmp directory is using the same filesystem as main root filesystem"
else
 echo -e "${GREEN}PASSED:: ${NC}/tmp directory is using seperate filesystem from main root filesystem"
fi
echo -e "${YELLOW}#################################${NC}\n"

sleep 1

OPTION_TMP=`mount | grep " /tmp " | grep nosuid | grep nodev | wc -l`
if [ $OPTION_TMP == 1 ]; then
 echo -e "${GREEN}PASSED:: ${NC}/tmp is mounted with nodev and nosuid option"
else
 echo -e "${RED}FAILED:: ${NC}/tmp is not mounted with nodev and nosuid option"
fi
echo -e "${YELLOW}#################################${NC}\n"

sleep 1

OPTION_SHM=`mount | grep /dev/shm | grep nosuid | grep nodev | wc -l`
if [ $OPTION_SHM == 1 ]; then
 echo -e "${GREEN}PASSED:: ${NC}/dev/shm is mounted with nodev and nosuid option"
else
 echo -e "${RED}FAILED:: ${NC}/dev/shm is not mounted with nodev and nosuid option"
fi
echo -e "${YELLOW}#################################${NC}\n"

sleep 1

OPTION_SHADOW=`ls -l /etc/shadow | awk '{print $1}' | grep "^----------" | wc -l`
if [ $OPTION_SHADOW == 1 ]; then
 echo -e "${GREEN}PASSED:: ${NC}/etc/shadow file permission is set to 000"
else
 echo -e "${RED}FAILED:: ${NC}/etc/shadow file permission is not set to 000"
fi
echo -e "${YELLOW}#################################${NC}\n"

sleep 1

OPTION_21=`netstat -tulpn | grep ":21 " | grep "tcp "i | wc -l`
if [ $OPTION_21 == 1 ]; then
 echo -e "${RED}FAILED:: ${NC}Telnet Server or any other daemon running on port number 21"
else
 echo -e "${GREEN}PASSED:: ${NC}No daemon or Telnet Server is listening on port 21"
fi
echo -e "${YELLOW}#################################${NC}\n"

sleep 1

OPTION_513=`netstat -tulpn | grep ":513 " | grep "tcp " | wc -l`
OPTION_514=`netstat -tulpn | grep ":514 " | grep "tcp " | wc -l`
if [ $OPTION_513 == 1 ] || [ $OPTION_514 == 1 ]; then
 echo -e "${RED}FAILED:: ${NC}rlogin or rsh is listening on port 514 or 513"
else
 echo -e "${GREEN}PASSED:: ${NC}rlogin or rsh is not listening on port 514 or 513"
fi
echo -e "${YELLOW}#################################${NC}\n"

sleep 1

SSHD_ROOT_LOGIN=`cat /etc/ssh/sshd_config | grep -i "PermitRootLogin" | cut -c1 | grep -i p | wc -l`
if [ $SSHD_ROOT_LOGIN == 1 ]; then
 echo -e "${RED}FAILED:: ${NC}Permit root login is enabled in /etc/ssh/sshd_config"
else
 echo -e "${GREEN}PASSED:: ${NC}Permit root login is not enabled in /etc/ssh/sshd_config"
fi
echo -e "${YELLOW}#################################${NC}\n"

sleep 1

SSHD_PROTO=1
SSHD_PROTO=`cat /etc/ssh/sshd_config | grep -i "^Protocol" | awk '{print $2}'`
if [ $SSHD_PROTO == 1 ]; then
 echo -e "${RED}FAILED:: ${NC}sshd protocol is not set to 2"
else
 echo -e "${GREEN}PASSED:: ${NC}sshd protocol is set to 2"
fi
echo -e "${YELLOW}#################################${NC}\n"

sleep 1

PERMIT_EMP=`cat /etc/ssh/sshd_config | grep -i "^permitemptypasswords" | awk '{print $2}' | grep -i no | wc -l`
if [ $PERMIT_EMP == 1 ]; then
 echo -e "${GREEN}PASSED:: ${NC}Permit empty password in /etc/ssh/sshd_config is set to no"
else
 echo -e "${RED}FAILED:: ${NC}Permit empty password in /etc/ssh/sshd_config is not set to no"
fi
echo -e "${YELLOW}#################################${NC}\n"

sleep 1

SSHD_LOG=`cat /etc/ssh/sshd_config |  grep -i loglevel | awk '{print $2}' | grep -i info | wc -l`
if [ $SSHD_LOG == 1 ]; then
 echo -e "${GREEN}PASSED:: ${NC}SSH loglevel is set to INFO in /etc/ssh/sshd_config"
else
 echo -e "${RED}FAILED:: ${NC}SSH loglevel is not set to info in /etc/ssh/sshd_config"
fi
echo -e "${YELLOW}#################################${NC}\n"

sleep 1

OBS_PKG=0
OBS_PKG=`rpm -qa telnet-server rsh rlogin rcp ypserv ypbind tftp tftp-server talk talk-server telnet | wc -l`
if [ $OBS_PKG == 1 ]; then
 echo -e "${RED}FAILED:: ${NC}Either one or more obselete packages found"
 rpm -qa telnet-server rsh rlogin rcp ypserv ypbind tftp tftp-server talk talk-server telnet
else
 echo -e "${GREEN}PASSED:: ${NC}No obselete remote packages found"
fi
echo -e "${YELLOW}#################################${NC}\n"

sleep 1

}

test_normal
