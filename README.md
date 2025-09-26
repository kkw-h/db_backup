# MySQL数据库自动备份工具

这个工具用于自动备份远程服务器上Docker容器中的MySQL数据库。

## 功能

- 连接到远程服务器 `172.31.11.151`
- 备份Docker容器 `mysql.internal` 中的 `db_name` 数据库
- 将备份文件保存到本地 `/path/db_backup/db_name` 目录
- 自动压缩备份文件以节省空间
- 自动删除30天前的旧备份
- 每天凌晨1点自动执行备份

## 使用方法

### 手动备份

如果需要立即执行备份，可以直接运行备份脚本：

```bash
./backup_mysql.sh
```

### 设置自动备份

要设置每天凌晨1点自动备份，请运行：

```bash
./setup_cron.sh
```

### 查看当前定时任务

```bash
crontab -l
```

### 查看备份日志

```bash
cat backup.log
```

## 注意事项

- 确保已经配置了与远程服务器的SSH免密登录
- 确保远程服务器上的Docker容器中MySQL的root密码已通过环境变量 `MYSQL_ROOT_PASSWORD` 设置
- 备份文件会以 `db_name_日期时间.sql.gz` 的格式保存