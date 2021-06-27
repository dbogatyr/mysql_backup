#!/bin/bash
# EX: sudo ./cron_changes.sh dbogatyr 

USERNAME=$1
BACKUP_PATH=/home/$USERNAME/backup_mysql
crontab -l -u $USERNAME > $USERNAME.date.cron
crontab -r -u $USERNAME

echo $USERNAME >> /etc/cron.allow

touch /var/spool/cron/$USERNAME
/usr/bin/crontab /var/spool/cron/$USERNAME
echo "* * * * * /bin/bash $BACKUP_PATH/dump.sh" >> /var/spool/cron/$USERNAME
