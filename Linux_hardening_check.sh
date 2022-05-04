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

VERSION_NUMBER=`cat $SCRIPT_NAME | grep -i version_n | head -1 | awk '{print $3}'`
echo -e "${GREEN}Script version number is $VERSION_NUMBER${NC}"
echo -e "${YELLOW}#################################${NC}\n"

REDHAT_RELEASE=`cat /etc/redhat-release`
echo -e "${GREEN}Linux Version: $REDHAT_RELEASE${NC}"
echo -e "${YELLOW}#################################${NC}\n"

echo -e "${YELLOW}######${NC} Starting GRUB tests ${YELLOW}######${NC}\n"
GRUB_PASSWD_CHECK=0
GRUB_PASSWD_CHECK=`cat /boot/grub2/grub.cfg| grep -i password | grep sha | wc -l`
if [ $GRUB_PASSWD_CHECK == 1 ]; then
 echo -e "${GREEN}PASSED:: ${NC}Password is set in the Grub /boot/grub2/grub.cfg"
else
 echo -e "${RED}FAILED:: ${NC}Password is not set in the Grub /boot/grub2/grub.cfg"
fi
echo -e "${YELLOW}#################################${NC}\n"

GRUB_FILE_PERM_CHECK=0
GRUB_FILE_PERM_CHECK=`ls -l /boot/grub2/grub.cfg | grep "rw-------" | wc -l`
if [ $GRUB_FILE_PERM_CHECK == 1 ]; then
 echo -e "${GREEN}PASSED:: ${NC}600 permission is set on /boot/grub2/grub.cfg"
else
 echo -e "${RED}FAILED:: ${NC}600 permission is not set on /boot/grub2/grub.cfg"
fi
echo -e "${YELLOW}#################################${NC}\n"

}

test_normal
