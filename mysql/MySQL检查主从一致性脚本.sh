#!/bin/bash
#####################################################Environment Setting#######################################################

# MySQL端口
port='3306'
# MySQL用户名
user='root'
# MySQL密码
password='Yuhan123456'
# 从服务器IP
HostGroup=('192.168.3.11' '192.168.3.12')
# 邮件发送者
source='……'
# 邮件接受者
target='……'
# 邮箱用户名
MailUser='……'
# 邮箱密码
MailPassword='……'
# 当前时间
date=$(date +%y%m%d-%H:%M:)

echo $date
for host in ${HostGroup[@]}; do
  title=$host': mysql master-slave replication problem alert'

  v1=$(mysql --host=$host --port=$port --user=$user --password=$password -e "show slave status\G" | awk '/Slave_IO_Running/' | awk -F ":" '{print $2}')
  v2=$(mysql --host=$host --port=$port --user=$user --password=$password -e "show slave status\G" | awk '/Slave_SQL_Running/' | awk -F ":" '{print $2}')
  v3=$(mysql --host=$host --port=$port --user=$user --password=$password -e "show slave status\G" | awk '/Seconds_Behind_Master/' | awk -F ":" '{print $2}')

  if [ $v1 = "" ]; then
    echo 'the username or password is wrong,or the mysql server is down,so we can not get value'
    content4='the username or password is wrong,or the mysql server is down,so we can not get value'
    # 发送邮件
    /usr/bin/sendEmail -f $source -t $target -s smtp.chinaunicom.cn -u $title -xu $MailUser -xp $MailPassword -m $content4
  else
    if [ $v1 = 'Yes' ]; then
      if [ $v2 = 'Yes' ]; then
        #判断sql进程是否出现延迟
        if [ $v3 != 0 ]; then
          if [ $v3 -ge 60 ]; then
            content3=$host': the status of io process and sql process is yes,but slave delayed '$v3' seconds,more than 1 minutes'
            echo $content3
            /usr/bin/sendEmail -f $source -t $target -s smtp.chinaunicom.cn -u $title -xu $MailUser -xp $MailPassword -m $content3
          else
            echo $host': the status of io process and sql process is yes,but slave delayed '$v3' seconds,less than 1 minutes'
          fi
        else
          echo 'There is no problem'
        fi
      else
        content2=$host': Slave_IO_Running status:'$v1',Slave_SQL_Running status:'$v2',please deal with it as soon as possible!'
        echo $content2
        /usr/bin/sendEmail -f $source -t $target -s smtp.chinaunicom.cn -u $title -xu $MailUser -xp $MailPassword -m $content2
      fi
    else
      content1=$host': Slave_IO_Running status:'$v1',Slave_SQL_Running status:'$v2',please deal with it as soon as possible!'
      echo $content1
      /usr/bin/sendEmail -f $source -t $target -s smtp.chinaunicom.cn -u $title -xu $MailUser -xp $MailPassword -m $content1
    fi
  fi
done
