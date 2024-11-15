#!/bin/bash

#source `pwd`/conf ## for /bin/ksh
source config.ini # use /bin/bash for reading from the current directory
source jscommon.sh


echo "OS is $PRETTY_NAME. "

case $RHEL_MAINVER in 
	7 ) MYSQL_YUMRPM="mysql84-community-release-el7-1.noarch.rpm" ;;
	8 ) MYSQL_YUMRPM="mysql84-community-release-el8-1.noarch.rpm" ;;
	9 ) MYSQL_YUMRPM="mysql84-community-release-el9-1.noarch.rpm" ;;
	* ) echo "$RHEL_MAINVER is unknown Red Hat version" && exit ;;
esac


installRepo(){
	wget https://dev.mysql.com/get/$MYSQL_YUMRPM
	
	if [ $? -ne 0 ]; then
		echo "..mysql repository download failure =>  https://dev.mysql.com/get/$MYSQL_YUMRPM "
  		exit 1 
	fi

	sudo yum -y install $MYSQL_YUMRPM
	yum repolist enabled | grep "mysql.*-community.*"
	yum repolist enabled | grep mysql
}

disableBuiltIn(){
	disp_msglvl2 "Disable the built-in mysql module ( on Red Hat 8 only ) "
	sudo yum -y module disable mysql  # on Red Hat 8 only
}

installPostgre(){
	
	disp_msglvl2 "Install mysql community "
	sudo yum -y install mysql-community-server 
}

initDB(){
	disp_msglvl1 "1st DB start "
	## start
	echo "Change policy to LOW... To use simple PW. Test system only"
	echo "validate_password.policy = LOW" >> /etc/my.cnf  
	systemctl start mysqld
	systemctl status mysqld
	
	disp_msglvl1 "Change the temp password to new PW and login"
	NEWPW="passw0rd"
	mysql -u root -p$(sudo grep 'temporary password' /var/log/mysqld.log |awk '{print $13;}') --connect-expired-password -v  -e "ALTER USER 'root'@'localhost' IDENTIFIED BY '$NEWPW'; "
	mysql -u root -p${NEWPW}
}


pgStatus(){
	disp_msglvl2 "status"
	systemctl status postgresql-${POSTGRE_VER}
	disp_msglvl2 "processes"
	ps -ef |grep post |grep -v grep
	
}	
	

installRepo
disableBuiltIn
installPostgre
initDB
pgStatus
