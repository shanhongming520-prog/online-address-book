#!/bin/bash
# ============================================================
# 网上通讯录系统 - 云服务器部署脚本
# 适用环境: CentOS 7+/Ubuntu 18.04+
# 前置要求: Java 17+, MySQL 8.0+
# ============================================================

set -e

echo "=========================================="
echo "  网上通讯录系统 - 自动部署脚本"
echo "=========================================="

# ---------------------------
# 配置区域（按需修改）
# ---------------------------
MYSQL_HOST="localhost"
MYSQL_PORT="3306"
MYSQL_USER="root"
MYSQL_PASSWORD="your_mysql_password"   # <--- 修改为实际密码
DB_NAME="contact_system"

APP_PORT=8080
JAR_FILE="contact-system-1.0.0.jar"
APP_NAME="contact-system"

# ---------------------------
# 1. 检查 Java 环境
# ---------------------------
echo ""
echo "[1/6] 检查 Java 环境..."
if command -v java &>/dev/null; then
    JAVA_VER=$(java -version 2>&1 | head -n1)
    echo "  ✅ Java 已安装: $JAVA_VER"
else
    echo "  ❌ 未检测到 Java，请先安装 Java 17+"
    echo "  CentOS: sudo yum install java-17-openjdk"
    echo "  Ubuntu: sudo apt install openjdk-17-jdk"
    exit 1
fi

# ---------------------------
# 2. 检查 MySQL 环境
# ---------------------------
echo ""
echo "[2/6] 检查 MySQL 环境..."
if command -v mysql &>/dev/null; then
    echo "  ✅ MySQL 客户端已安装"
else
    echo "  ⚠️  未检测到 MySQL 客户端（如果 MySQL 在远程服务器可忽略）"
fi

# ---------------------------
# 3. 初始化数据库
# ---------------------------
echo ""
echo "[3/6] 初始化数据库..."
echo "  数据库: $DB_NAME @ $MYSQL_HOST:$MYSQL_PORT"

# 检查数据库是否已存在
DB_EXISTS=$(mysql -h"$MYSQL_HOST" -P"$MYSQL_PORT" -u"$MYSQL_USER" -p"$MYSQL_PASSWORD" -e "SELECT SCHEMA_NAME FROM INFORMATION_SCHEMA.SCHEMATA WHERE SCHEMA_NAME='$DB_NAME'" 2>/dev/null | grep -c "$DB_NAME" || echo "0")

if [ "$DB_EXISTS" -eq 0 ]; then
    echo "  正在创建数据库并导入初始化脚本..."
    mysql -h"$MYSQL_HOST" -P"$MYSQL_PORT" -u"$MYSQL_USER" -p"$MYSQL_PASSWORD" < init.sql
    echo "  ✅ 数据库初始化完成"
else
    echo "  ⚠️  数据库 $DB_NAME 已存在，跳过初始化"
fi

# ---------------------------
# 4. 停止旧进程
# ---------------------------
echo ""
echo "[4/6] 停止旧进程..."
PID=$(ps -ef | grep "$APP_NAME" | grep -v grep | awk '{print $2}')
if [ -n "$PID" ]; then
    kill -9 $PID
    echo "  ✅ 已停止旧进程 (PID: $PID)"
else
    echo "  ℹ️  没有运行中的进程"
fi

# ---------------------------
# 5. 启动应用
# ---------------------------
echo ""
echo "[5/6] 启动应用..."

# 设置环境变量
export SPRING_PROFILES_ACTIVE=prod
export SERVER_PORT=$APP_PORT

# 后台启动
nohup java -jar \
    -Dspring.datasource.url="jdbc:mysql://$MYSQL_HOST:$MYSQL_PORT/$DB_NAME?useUnicode=true&characterEncoding=utf-8&serverTimezone=Asia/Shanghai&useSSL=false" \
    -Dspring.datasource.username="$MYSQL_USER" \
    -Dspring.datasource.password="$MYSQL_PASSWORD" \
    -jar "$JAR_FILE" \
    > "$APP_NAME.log" 2>&1 &

NEW_PID=$!
echo "  ✅ 应用已启动 (PID: $NEW_PID)"
echo "  日志文件: $APP_NAME.log"

# ---------------------------
# 6. 等待并检查启动状态
# ---------------------------
echo ""
echo "[6/6] 检查应用启动状态..."
sleep 5

if ps -p $NEW_PID > /dev/null 2>&1; then
    echo "  ✅ 应用运行正常"
    echo ""
    echo "=========================================="
    echo "  部署完成！"
    echo "  访问地址: http://服务器IP:$APP_PORT"
    echo "  管理员账号: admin / admin123"
    echo "=========================================="
else
    echo "  ❌ 应用启动失败，请检查日志: $APP_NAME.log"
    tail -50 "$APP_NAME.log"
    exit 1
fi
