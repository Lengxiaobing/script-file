#!/bin/bash
#####################################################Environment Setting#######################################################

#timedTask
# 清理日志

#spark log dir
sparkLog=/usr/spark/spark-2.3.1-bin-hadoop2.7/logs

#Number of reserved files
sparkNum=10
sparkNum=$(($sparkNum + 1))

#Delete spark log
ls -t $sparkLog/*.out.* | tail -n +$sparkNum | xargs rm -f

#hadoop log dir
hadoopLog=/usr/hadoop/hadoop-3.1.1/logs

#Number of reserved files
hadoopNum=5
hadoopNum=$(($hadoopNum + 1))

#Delete hadoop log
ls -t $hadoopLog/hadoop-root-historyserver-hadoop171.log.* | tail -n +$hadoopNum | xargs rm -f
ls -t $hadoopLog/hadoop-root-nodemanager-hadoop171.log.* | tail -n +$hadoopNum | xargs rm -f
ls -t $hadoopLog/hadoop-root-namenode-hadoop171.log.* | tail -n +$hadoopNum | xargs rm -f
ls -t $hadoopLog/hadoop-root-secondarynamenode-hadoop171.log.* | tail -n +$hadoopNum | xargs rm -f
ls -t $hadoopLog/hadoop-root-resourcemanager-hadoop171.log.* | tail -n +$hadoopNum | xargs rm -f
ls -t $hadoopLog/hadoop-root-datanode-hadoop171.log.* | tail -n +$hadoopNum | xargs rm -f

ls -t $hadoopLog/hadoop-root-nodemanager-hadoop171.out.* | tail -n +$hadoopNum | xargs rm -f
ls -t $hadoopLog/hadoop-root-secondarynamenode-hadoop171.out.* | tail -n +$hadoopNum | xargs rm -f
ls -t $hadoopLog/hadoop-root-namenode-hadoop171.out.* | tail -n +$hadoopNum | xargs rm -f
ls -t $hadoopLog/hadoop-root-resourcemanager-hadoop171.out.* | tail -n +$hadoopNum | xargs rm -f
ls -t $hadoopLog/hadoop-root-datanode-hadoop171.out.* | tail -n +$hadoopNum | xargs rm -f

#hive log dir
hiveLog=/usr/hive/logs
#Number of reserved files
hiveNum=10
hiveNum=$(($hiveNum + 1))
#Delete hive log
ls -t $hiveLog/hive.log.* | tail -n +$hiveNum | xargs rm -f
