#!/bin/bash

# 获取当前脚本的绝对路径
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BACKUP_SCRIPT="$SCRIPT_DIR/backup_mysql.sh"

# 创建新的crontab条目
CRON_JOB="0 1 * * * $BACKUP_SCRIPT >> $SCRIPT_DIR/backup.log 2>&1"

# 检查crontab中是否已存在该任务
EXISTING_CRON=$(crontab -l 2>/dev/null | grep -F "$BACKUP_SCRIPT")

if [ -z "$EXISTING_CRON" ]; then
    # 添加到现有crontab
    (crontab -l 2>/dev/null; echo "$CRON_JOB") | crontab -
    echo "已添加定时任务：每天凌晨1点执行数据库备份"
else
    echo "定时任务已存在，无需重复添加"
fi

echo "定时备份设置完成"