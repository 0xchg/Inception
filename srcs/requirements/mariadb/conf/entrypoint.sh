#!/bin/bash
set -e

mkdir -p /run/mysqld
chown -R mysql:mysql /run/mysqld

envsubst < /template.sql > /db_commands.sql

exec mysqld --user=mysql
