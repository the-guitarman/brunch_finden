#!/bin/bash

#DATETIME=`date +%Y%m%d%H%M%S`
FILE="$HOME/db_dumps/brunch_finden.sql"

if [ -e "$FILE.bz2" ]; then
  rm "$FILE.bz2"
#  echo "$FILE.bz2 wurde geloescht."
else
  echo "$FILE.bz2 wurde nicht gefunden und konnte nicht geloescht werden."
fi

/usr/bin/mysqldump -u brunchfindensql --password='br4nch_f1nden_sql' brunch_finden > $FILE

sleep 5

if [ -e $FILE ]; then
  bzip2 $FILE
#  echo "$FILE.bz2 wurde erstellt."
else
  echo "$FILE wurde nicht gefunden und konnte nicht gzippt werden."
fi

