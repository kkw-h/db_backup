#!/bin/bash

# 设置变量
REMOTE_SERVER="root@172.31.11.151"
REMOTE_DB_CONTAINER="mysql.internal"
BACKUP_DIR="/path/db_backup/db_name"

echo "===== 环境检查 ====="

# 检查备份目录
echo "检查本地备份目录..."
if [ -d "$BACKUP_DIR" ]; then
    echo "✓ 备份目录存在: $BACKUP_DIR"
else
    echo "✗ 备份目录不存在，将创建..."
    mkdir -p "$BACKUP_DIR"
    if [ $? -eq 0 ]; then
        echo "✓ 备份目录已创建"
    else
        echo "✗ 无法创建备份目录，请检查权限"
        exit 1
    fi
fi

# 测试SSH连接
echo "测试SSH连接到远程服务器..."
ssh -q -o BatchMode=yes -o ConnectTimeout=5 $REMOTE_SERVER "echo 2>&1" >/dev/null
if [ $? -eq 0 ]; then
    echo "✓ SSH连接成功"
else
    echo "✗ SSH连接失败，请检查SSH配置或网络连接"
    echo "提示: 您可能需要设置SSH免密登录，运行以下命令:"
    echo "  ssh-keygen -t rsa -b 4096"
    echo "  ssh-copy-id $REMOTE_SERVER"
    exit 1
fi

# 检查Docker容器
echo "检查Docker容器是否存在..."
CONTAINER_EXISTS=$(ssh $REMOTE_SERVER "docker ps | grep $REMOTE_DB_CONTAINER")
if [ -n "$CONTAINER_EXISTS" ]; then
    echo "✓ Docker容器存在: $REMOTE_DB_CONTAINER"
else
    echo "✗ Docker容器不存在或未运行: $REMOTE_DB_CONTAINER"
    exit 1
fi

# 检查数据库连接
echo "检查数据库连接..."
DB_CHECK=$(ssh $REMOTE_SERVER "docker exec $REMOTE_DB_CONTAINER mysql -u root -p\$MYSQL_ROOT_PASSWORD -e 'SHOW DATABASES;' 2>/dev/null | grep db_name")
if [ -n "$DB_CHECK" ]; then
    echo "✓ 数据库连接成功，db_name数据库存在"
else
    echo "✗ 无法连接到数据库或db_name数据库不存在"
    echo "请检查MySQL用户名/密码或数据库名称"
    exit 1
fi

echo "===== 环境检查完成 ====="
echo "所有检查通过，备份环境配置正确"
echo "您可以运行 ./backup_mysql.sh 进行手动备份测试"
echo "或运行 ./setup_cron.sh 设置每天凌晨1点的自动备份"