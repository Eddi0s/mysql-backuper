#!/bin/bash

BACKUP_DIR="/pad/naar/back-up/map"
MYSQL_USER="jouw_mysql_gebruiker"
MYSQL_PASSWORD="jouw_mysql_wachtwoord"

# Lijst van databases om back-up te maken
DATABASES=$(mysql -u$MYSQL_USER -p$MYSQL_PASSWORD -e "SHOW DATABASES;" | grep -Ev "(Database|information_schema|performance_schema|mysql)")

for DB in $DATABASES
do
    TIMESTAMP=$(date +"%Y_%m_%d_%H_%M")
        BACKUP_FILE="$BACKUP_DIR/$DB-$TIMESTAMP.sql"

    # Maak een nieuwe map als deze nog niet bestaat
    DB_BACKUP_DIR="$BACKUP_DIR/$DB"
    if [ ! -d "$DB_BACKUP_DIR" ]; then
        mkdir -p "$DB_BACKUP_DIR"
    fi

    # Maak een nieuwe backup
    mysqldump -u$MYSQL_USER -p$MYSQL_PASSWORD $DB > $BACKUP_FILE

    # Controleer het aantal bestaande backups voor deze database
    BACKUP_COUNT=$(ls -1 "$DB_BACKUP_DIR/$DB-"*.sql 2>/dev/null | wc -l)

    if [ $BACKUP_COUNT -ge 5 ]; then
        # Als er al 5 of meer backups zijn, verwijder dan de oudste
        OLDEST_BACKUP=$(ls -1t "$DB_BACKUP_DIR/$DB-"*.sql | tail -n 1)
        rm "$OLDEST_BACKUP"
    fi

    # Verplaats de nieuwe backup naar de juiste map
    mv "$BACKUP_FILE" "$DB_BACKUP_DIR/"
done
