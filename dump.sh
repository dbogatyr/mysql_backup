#!/bin/bash

## USER=
## PASSWORD=

SERVER=localhost
PORT=3306

DB_NAME=mysql
BACKUP_PATH=$HOME/backup_mysql
dump() {

  # $1: server name
  # $2: server port
  # $3: database name
  echo "Dump is started... "
  mysqldump -h $1 -P $2 --protocol=tcp -uroot -proot $3 > $BACKUP_PATH/$3.sql
  ## Uncomment me when USER/PASSWORD variables will be assigned and delete the line above
  ## mysqldump -h $1 -P $2 --protocol=tcp -u$USER -p$PASSWORD $3 > $BACKUP_PATH/$3.sql
  tar zcvf $BACKUP_PATH/$(date +"%Y%m%d").tar.gz -C $BACKUP_PATH $3.sql
  rm -f $BACKUP_PATH/$3.sql

}

delete_older_backups() {

  find $BACKUP_PATH/* -mtime +14 -exec rm -rf {} \;
}


system_check() {

  mysql_exist=/usr/bin/mysqldump
  if [[ -f $mysql_exist ]]; then
    echo "Mysqldump is installed"
  else
    echo "Mysqldump is not installed"
    # For centos os
    #sudo yum install MariaDB-client -y
    # For debian
    sudo apt-get install mysql-client -y
  fi

  if [[ -f $BACKUP_PATH ]]; then
    return 0
  else
    mkdir -p $BACKUP_PATH
    chown $(whoami):$(whoami) -R $BACKUP_PATH
    chmod 777 -R $BACKUP_PATH
  fi

  cp $(basename $0) $BACKUP_PATH/$(basename $0)

}

checked_before() {

  check_file=$HOME/.checked_by_dump
  if [[ -f $check_file ]]; then
    return 0
  else
    touch $check_file
    return 1
  fi
}

if checked_before ; then
  echo "File exists"
  dump $SERVER $PORT $DB_NAME
  delete_older_backups
else
  echo "No file, create one"
  system_check
  echo "System is fine you can run script to get dump"
fi
