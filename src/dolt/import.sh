#! /usr/bin/env bash

R="$(dirname -- $0)"
source "$R/../utils/error_reporting.sh"
trap 'report_error $? $LINENO "$BASH_COMMAND"' ERR

"$R/export_csv.sh" "$1" | pv | "$R/csv2sql.sh" | dolt sql
