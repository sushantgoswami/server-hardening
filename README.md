Linux Server hardening ( CentOS, Redhat )

This application and scripts are intended to check hardening of CentOS/Redhat 7,8 servers in large environment

to Deploy the application git clone the repo in the jump server

and run the deploy.yaml through ansible playbook. define the hosts in host.txt

this script also understand version control when new version of script is introduced. redeploy it with the same command.

# ansible-playbook -i host.txt deploy.yaml

manual checking can also be done through directly running Linux_hardening_check.sh on the server

# ./Linux_hardening_check.sh
