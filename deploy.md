# 网上通讯录系统 - 部署文档

## 一、环境要求

| 组件 | 最低版本 | 推荐版本 |
|------|---------|---------|
| Java | 17 | JDK 17 LTS |
| MySQL | 8.0 | 8.0+ |
| Node.js | 16 | 18+ |
| Maven | 3.8 | 3.9+ |

---

## 二、本地开发运行

### 2.1 数据库初始化

```sql
-- 执行 init.sql 脚本
mysql -u root -p < sql/init.sql
```

### 2.2 后端启动

```bash
cd backend

# 修改 application.yml 中的数据库连接信息
# spring.datasource.url / username / password

# 启动（开发模式）
mvnw.cmd spring-boot:run
# 或直接运行 JAR
java -jar target/contact-system-1.0.0.jar
```

后端默认运行在 **http://localhost:8080**

### 2.3 前端启动（开发模式）

```bash
cd frontend
npm install
npm run dev
```

前端默认运行在 **http://localhost:5173**，已配置代理转发 `/api` 到后端。

---

## 三、云服务器部署

### 3.1 前置准备

**云服务器要求：**
- 系统：CentOS 7+ / Ubuntu 18.04+
- 开放端口：8080（应用）、3306（MySQL，可选）、22（SSH）
- 建议配置：2核4G 以上

**安全组配置：**
```
入方向规则：
  TCP 22    - SSH 远程登录
  TCP 8080  - 应用访问端口
  TCP 3306  - MySQL（如需要远程访问）
```

### 3.2 安装依赖

#### CentOS

```bash
# 安装 Java 17
sudo yum install java-17-openjdk -y

# 安装 MySQL 8.0
sudo yum install mysql-server -y
sudo systemctl start mysqld
sudo systemctl enable mysqld
```

#### Ubuntu

```bash
# 安装 Java 17
sudo apt update && sudo apt install openjdk-17-jdk -y

# 安装 MySQL 8.0
sudo apt install mysql-server -y
sudo systemctl start mysql
sudo systemctl enable mysql
```

### 3.3 初始化数据库

```bash
# 登录 MySQL
mysql -u root -p

# 执行初始化脚本
source /path/to/sql/init.sql;

# 或
mysql -u root -p < /path/to/sql/init.sql
```

### 3.4 部署应用

#### 方式一：使用部署脚本（推荐）

```bash
# 1. 上传文件到服务器
scp -r sql/ deploy/ user@服务器IP:/opt/contact-system/
scp backend/target/contact-system-1.0.0.jar user@服务器IP:/opt/contact-system/

# 2. 登录服务器
ssh user@服务器IP

# 3. 修改部署脚本中的 MySQL 密码
vim deploy/deploy.sh
# 修改 MYSQL_PASSWORD="your_mysql_password" 为实际密码

# 4. 执行部署
chmod +x deploy/deploy.sh
bash deploy/deploy.sh
```

#### 方式二：systemd 服务管理（生产推荐）

```bash
# 1. 创建应用目录
sudo mkdir -p /opt/contact-system
sudo chown -R $(whoami):$(whoami) /opt/contact-system

# 2. 上传 JAR 文件
scp backend/target/contact-system-1.0.0.jar user@服务器IP:/opt/contact-system/

# 3. 配置 systemd 服务
sudo cp deploy/contact-system.service /etc/systemd/system/
sudo vim /etc/systemd/system/contact-system.service
# 修改 MySQL 密码和 Java 路径

# 4. 启动服务
sudo systemctl daemon-reload
sudo systemctl start contact-system
sudo systemctl enable contact-system

# 5. 查看状态
sudo systemctl status contact-system
sudo journalctl -u contact-system -f
```

### 3.5 验证部署

```bash
# 检查应用是否运行
curl http://localhost:8080/api/auth/info
# 预期返回: {"code":401,"message":"未登录或登录已过期","data":null}

# 浏览器访问
http://服务器公网IP:8080
```

---

## 四、Nginx 反向代理（可选）

```nginx
server {
    listen 80;
    server_name your_domain.com;  # 或服务器 IP

    # 访问日志
    access_log /var/log/nginx/contact-system-access.log;
    error_log  /var/log/nginx/contact-system-error.log;

    # 反向代理到后端
    location / {
        proxy_pass http://127.0.0.1:8080;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;

        # WebSocket 支持（如需要）
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection "upgrade";
    }
}
```

```bash
sudo nginx -t && sudo systemctl reload nginx
```

---

## 五、测试账号

| 角色 | 用户名 | 密码 |
|------|--------|------|
| 管理员 | admin | admin123 |

学生账号需自行注册，管理员审核后登录。

---

## 六、常见问题

### Q1: 应用启动失败 "Connection refused"
**原因：** MySQL 未启动或连接信息错误
```bash
# 检查 MySQL 状态
sudo systemctl status mysqld

# 检查 application.yml 中的数据库配置
```

### Q2: 前端页面空白 / 404
**原因：** Nginx 配置未支持 Vue Router history 模式
```nginx
# 在 server 块中添加
try_files $uri $uri/ /index.html;
```

### Q3: 跨域错误
**解决：** 确保后端 `WebConfig` 中 CORS 配置正确，或使用 Nginx 同域名代理。

### Q4: 数据库字符集问题
```sql
ALTER DATABASE contact_system CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci;
```

---

## 七、项目文件清单

```
contact-system/
├── backend/                      # 后端源码 (Spring Boot)
│   ├── src/main/java/           # Java 源代码
│   ├── src/main/resources/
│   │   ├── application.yml      # 配置文件
│   │   └── static/             # 前端构建产物（生产部署）
│   ├── pom.xml
│   └── mvnw.cmd                 # Maven Wrapper
├── frontend/                     # 前端源码 (Vue 3)
│   ├── src/
│   ├── package.json
│   └── vite.config.js
├── sql/
│   └── init.sql                 # 数据库初始化脚本
├── deploy/                       # 部署脚本
│   ├── deploy.sh                # 一键部署脚本 (Linux)
│   └── contact-system.service   # systemd 服务配置
├── docs/                         # 项目文档
├── build.bat                     # Windows 打包脚本
└── deploy.md                     # 本文档
```
