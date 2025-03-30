#!/bin/bash

PGUSER=$(grep postgres /etc/passwd |cut -d\: -f1); echo "postgressql user name : $PGUSER"
PGHOME=$(grep postgres /etc/passwd |cut -d\: -f6); echo "$PGUSER home path  $PGHOME" 

echo "Running this script is only permitted by $PGUSER"

if [ "$(whoami)" == "$PGUSER" ]; then
    echo "You are logged in as postgres."
else
    echo "You are NOT logged in as postgres. Your username is: $(whoami)"
    exit 1
fi

chkPGEnv(){
   echo "echolist up existing DBs";echo ;psql -c "\l"
   echo "Listing up database paths";echo ; psql -c "SHOW data_directory;"
   echo "port number";echo; psql -c "Show port"
}

crDB(){
    echo "create a testdb";echo
    createdb testdb
    chkPGEnv
    echo "create a test table";echo
    psql -d testdb -c "CREATE TABLE employees (id SERIAL PRIMARY KEY, name VARCHAR(100), age INT, department VARCHAR(50));"
    echo "List tables";echo
    psql -d testdb -c "\dt"
    echo "Table layout";echo
    psql -d testdb -c "\d employees"

    echo "Insert rows";echo
    psql -d testdb -c "INSERT INTO employees (name, age, department) VALUES ('Alice', 30, 'IT');"
    psql -d testdb -c "INSERT INTO employees (name, age, department) VALUES ('Cooper', 50, 'IT');"
    
    echo "select rows";echo
    psql -d testdb -c "SELECT * FROM employees;"
    
    #echo "Drop DB";echo
    #dropdb testdb
}

crUsr(){
    echo "create a test user";echo
    psql -d testdb -c "CREATE USER testuser WITH PASSWORD 'testuser';"
    echo "grant connection";echo
    psql -d testdb -c "GRANT CONNECT ON DATABASE testdb TO testuser;"
    echo "Assign Schema Usage (If Using public Schema)";echo
    psql -d testdb -c "GRANT USAGE ON SCHEMA public TO testuser;"
    echo "Grant Read & Write Access"
    psql -d testdb -c "GRANT SELECT, INSERT, UPDATE, DELETE ON ALL TABLES IN SCHEMA public TO testuser;"
    echo "Grant Future Table Access Automatically"
    psql -d testdb -c "ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT SELECT, INSERT, UPDATE, DELETE ON TABLES TO testuser "

}

chkEnv
crDB
crUsr