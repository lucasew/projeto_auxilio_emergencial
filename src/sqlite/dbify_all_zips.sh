#! /usr/bin/env bash
# vim:ft=bash

set -euxo pipefail

R="$(dirname -- $0)"
# Since this file will be moved, its relative path to utils will change. For now, assume it'll be in src/sqlite
source "$R/../utils/error_reporting.sh"
trap 'report_error $? $LINENO "$BASH_COMMAND"' ERR

ZIPFOLDER=$1;shift;
DATABASE=$1;shift;
echo $R

for file in $ZIPFOLDER;
do
    echo "Processando arquivo $file..."
    "$R/zipcat.sh" "$file" | "$R/sqlify.sh" | "$R/sql2db.sh" "$DATABASE"
done
