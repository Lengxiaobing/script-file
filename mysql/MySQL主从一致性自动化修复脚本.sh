#!/bin/bash
#####################################################Environment Setting#######################################################

dbuser=XXXX

dbpasswd="XXXXX"

port=3306

mycat_host=192.168.3.11
mycat_Port=8066

master_ip=XXXXX

slave_ip=XXXXX

password="XXXXX"

hostname=`XXXXX`

date=`date+%Y%m%d`

logfile="/usr/perconaToolkit/repair.log"

mycat_login="mysql -u"$dbuser" -p"$dbpasswd" -h"$mycat_host" -P"$mycat_Port

ssh_status=`XXXXX`

# 检查ssh免密登录是否正常
if [ $ssh_status != $hostname ]
then
    echo "\nthe ssh should be repair" >$logfile
    exit
else
    echo "\nthe ssh is ok" >$logfile
fi 

# 获取带有主键的表
SELECT DISTINCT
	CONCAT(
		T.TABLE_SCHEMA,
		'.',
		T.TABLE_NAME
	) AS SCHEMA_TABLE,
	T. ENGINE,
IF (
	ISNULL(C.CONSTRAINT_NAME),
	'NOPK',
	C.CONSTRAINT_NAME
) AS PK,
 S.INDEX_TYPE,
 T.TABLE_TYPE
FROM
	INFORMATION_SCHEMA. TABLES AS T
LEFT JOIN INFORMATION_SCHEMA.KEY_COLUMN_USAGE AS C ON (
	T.TABLE_SCHEMA = C.CONSTRAINT_SCHEMA
	AND T.TABLE_NAME = C.TABLE_NAME
	AND C.CONSTRAINT_NAME = 'PRIMARY'
)
LEFT JOIN INFORMATION_SCHEMA.STATISTICS AS S ON (
	T.TABLE_SCHEMA = S.TABLE_SCHEMA
	AND T.TABLE_NAME = S.TABLE_NAME
	AND S.INDEX_TYPE IN ('FULLTEXT', 'SPATIAL')
)
WHERE
	T.TABLE_SCHEMA NOT IN (
		'INFORMATION_SCHEMA',
		'PERFORMANCE_SCHEMA',
		'MYSQL',
		'SYS'
	)
AND T.TABLE_TYPE = 'BASE TABLE'
AND (
	T. ENGINE <> 'INNODB'
	OR C.CONSTRAINT_NAME IS NULL
	OR S.INDEX_TYPE IN ('FULLTEXT', 'SPATIAL')
)
ORDER BY
	SCHEMA_TABLE