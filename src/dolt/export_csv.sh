#! /usr/bin/env bash

R="$(dirname -- $0)"
source "$R/../utils/error_reporting.sh"
trap 'report_error $? $LINENO "$BASH_COMMAND"' ERR

sqlite3 "$1" -csv 'select * from auxilio order by nome'
