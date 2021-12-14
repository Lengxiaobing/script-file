#!/bin/bash
#####################################################Environment Setting#######################################################

# linux命令用法：

# 1.启动所有jar程序：sh service.sh start all
# 2.停止所有jar程序：sh service.sh stop all
# 3.重启所有jar程序：sh service.sh restart all
# 4.单独启动、停止、重启某个jar程序：把最后面的all替换为某个jar程序的代码即可

#程序代码数组
APPS=(
  DGovModService
  DGovModWeb
)

#程序名称数组
NAMES=(
  数据治理模块后端
  数据治理模块前端
)

#jar包数组
JARS=(
  DGovModService.jar
  DGovModWeb.jar
)

#jar包路径数组
PATHS=(
  /root/jar/DGovModService
  /root/jar/DGovModWeb
)

start() {
  # 程序代码
  local APPNAME=
  # 程序名称
  local NAME=
  # jar名称
  local CLASSNAME=
  # jar包路径
  local PROJECTDIR=
  # 启动命令
  local command="sh service.sh start"
  # 参数2:启动的类型
  local cmd2="$1"
  # 状态:判定参数是否符合要求
  local cmd2ok=0
  # 计时:记录app启动时间
  local cnt=0
  # 计数:启动app的个数
  local okcnt=0

  echo "---------------------------开始启动服务..."

  for ((i = 0; i < ${#APPS[@]}; i++)); do
    APPNAME=${APPS[$i]}
    NAME=${NAMES[$i]}
    CLASSNAME=${JARS[$i]}
    PROJECTDIR=${PATHS[$i]}
    if [ "$cmd2" == "all" ] || [ "$cmd2" == "$APPNAME" ]; then
      cmd2ok=1
      cnt=0

      PID=$(ps -ef | grep $(echo $CLASSNAME | awk -F/ '{print $NF}') | grep -v grep | awk '{print $2}')
      # -n 表示长度大于0时为真
      if [ -n "$PID" ]; then
        echo "$APPNAME---$NAME:己经运行,PID=$PID"
      else
        cd $PROJECTDIR
        rm -f $PROJECTDIR/nohup.out
        command="nohup java -jar $CLASSNAME"
        exec $command >>$PROJECTDIR/nohup.out &

        PID=$(ps -ef | grep $(echo $CLASSNAME | awk -F/ '{print $NF}') | grep -v grep | awk '{print $2}')

        # -z 表示长度为0时为真
        while [ -z "$PID" ]; do
          if (($cnt == 30)); then
            echo "$APPNAME---$NAME:$cnt秒内未启动，请检查！"
            break
          fi

          cnt=$(($cnt + 1))
          sleep 1s
          PID=$(ps -ef | grep $(echo $CLASSNAME | awk -F/ '{print $NF}') | grep -v grep | awk '{print $2}')
        done

        okcnt=$(($okcnt + 1))
        echo "$APPNAME---$NAME:己经成功启动,PID=$PID"
      fi
    fi
  done

  if (($cmd2ok == 0)); then
    echo "请输入存在的程序代码:"
    echo ${APPS[@]}
  else
    echo "---------------------------本次启动:$okcnt个服务"
  fi
}

stop() {
  local APPNAME=
  local CLASSNAME=
  local PROJECTDIR=
  local command="sh service.sh stop"
  local cmd2="$1"
  local cmd2ok=0
  local okcnt=0
  echo "---------------------------开始停止服务..."
  for ((i = 0; i < ${#APPS[@]}; i++)); do
    APPNAME=${APPS[$i]}
    NAME=${NAMES[$i]}
    CLASSNAME=${JARS[$i]}
    PROJECTDIR=${PATHS[$i]}
    if [ "$cmd2" == "all" ] || [ "$cmd2" == "$APPNAME" ]; then
      cmd2ok=1
      PID=$(ps -ef | grep $(echo $CLASSNAME | awk -F/ '{print $NF}') | grep -v grep | awk '{print $2}')

      if [ -n "$PID" ]; then
        echo "$NAME:PID=$PID准备结束"
        kill $PID

        PID=$(ps -ef | grep $(echo $CLASSNAME | awk -F/ '{print $NF}') | grep -v grep | awk '{print $2}')
        while [ -n "$PID" ]; do
          sleep 1s
          PID=$(ps -ef | grep $(echo $CLASSNAME | awk -F/ '{print $NF}') | grep -v grep | awk '{print $2}')
        done
        echo "$NAME:成功停止服务"
        okcnt=$(($okcnt + 1))
      else
        echo "$NAME:未运行"
      fi
    fi
  done

  if (($cmd2ok == 0)); then
    echo "请输入存在的程序代码:"
    echo ${APPS[@]}
  else
    echo "---------------------------本次共停止:$okcnt个服务"
  fi
}

case "$1" in
start)
  start "$2"
  exit 1
  ;;
stop)
  stop "$2"
  ;;
restart)
  stop "$2"
  start "$2"
  ;;
*)
  echo "command: start|stop|restart"
  exit 1
  ;;
esac
