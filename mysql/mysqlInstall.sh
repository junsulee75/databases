#!/bin/bash

#source `pwd`/conf ## for /bin/ksh
source ../config.ini # use /bin/bash for reading from the current directory
source ../jscommon.sh


echo "OS is $PRETTY_NAME. "

case $RHEL_MAINVER in 
	7 ) MYSQL_YUMRPM="mysql84-community-release-el7-1.noarch.rpm" ;;
	8 ) MYSQL_YUMRPM="mysql84-community-release-el8-1.noarch.rpm" ;;
	9 ) MYSQL_YUMRPM="mysql84-community-release-el9-1.noarch.rpm" ;;
	* ) echo "$RHEL_MAINVER is unknown Red Hat version" && exit ;;
esac


installRepo(){
	
	print1 "mysql repository download : $MYSQL_YUMRPM "
	wget https://dev.mysql.com/get/$MYSQL_YUMRPM
	
	if [ $? -ne 0 ]; then
		echo "..mysql repository download failure "
  		exit 1 
	fi

	print1 "Enabling mysql repos "
	sudo yum -y install $MYSQL_YUMRPM
	yum repolist enabled | grep "mysql.*-community.*"
	yum repolist enabled | grep mysql
}

disableBuiltIn(){
	disp_msglvl1 "Disable the built-in mysql module ( on Red Hat 8 only ) "
	sudo yum -y module disable mysql  # on Red Hat 8 only
}

installDB(){
	
	disp_msglvl1 "Install mysql community "
	sudo yum -y install mysql-community-server 
}

initDB(){
	disp_msglvl1 "1st DB start "
	## start
 
	systemctl start mysqld
	systemctl status mysqld

	print1 "Change policy to LOW... To use simple PW. Test system only"
	print2 "Stopping mysqld"
	systemctl stop mysqld
	systemctl status mysqld
	echo "validate_password.policy = LOW" >> /etc/my.cnf  # mysqld start issue if I do this before the 1st start.  
	
	print2 "Starting mysqld again"
	systemctl start mysqld
	systemctl status mysqld

	print2 "Change the temp password to new PW and login to mysql"
	NEWPW="passw0rd"
	mysql -u root -p$(sudo grep 'temporary password' /var/log/mysqld.log |awk '{print $13;}') --connect-expired-password -v  -e "ALTER USER 'root'@'localhost' IDENTIFIED BY '$NEWPW'; "
	mysql -u root -p${NEWPW}
}


dbStatus(){
	disp_msglvl2 "status"
	systemctl status mysqld
	disp_msglvl2 "processes"
	ps -ef |grep post |grep -v grep
	
}	
	

installRepo
disableBuiltIn
installDB
initDB
dbStatus
