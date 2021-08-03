#!/bin/bash
# EX: sudo ./cron_changes.sh dbogatyr

USERNAME=$1
BACKUP_PATH=/tmp
# Backup current tasks
crontab -l -u $USERNAME > $USERNAME.date.cron
# Remove existing tasks
crontab -r -u $USERNAME

echo $USERNAME >> /etc/cron.allow

touch /var/spool/cron/$USERNAME
/usr/bin/crontab /var/spool/cron/$USERNAME
echo "* * * * * /bin/bash $BACKUP_PATH/dump.sh" >> /var/spool/cron/$USERNAME
chown $USERNAME:$USERNAME /var/spool/cron/$USERNAME
chmod 600 /var/spool/cron/$USERNAME
