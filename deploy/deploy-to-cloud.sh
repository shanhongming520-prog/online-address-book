#!/bin/bash
# ============================================================
# 网上通讯录系统 - 云服务器部署脚本 (适配 CentOS 7)
# 专为 10.211.55.20 服务器定制
# ============================================================

set -e

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

print_status() {
    echo -e "${GREEN}✅ ${NC}$1"
}

print_warning() {
    echo -e "${YELLOW}⚠️  ${NC}$1"
}

print_error() {
    echo -e "${RED}❌ ${NC}$1"
}

print_info() {
    echo -e "${BLUE}ℹ️  ${NC}$1"
}

# ---------------------------
# 配置区域（请根据你的服务器实际情况修改）
# ---------------------------
MYSQL_HOST="localhost"
MYSQL_PORT="3306"
MYSQL_USER="root"
MYSQL_PASSWORD="your_root_password"   # <-- 请修改为你的MySQL密码
DB_NAME="contact_system"

APP_PORT=8080
JAR_FILE="contact-system-1.0.0.jar"
APP_NAME="contact-system"

# 数据库初始化SQL文件路径（相对于当前目录）
INIT_SQL="sql/init.sql"

# ---------------------------
# 1. 检查 Java 环境
# ---------------------------
echo ""
print_info "[1/7] 检查 Java 环境..."
if command -v java &>/dev/null; then
    JAVA_VER=$(java -version 2>&1 | head -n1)
    JAVA_MAJOR=$(java -version 2>&1 | head -n1 | grep -o 'version \"[0-9]*' | grep -o '[0-9]*')
    
    if [ "$JAVA_MAJOR" -ge "17" ]; then
        print_status "Java 已安装: $JAVA_VER"
    else
        print_error "Java 版本过低: $JAVA_VER (需要 JDK 17+)"
        print_info "请执行: sudo yum install java-17-openjdk"
        exit 1
    fi
else
    print_error "未检测到 Java，请先安装 Java 17+"
    print_info "CentOS 7 安装命令: sudo yum install java-17-openjdk"
    exit 1
fi

# ---------------------------
# 2. 检查 MySQL 环境
# ---------------------------
echo ""
print_info "[2/7] 检查 MySQL 环境..."
if command -v mysql &>/dev/null; then
    MYSQL_VER=$(mysql --version)
    print_status "MySQL 已安装: $MYSQL_VER"
else
    print_error "未检测到 MySQL 客户端"
    print_info "请执行: sudo yum install mysql"
    exit 1
fi

# ---------------------------
# 3. 检查并创建数据库
# ---------------------------
echo ""
print_info "[3/7] 初始化数据库..."
echo "  数据库: $DB_NAME @ $MYSQL_HOST:$MYSQL_PORT"

# 检查数据库是否已存在
if mysql -h"$MYSQL_HOST" -P"$MYSQL_PORT" -u"$MYSQL_USER" -p"$MYSQL_PASSWORD" -e "USE $DB_NAME" 2>/dev/null; then
    print_warning "数据库 $DB_NAME 已存在，跳过创建"
else
    echo "  正在创建数据库..."
    mysql -h"$MYSQL_HOST" -P"$MYSQL_PORT" -u"$MYSQL_USER" -p"$MYSQL_PASSWORD" -e "CREATE DATABASE IF NOT EXISTS $DB_NAME DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci;"
    print_status "数据库创建完成"
fi

# ---------------------------
# 4. 导入初始化数据
# ---------------------------
echo ""
print_info "[4/7] 导入初始化数据..."
if [ -f "$INIT_SQL" ]; then
    echo "  执行 SQL 初始化脚本..."
    mysql -h"$MYSQL_HOST" -P"$MYSQL_PORT" -u"$MYSQL_USER" -p"$MYSQL_PASSWORD" "$DB_NAME" < "$INIT_SQL"
    print_status "初始化数据导入完成"
else
    print_error "找不到初始化SQL文件: $INIT_SQL"
    print_info "请确保 sql/init.sql 文件存在"
    exit 1
fi

# ---------------------------
# 5. 检查 JAR 文件
# ---------------------------
echo ""
print_info "[5/7] 检查应用JAR文件..."
if [ -f "$JAR_FILE" ]; then
    JAR_SIZE=$(du -h "$JAR_FILE" | cut -f1)
    print_status "JAR 文件存在: $JAR_FILE ($JAR_SIZE)"
else
    print_error "找不到 JAR 文件: $JAR_FILE"
    print_info "请先构建项目: mvn clean package -DskipTests"
    exit 1
fi

# ---------------------------
# 6. 停止旧进程
# ---------------------------
echo ""
print_info "[6/7] 停止旧进程..."
PID=$(ps -ef | grep "$APP_NAME" | grep -v grep | awk '{print $2}')
if [ -n "$PID" ]; then
    kill -9 $PID
    print_status "已停止旧进程 (PID: $PID)"
else
    print_warning "没有运行中的进程"
fi

# ---------------------------
# 7. 启动应用
# ---------------------------
echo ""
print_info "[7/7] 启动应用..."

# 设置环境变量
export SPRING_PROFILES_ACTIVE=prod
export SERVER_PORT=$APP_PORT

# 后台启动
nohup java -jar \
    -Dspring.datasource.url="jdbc:mysql://$MYSQL_HOST:$MYSQL_PORT/$DB_NAME?useUnicode=true&characterEncoding=utf-8&serverTimezone=Asia/Shanghai&useSSL=false" \
    -Dspring.datasource.username="$MYSQL_USER" \
    -Dspring.datasource.password="$MYSQL_PASSWORD" \
    -Dlogging.level.com.contact=DEBUG \
    "$JAR_FILE" \
    > "$APP_NAME.log" 2>&1 &

NEW_PID=$!
print_status "应用已启动 (PID: $NEW_PID)"
echo "  日志文件: $APP_NAME.log"

# ---------------------------
# 8. 等待并检查启动状态
# ---------------------------
echo ""
print_info "[8/8] 检查应用启动状态..."
sleep 10

# 检查进程是否存活
if ps -p $NEW_PID > /dev/null 2>&1; then
    # 检查端口是否监听
    if lsof -i :$APP_PORT > /dev/null 2>&1 || netstat -tuln | grep ":$APP_PORT" > /dev/null 2>&1; then
        print_status "应用运行正常"
        echo ""
        echo "=========================================="
        echo "  🎉 部署完成！"
        echo "=========================================="
        echo "  访问地址: http://10.211.55.20:$APP_PORT"
        echo "  管理员账号: admin / admin123"
        echo "  日志查看: tail -f $APP_NAME.log"
        echo "=========================================="
        echo ""
    else
        print_error "应用启动失败：端口 $APP_PORT 未监听"
        print_info "请检查日志: tail -f $APP_NAME.log"
        exit 1
    fi
else
    print_error "应用启动失败：进程不存在"
    print_info "请检查日志: tail -f $APP_NAME.log"
    exit 1
fi
