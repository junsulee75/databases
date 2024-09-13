#!/bin/bash

#source `pwd`/conf ## for /bin/ksh
source config.ini # use /bin/bash for reading from the current directory
source jscommon.sh


echo "OS is $PRETTY_NAME. Will install posgresql version  $POSTGRE_VER "

case $REHL_MAINVER in 
	8 ) REHL_REPO_URL="https://download.postgresql.org/pub/repos/yum/reporpms/EL-8-x86_64/pgdg-redhat-repo-latest.noarch.rpm" ;;
	* ) echo "$REHL_MAINVER is unknown version" && exit ;;
esac


installRepo(){
	disp_msglvl2 "Install Repository"   
	sudo dnf install -y $REHL_REPO_URL
}

disableBuiltIn(){
	disp_msglvl2 "Disable the built-in PostgreSQL module"
	sudo dnf -qy module disable postgresql
}

installPostgre(){
	
	disp_msglvl2 "Install posgresql version $POSTGRE_VER"
	sudo dnf install -y postgresql${POSTGRE_VER}-server
}

initDB(){
	disp_msglvl2 "Init DB"
	sudo /usr/pgsql-15/bin/postgresql-${POSTGRE_VER}-setup initdb
	disp_msglvl2 "Enable auto start"
	sudo systemctl enable postgresql-${POSTGRE_VER}
	sudo systemctl start postgresql-${POSTGRE_VER}
}


pgStatus(){
	disp_msglvl2 "status"
	systemctl status postgresql-${POSTGRE_VER}
	disp_msglvl2 "processes"
	ps -ef |grep post |grep -v grep
	
}	
	

#installRepo
#disableBuiltIn
#installPostgre
#initDB
pgStatus
