#!/bin/bash
# -------------------------------------------------------------------------------
# FileName:    mysql_backup.sh
# Describe:    Used for database backup
# Revision:    1.0
# Date:        2021/05/30
# Author:      zhuxiang

mysql_host="127.0.0.1"
mysql_port="3306"
mysql_user="root"
mysql_password="123456"
backup_dir=/mnt/backup

dt=date +'%Y%m%d_%H%M'

echo "Backup Begin Date:" $(date +"%Y-%m-%d %H:%M:%S")

# 备份全部数据库
echo 'mysqldump -h${mysql_host} -P${mysql_port} -u${mysql_user} -p${mysql_password} -R -E --all-databases --single-transaction > ${backup_dir}/mysql_backup_${dt}.sql'
mysqldump -h ${mysql_host} -P ${mysql_port} --user=${mysql_user} --password=${mysql_password} -R -E --all-databases --single-transaction >${backup_dir}/mysql_backup_${dt}.sql

find ${backup_dir} -mtime +7 -type f -name '*.sql' -exec rm -rf {} \;
echo "Backup Succeed Date:" $(date +"%Y-%m-%d %H:%M:%S")
