#!/bin/bash
# ============================================================
# 网上通讯录系统 - 一键部署脚本（适配任何云服务器）
# 支持：CentOS 7.9 / Ubuntu 20.04
# ============================================================

set -e

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

print_status() { echo -e "${GREEN}✅ ${NC}$1"; }
print_warning() { echo -e "${YELLOW}⚠️  ${NC}$1"; }
print_error() { echo -e "${RED}❌ ${NC}$1"; }
print_info() { echo -e "${BLUE}ℹ️  ${NC}$1"; }

# ---------------------------
# 配置区域（请修改此处）
# ---------------------------
SERVER_IP="你的服务器 IP"        # 例如：47.113.22.1
SERVER_USER="root"
SERVER_PASSWORD="你的服务器密码"

MYSQL_PASSWORD="mysql123456"    # MySQL root 密码（会自动设置）
APP_PORT=8080

# ---------------------------
# 本地检查
# ---------------------------
echo ""
print_info "===== 网上通讯录系统 - 一键部署 ====="
echo ""

# 检查 JAR 文件
if [ ! -f "backend/target/contact-system-1.0.0.jar" ]; then
    print_error "找不到 JAR 文件：backend/target/contact-system-1.0.0.jar"
    print_info "请先执行：mvn clean package -DskipTests"
    exit 1
fi
print_status "JAR 文件检查通过"

# 检查 WinSCP
if ! command -v winscp.com &>/dev/null; then
    print_warning "未检测到 WinSCP，将使用手动部署方式"
    USE_WINSCP=false
else
    USE_WINSCP=true
fi

# ---------------------------
# 生成远程部署脚本
# ---------------------------
print_info "生成远程部署脚本..."

cat > /tmp/remote-deploy.sh << 'REMOTE_SCRIPT'
#!/bin/bash
set -e

echo ""
echo "=========================================="
echo "  开始部署网上通讯录系统"
echo "=========================================="

# 1. 安装 Java 17
echo "[1/6] 安装 Java 17..."
if command -v java &>/dev/null; then
    JAVA_VER=$(java -version 2>&1 | head -n1)
    echo "  Java 已安装：$JAVA_VER"
else
    yum install -y java-17-openjdk || apt install -y openjdk-17-jdk
fi

# 2. 安装 MySQL
echo "[2/6] 安装 MySQL..."
if ! command -v mysql &>/dev/null; then
    # CentOS
    if command -v yum &>/dev/null; then
        yum install -y mysql-server mysql
        systemctl start mysqld
        systemctl enable mysqld
    # Ubuntu
    elif command -v apt &>/dev/null; then
        apt update
        apt install -y mysql-server
        systemctl start mysql
        systemctl enable mysql
    fi
fi

# 3. 配置 MySQL
echo "[3/6] 配置 MySQL..."
TEMP_PASS=$(grep 'temporary password' /var/log/mysqld.log 2>/dev/null | awk '{print $NF}' || echo "")
if [ -n "$TEMP_PASS" ]; then
    mysql -u root -p"$TEMP_PASS" --connect-expired-password -e "ALTER USER 'root'@'localhost' IDENTIFIED BY 'mysql123456';" 2>/dev/null || true
fi

# 4. 创建数据库
echo "[4/6] 创建数据库..."
mysql -u root -p"mysql123456" -e "CREATE DATABASE IF NOT EXISTS contact_system DEFAULT CHARACTER SET utf8mb4;" 2>/dev/null || {
    # 尝试无密码登录
    mysql -u root -e "CREATE DATABASE IF NOT EXISTS contact_system DEFAULT CHARACTER SET utf8mb4;" 2>/dev/null || true
}

# 导入表结构
if [ -f "init.sql" ]; then
    mysql -u root -p"mysql123456" contact_system < init.sql 2>/dev/null || \
    mysql -u root contact_system < init.sql 2>/dev/null || true
    echo "  数据库初始化完成"
fi

# 5. 停止旧进程
echo "[5/6] 停止旧进程..."
PID=$(ps -ef | grep contact-system | grep -v grep | awk '{print $2}')
if [ -n "$PID" ]; then
    kill -9 $PID 2>/dev/null || true
    echo "  已停止旧进程"
fi

# 6. 启动应用
echo "[6/6] 启动应用..."
nohup java -jar contact-system-1.0.0.jar \
    -Dspring.datasource.url="jdbc:mysql://localhost:3306/contact_system?useUnicode=true&characterEncoding=utf-8&serverTimezone=Asia/Shanghai" \
    -Dspring.datasource.username=root \
    -Dspring.datasource.password=mysql123456 \
    > contact-system.log 2>&1 &

sleep 5

# 7. 检查状态
if ps -ef | grep contact-system | grep -v grep > /dev/null; then
    echo ""
    echo "=========================================="
    echo "  🎉 部署完成！"
    echo "=========================================="
    echo "  访问地址：http://$(curl -s ifconfig.me):8080"
    echo "  管理员账号：admin / admin123"
    echo "  日志查看：tail -f contact-system.log"
    echo "=========================================="
else
    echo "  ❌ 应用启动失败，请检查日志"
    tail -20 contact-system.log
fi
REMOTE_SCRIPT

chmod +x /tmp/remote-deploy.sh

# ---------------------------
# 部署方式选择
# ---------------------------
echo ""
print_info "请选择部署方式："
echo ""
echo "  1) 自动部署（使用 WinSCP 上传并执行）"
echo "  2) 手动部署（生成部署指南，手动 SSH 操作）"
echo ""
read -p "请选择 [1/2]: " DEPLOY_MODE

if [ "$DEPLOY_MODE" = "1" ] && [ "$USE_WINSCP" = true ]; then
    # 自动部署
    print_info "开始自动部署..."
    
    # 创建 WinSCP 脚本
    cat > /tmp/winscp-script.txt << WINSCP_SCRIPT
option batch abort
option confirm off
open sftp://$SERVER_USER:$SERVER_PASSWORD@$SERVER_IP/
mkdir /home/root/contact-system
cd /home/root/contact-system
put "backend/target/contact-system-1.0.0.jar"
put "sql/init.sql"
put "/tmp/remote-deploy.sh"
call bash -c "cd /home/root/contact-system && chmod +x remote-deploy.sh && ./remote-deploy.sh"
exit
WINSCP_SCRIPT

    print_status "执行上传和部署..."
    winscp.com /script=/tmp/winscp-script.txt
    
    print_status "部署完成！"
else
    # 手动部署指南
    echo ""
    echo "=========================================="
    echo "  手动部署指南"
    echo "=========================================="
    echo ""
    echo "步骤 1: SSH 登录服务器"
    echo "  ssh $SERVER_USER@$SERVER_IP"
    echo ""
    echo "步骤 2: 创建项目目录"
    echo "  mkdir -p /home/root/contact-system"
    echo "  cd /home/root/contact-system"
    echo ""
    echo "步骤 3: 上传文件（使用 WinSCP 或 scp）"
    echo "  - backend/target/contact-system-1.0.0.jar"
    echo "  - sql/init.sql"
    echo "  - deploy/remote-deploy.sh"
    echo ""
    echo "步骤 4: 执行部署脚本"
    echo "  chmod +x remote-deploy.sh"
    echo "  ./remote-deploy.sh"
    echo ""
    echo "步骤 5: 配置防火墙（在云控制台）"
    echo "  开放端口：8080"
    echo ""
    echo "=========================================="
fi

echo ""
print_info "部署脚本已生成：/tmp/remote-deploy.sh"
