# connect

Connecting and listing up objects.     

## contents

- [connect](#connect)
  - [contents](#contents)
  - [Db2](#db2)
  - [PosgreSQL](#posgresql)
    - [Allow remote connections](#allow-remote-connections)
  - [MariaDB](#mariadb)

## Db2

From server terminal 
```
DBNAME=sample
db2 connect to $DBNAME
db2 list tables for all  # all tables and views.
```


[content](#contents)  

## PosgreSQL

by 'postgres' user   
```
DBNAME=postgres
/usr/pgsql-15/bin/postgres -V  # server version 
psql -V # client version
psql -U postgres -P pager=off -d postgres
SELECT VERSION();
\l   : List databases
\du  : Display users   
\d      : List all objects - tables, views, sequences
\d+ <table name>
\dtmv  : List only tables and views
```

Run from OS terminal   
```
psql -d testdb -c "SELECT * FROM employees;"
```

[content](#contents)  

### Allow remote connections   

Edit /var/lib/pgsql/15/data/postgresql.conf     

> network port related.   

```
listen_addresses = '*'
#listen_addresses = 'localhost'
```

Still error. 
```
FATAL: no pg_hba.conf entry for host "9.30.248.153"
```

Edit /var/lib/pgsql/15/data/pg_hba.conf
```
##added at the end of the file   
host    all             all             0.0.0.0/0             md
```
Still error complaining empty password. ( postgres )   
```
The server requested SCRAM-based authentication, but the password is an empty string.
```

/var/lib/pgsql/15/data/pg_hba.conf
Changed to password for clear text test.    
```
##added by me
host    all             all             0.0.0.0/0             password
```

Still error
```
FATAL: empty password returned by client
```

Rather than changing about `postgres` user, created an application user and granted access to the DB     
```
psql -d testdb -c "CREATE USER testuser WITH PASSWORD 'testuser';"
psql -d testdb -c "GRANT CONNECT ON DATABASE testdb TO testuser;"
psql -d testdb -c "GRANT USAGE ON SCHEMA public TO testuser;"
psql -d testdb -c "GRANT SELECT, INSERT, UPDATE, DELETE ON ALL TABLES IN SCHEMA public TO testuser;"
psql -d testdb -c "ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT SELECT, INSERT, UPDATE, DELETE ON TABLES TO testuser "
```

Then, success. 


[content](#contents)   


## MariaDB

```
mariadb -u root  # connect by root, then create a test user giving password
show databases;
CREATE USER 'testuser'@'localhost' IDENTIFIED BY 'testuser';
FLUSH PRIVILEGES;
exit;

mariadb -u testuser -p  # connect by created user.  
show databases;
CREATE DATABASE testdb;
show databases;
use testdb;

CREATE TABLE employees (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(50) NOT NULL,
    age INT NOT NULL,
    department VARCHAR(50)
);
show tables;
INSERT INTO employees (name, age, department) VALUES 
('Alice', 30, 'HR'),
('Bob', 28, 'IT'),
('Charlie', 35, 'Finance');

SELECT * FROM employees;
```



[content](#contents)   

### MISC   

And this is an example connecting to postgresql service pod in IBM CP4D zendb.  
Find the primary DB and connect.     

```
PRIMARY_POD=`oc get cluster zen-metastore-edb -o jsonpath="{.status.currentPrimary}"` && oc exec -it $PRIMARY_POD bash -c postgres -- bash
```

[content](#contents)  
