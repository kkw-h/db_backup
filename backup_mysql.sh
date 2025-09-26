#!/bin/bash

# 设置变量
REMOTE_SERVER="root@172.31.11.151"
REMOTE_DB_CONTAINER="mysql.internal"
DB_NAME="db_name"
BACKUP_DIR="/path/db_backup/db_name"
DATE=$(date +%Y%m%d_%H%M%S)
BACKUP_FILE="${DB_NAME}_${DATE}.sql"

# 确保备份目录存在
mkdir -p $BACKUP_DIR

# 登录远程服务器，使用docker执行mysqldump并将结果保存到本地
echo "开始备份数据库 ${DB_NAME}..."
ssh $REMOTE_SERVER "docker exec $REMOTE_DB_CONTAINER mysqldump -u root -p --password=\$MYSQL_ROOT_PASSWORD $DB_NAME" > "$BACKUP_DIR/$BACKUP_FILE"

# 检查备份是否成功
if [ $? -eq 0 ]; then
    echo "备份成功: $BACKUP_FILE"
    # 可选：压缩备份文件以节省空间
    gzip "$BACKUP_DIR/$BACKUP_FILE"
    echo "备份文件已压缩: ${BACKUP_FILE}.gz"
else
    echo "备份失败"
    exit 1
fi

# 可选：保留最近30天的备份，删除更早的备份
find $BACKUP_DIR -name "${DB_NAME}_*.sql*" -type f -mtime +30 -delete
echo "已清理30天前的备份文件"

echo "备份过程完成"