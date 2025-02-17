# Installation  

Installation and configuration related 

## contents

- [Installation](#installation)
  - [contents](#contents)
  - [Db2](#db2)
  - [posgresql](#posgresql)
    - [standalone single](#standalone-single)
    - [Processes](#processes)
    - [user](#user)
      - [Execution file path](#execution-file-path)
      - [Install path](#install-path)
  - [mysql](#mysql)
    - [Using repository](#using-repository)

## Db2

Db2 installation image is about 1.5 ~ 2.X GB, not utliizing OS rpm package.       
Basically, using `./db2_install` from downloaded installation image.   
Recommend to install by root user, which is the general scenario.       

[content](#contents)  

## posgresql

[15.8 doc](https://www.postgresql.org/docs/15/)    

### standalone single  


[Redhat](https://www.postgresql.org/download/linux/redhat/)     

Popular version as of Sep.2024. : 15 (fully compatible with Redhat 8 )       

Example installation scripts (Postgre 15 on Redhat 8 )   
```sh
# Install the repository RPM:
sudo dnf install -y https://download.postgresql.org/pub/repos/yum/reporpms/EL-8-x86_64/pgdg-redhat-repo-latest.noarch.rpm

# Disable the built-in PostgreSQL module:
sudo dnf -qy module disable postgresql

# Install PostgreSQL:
sudo dnf install -y postgresql15-server

# Optionally initialize the database and enable automatic start:
sudo /usr/pgsql-15/bin/postgresql-15-setup initdb
sudo systemctl enable postgresql-15
sudo systemctl start postgresql-15
```

[content](#contents)  

### Processes  
```
[root@jstest1 ~]# systemctl status postgresql-15
● postgresql-15.service - PostgreSQL 15 database server
   Loaded: loaded (/usr/lib/systemd/system/postgresql-15.service; enabled; vendor preset: disabled)
   Active: active (running) since Thu 2024-09-12 00:36:41 PDT; 14s ago
     Docs: https://www.postgresql.org/docs/15/static/
  Process: 4493 ExecStartPre=/usr/pgsql-15/bin/postgresql-15-check-db-dir ${PGDATA} (code=exited, status=0/SUCCESS)
 Main PID: 4499 (postmaster)
    Tasks: 7 (limit: 49022)
   Memory: 17.6M
   CGroup: /system.slice/postgresql-15.service
           ├─4499 /usr/pgsql-15/bin/postmaster -D /var/lib/pgsql/15/data/
           ├─4501 postgres: logger
           ├─4502 postgres: checkpointer
           ├─4503 postgres: background writer
           ├─4505 postgres: walwriter
           ├─4506 postgres: autovacuum launcher
           └─4507 postgres: logical replication launcher

Sep 12 00:36:41 jstest1.fyre.ibm.com systemd[1]: Starting PostgreSQL 15 database server...
Sep 12 00:36:41 jstest1.fyre.ibm.com postmaster[4499]: 2024-09-12 00:36:41.048 PDT [4499] LOG:  redirecting log output to logging collector process
Sep 12 00:36:41 jstest1.fyre.ibm.com postmaster[4499]: 2024-09-12 00:36:41.048 PDT [4499] HINT:  Future log output will appear in directory "log".
Sep 12 00:36:41 jstest1.fyre.ibm.com systemd[1]: Started PostgreSQL 15 database server.


[root@jstest1 ~]# ps -ef |grep post |grep -v grep
postgres    4499       1  0 00:36 ?        00:00:00 /usr/pgsql-15/bin/postmaster -D /var/lib/pgsql/15/data/
postgres    4501    4499  0 00:36 ?        00:00:00 postgres: logger
postgres    4502    4499  0 00:36 ?        00:00:00 postgres: checkpointer
postgres    4503    4499  0 00:36 ?        00:00:00 postgres: background writer
postgres    4505    4499  0 00:36 ?        00:00:00 postgres: walwriter
postgres    4506    4499  0 00:36 ?        00:00:00 postgres: autovacuum launcher
postgres    4507    4499  0 00:36 ?        00:00:00 postgres: logical replication launcher
```   

Parent process    
- postmaster : Manages the entire PostgreSQL instance, including handling database connections, starting/stopping services, and other administrative tasks.   

Below are child process.   

- logger : Writes messages about system errors, warnings, and information to log files.   
- Checkpointer : Periodically writes changes from memory to disk, ensuring data integrity by creating checkpoints. ( DB2 : log flush )   
- background writer : Helps to write dirty buffers to disk to reduce the work the checkpointer has to do. ( DB2 : page cleaner )    
-  WAL writer : Writes data from the WAL (Write-Ahead Logging) buffer to disk, ensuring that transactions are durable. ( DB2 : db2loggw )    
- autovacumm launcher : Handles the automatic vacuuming of tables, which is essential for preventing table bloat and maintaining performance. ( DB2 : auto reorg ? )    
- logical replication launcher :  Handles logical replication, which allows selective replication of data changes to another PostgreSQL server. (DB2 : SQL replication )         

> Db2 has all above within one 'db2sysc' process as theads. ( Aka Edu )      

[content](#contents)   

### user  

'postgres` user and group is created automatically.   
```
# grep postgre /etc/passwd
postgres:x:26:26:PostgreSQL Server:/var/lib/pgsql:/bin/bash
# grep postgre /etc/group
postgres:x:26
```

The followings are added to profile.   
```
su - postgres   

$ cat .bash_profile
[ -f /etc/profile ] && source /etc/profile
PGDATA=/var/lib/pgsql/15/data
export PGDATA
# If you want to customize your settings,
# Use the file below. This is not overridden
# by the RPMS.
[ -f /var/lib/pgsql/.pgsql_profile ] && source /var/lib/pgsql/.pgsql_profile
```

Init DB logs    
``` 
$ cat ./15/initdb.log
The files belonging to this database system will be owned by user "postgres".
This user must also own the server process.

The database cluster will be initialized with locale "en_US.UTF-8".
The default database encoding has accordingly been set to "UTF8".
The default text search configuration will be set to "english".

Data page checksums are disabled.  <====  no page checksum check by default ?  

fixing permissions on existing directory /var/lib/pgsql/15/data ... ok
creating subdirectories ... ok
selecting dynamic shared memory implementation ... posix
selecting default max_connections ... 100
selecting default shared_buffers ... 128MB
selecting default time zone ... America/Los_Angeles
creating configuration files ... ok
running bootstrap script ... ok
performing post-bootstrap initialization ... ok
syncing data to disk ... ok

Success. You can now start the database server using:

    /usr/pgsql-15/bin/pg_ctl -D /var/lib/pgsql/15/data/ -l logfile start
```

[content](#contents)   

#### Execution file path   

```
# which createdb
/usr/bin/createdb
# ls -al /usr/bin/createdb
lrwxrwxrwx 1 root root 32 Sep 12 00:36 /usr/bin/createdb -> /etc/alternatives/pgsql-createdb
# ls -l /etc/alternatives/pgsql-createdb
lrwxrwxrwx 1 root root 26 Sep 12 00:36 /etc/alternatives/pgsql-createdb -> /usr/pgsql-15/bin/createdb
```

[content](#contents)   

#### Install path  
Biggest file is 8.3 MB and all others are less than 1 MB.   

```
# find /usr/pgsql-15/ -type f  -exec du -h {} + |sort -rh  |more
8.3M	/usr/pgsql-15/bin/postgres
992K	/usr/pgsql-15/share/locale/ru/LC_MESSAGES/postgres-15.mo
...
724K	/usr/pgsql-15/bin/psql
...
```

About 660 files in the installation directory.   
250 files are message related.   
```
# find /usr/pgsql-15/ -type f  |wc -l
661

# find /usr/pgsql-15/ -type f |grep -v .mo  |wc -l
408

```
 
[content](#contents)     

## mysql

[MySQL Installation Guide](https://dev.mysql.com/doc/mysql-installation-excerpt/8.0/en/)     

[OS compatibility](https://www.mysql.com/support/supportedplatforms/database.html)   

### Using repository

[Redhat Yum](https://dev.mysql.com/doc/mysql-installation-excerpt/8.0/en/linux-installation-yum-repo.html)    


```sh

## download
MYSQL_YUMRPM="mysql84-community-release-el8-1.noarch.rpm" # For Red hat 8 and mysql 8.4 community   
wget https://dev.mysql.com/get/$MYSQL_YUMRPM
echo $?
sudo yum -y install $MYSQL_YUMRPM
yum repolist enabled | grep "mysql.*-community.*"
yum repolist enabled | grep mysql

sudo yum -y module disable mysql  # on Red Hat 8 only   

## install
sudo yum -y install mysql-community-server 

## start

systemctl start mysqld
systemctl status mysqld

systemctl stop mysqld

echo "validate_password.policy = LOW" >> /etc/my.cnf  # To use simple PW. Test system only

## Change the temp password to new PW and login
NEWPW="passw0rd"
mysql -u root -p$(sudo grep 'temporary password' /var/log/mysqld.log |awk '{print $13;}') --connect-expired-password -v  -e "ALTER USER 'root'@'localhost' IDENTIFIED BY '$NEWPW'; "

mysql -u root -p${NEWPW}


```



[content](#contents)   