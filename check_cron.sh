#!/bin/bash

USER=$(whoami)
PM2_PATH="/home/${USER}/.npm-global/lib/node_modules/pm2/bin/pm2"
CRON_JOB="*/12 * * * * $PM2_PATH resurrect >> /home/$(whoami)/pm2_resurrect.log 2>&1"
REBOOT_COMMAND="@reboot pkill -kill -u $(whoami) && $PM2_PATH resurrect >> /home/$(whoami)/pm2_resurrect.log 2>&1"

# 保留的原始 cron 任务
CRON_TASK1="19 1 1 * * /usr/bin/env TZ=Asia/Shanghai /home/crazy262/auto-login.sh >/dev/null 2>&1"
CRON_TASK2="19 1 15 * * /usr/bin/env TZ=Asia/Shanghai /home/crazy262/auto-login.sh >/dev/null 2>&1"
CRON_TASK3="@reboot /usr/bin/env TZ=Asia/Shanghai /home/crazy262/auto-login.sh >/dev/null 2>&1"

echo "检查并添加 crontab 任务"

# 添加原始 cron 任务（保活）
(crontab -l | grep -F "$CRON_TASK1") || (crontab -l; echo "$CRON_TASK1") | crontab -
(crontab -l | grep -F "$CRON_TASK2") || (crontab -l; echo "$CRON_TASK2") | crontab -
(crontab -l | grep -F "$CRON_TASK3") || (crontab -l; echo "$CRON_TASK3") | crontab -

# 检查 pm2 是否安装并返回正确路径
if [ "$(command -v pm2)" == "/home/${USER}/.npm-global/bin/pm2" ]; then
  echo "已安装 pm2，并返回正确路径，启用 pm2 保活任务"
  (crontab -l | grep -F "$REBOOT_COMMAND") || (crontab -l; echo "$REBOOT_COMMAND") | crontab -
  (crontab -l | grep -F "$CRON_JOB") || (crontab -l; echo "$CRON_JOB") | crontab -
else
  echo "pm2 未安装在指定路径，请检查安装情况。"
fi
