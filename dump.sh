#!/bin/bash

## USER=
## PASSWORD=

MYSQL_SERVER=localhost
MYSQL_PORT=3306
REDIS_SERVER=localhost
REDIS_PORT=6371
MYSQL_DB_NAME=mysql
REDIS_DUMP_NAME=appendonly.aof
BACKUP_PATH=$HOME/backup_databases
REDIS_DOCKER_PATH_SAVE=/var/lib/docker/volumes/redis-slave-data/_data
dump_mysql() {

  # $1: server name
  # $2: server port
  # $3: database name
  echo "Dump is started... "
  mysqldump -h $1 -P $2 --protocol=tcp -uroot -proot $3 > $BACKUP_PATH/$3.sql
  ## Uncomment me when USER/PASSWORD variables will be assigned and delete the line above
  ## mysqldump -h $1 -P $2 --protocol=tcp -u$USER -p$PASSWORD $3 > $BACKUP_PATH/$3.sql
  tar zcvf $BACKUP_PATH/$(date +"%Y%m%d").$3.sql.tar.gz -C $BACKUP_PATH $3.sql
  rm -f $BACKUP_PATH/$3.sql
}

dump_redis() {

  cp $REDIS_DOCKER_PATH_SAVE/$REDIS_DUMP_NAME $BACKUP_PATH/$REDIS_DUMP_NAME
  tar zcvf $BACKUP_PATH/$(date +"%Y%m%d").$REDIS_DUMP_NAME.tar.gz -C $BACKUP_PATH $REDIS_DUMP_NAME
  rm -f $BACKUP_PATH/$REDIS_DUMP_NAME
}


delete_older_backups() {

  find $BACKUP_PATH/* -mtime +14 -exec rm -rf {} \;
}

system_check() {

  mysql_exists=/usr/bin/mysqldump
  if [[ -f $mysql_exists ]]; then
    echo "Mysqldump is installed"
  else
    echo "Mysqldump is not installed"
    # For centos os
    #sudo yum install MariaDB-client -y
    # For debian
    sudo apt-get install mysql-client -y
  fi
  redis_exists=/usr/bin/redis-cli
  if [[ -f $redis_exists ]] ; then
    echo "Redis cli is isntalled"
  else
    echo "Redis cli is not installed"
    # For centos os
    # sudo yum install redis
    # For debian
     sudo apt install redis-server
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
  dump_mysql $MYSQL_SERVER $MYSQL_PORT $MYSQL_DB_NAME
  dump_redis $REDIS_SERVER $REDIS_PORT
  delete_older_backups
else
  echo "No file, create one"
  system_check
  echo "System is fine you can run script to get dump"
fi
