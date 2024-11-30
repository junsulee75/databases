#!/bin/bash

sudo systemctl stop postgresql
sudo systemctl disable postgresql

sudo yum -y remove postgresql*

sudo rm -rf /var/lib/pgsql/
sudo rm -rf /etc/pgsql/
sudo rm -rf /usr/pgsql-*

sudo yum clean all