#!/bin/bash
#####################################################Environment Setting#######################################################

# MySQL用户名
user='root'
# MySQL密码
password='Yuhan123456'
# 主服务器ip
master_ip=$1
# 从服务器ip
slave_ip=$2

if [[ $# -eq 0 ]]; then
  echo "Usage: /bin/bash $(basename $0) master_ip slave_ip"
  exit 1
fi

# 配置master
sed -i '/# log_bin/a server-id=1' /etc/my.cnf
sed -i '/# log_bin/a log-bin=mysql-bin' /etc/my.cnf
sed -i '/# log_bin/a binlog-ignore-db=mysql' /etc/my.cnf
sed -i '/# log_bin/a binlog_format=MIXED' /etc/my.cnf

mysql --user=$user --password=$password -e "grant replication client,replication slave on *.* to 'replacer'@'"$slave_ip"' identified by 'replacer'; flush privileges; exit;"

systemctl restart mysqld.service

#配置slave
cat >master_slave.sh <<EOF
#!/bin/bash 

sed -i '/# log_bin/a server-id=2' /etc/my.cnf
sed -i '/# log_bin/a relay-log=relay-bin' /etc/my.cnf
sed -i '/# log_bin/a relay-log-index=relay-log.index' /etc/my.cnf
sed -i '/# log_bin/a read-only=on' /etc/my.cnf

#mysql

systemctl restart mysqld.service

EOF

log_file=$(mysql --user=$user --password=$password -e "show master status" | grep 'bin' | awk '{print $1}')
log_pos=$(mysql --user=$user --password=$password -e "show master status" | grep 'bin' | awk '{print $2}')

sed -i "/#mysql/a mysql --user="$user" --password="$password" -e \"change master to master_host="$master_ip", master_user='replacer', master_password='replacer', master_log_file="$log_file", master_log_pos="$log_pos"; start slave; flush privileges; exit;\"" master_slave.sh

echo $log_file
echo $log_pos

scp master_slave.sh $slave_ip:/root

ssh $slave_ip "/bin/bash /root/master_slave.sh"
