#!/bin/bash
set -e

mkdir -p /run/mysqld
chown -R mysql:mysql /run/mysqld

export DB_PASSWORD=$(cat /run/secrets/db_password.txt) DB_ROOT_PASSWORD=$(cat /run/secrets/db_root_password.txt) 

envsubst < /template.sql > /db_commands.sql

exec mysqld --user=mysql
