#!/usr/bin/env bash

DB=$1;
mysql -uroot -pvagrant -e "DROP DATABASE IF EXISTS $DB";
mysql -uroot -pvagrant -e "CREATE DATABASE $DB";
