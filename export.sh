#!/usr/bin/bash
DIR_PATH="/home/oracle/dump/"
FILE_NAME=${DIR_PATH}$(date "+%Y.%m.%d")".csv"
SCHEMA="system/test@127.0.0.1/XE"
TABLE="customers"
USER="system"

sqlplus -s ${SCHEMA} @dump.sql ${USER} ${TABLE} ${FILE_NAME} > /dev/null