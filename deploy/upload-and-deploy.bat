@echo off
REM ============================================================
REM 网上通讯录系统 - 本地上传部署脚本 (Windows)
REM 用于将构建好的JAR文件上传到云服务器并部署
REM ============================================================

setlocal enabledelayedexpansion

REM ---------------------------
REM 配置区域（请根据你的服务器实际情况修改）
REM ---------------------------
set SERVER_IP=10.211.55.20
set SERVER_USER=root
set SERVER_PASSWORD=your_password
set SERVER_PATH=/home/root/contact-system
set JAR_FILE=E:\py\1\contact-system\backend\target\contact-system-1.0.0.jar

REM ---------------------------
REM 检查前置条件
REM ---------------------------
echo.
echo [1/4] 检查前置条件...

REM 检查JAR文件是否存在
echo Checking JAR file...
if not exist "%JAR_FILE%" (
    echo ❌ 错误: 找不到JAR文件: %JAR_FILE%
    echo 请先运行: mvn clean package -DskipTests
    pause
    exit /b 1
)

echo ✅ JAR文件存在

REM 检查WinSCP是否存在
where winscp.com >nul 2>&1
if %errorlevel% neq 0 (
    echo ❌ 错误: 未找到 WinSCP
    echo 请下载并安装 WinSCP: https://winscp.net/eng/download.php
    pause
    exit /b 1
)

echo ✅ WinSCP已安装

REM ---------------------------
REM 创建部署脚本
REM ---------------------------
echo.
echo [2/4] 创建远程部署脚本...

set DEPLOY_SCRIPT=%TEMP%\deploy-script.txt

echo option batch abort > "%DEPLOY_SCRIPT%"
echo option confirm off >> "%DEPLOY_SCRIPT%"
echo open sftp://%SERVER_USER%:%SERVER_PASSWORD%@%SERVER_IP%/ >> "%DEPLOY_SCRIPT%"
echo mkdir %SERVER_PATH% >> "%DEPLOY_SCRIPT%"
echo cd %SERVER_PATH% >> "%DEPLOY_SCRIPT%"
echo put "%JAR_FILE%" >> "%DEPLOY_SCRIPT%"
echo put "E:\py\1\contact-system\sql\init.sql" >> "%DEPLOY_SCRIPT%"
echo call bash -c "cd %SERVER_PATH% && chmod +x deploy-to-cloud.sh && ./deploy-to-cloud.sh" >> "%DEPLOY_SCRIPT%"
echo exit >> "%DEPLOY_SCRIPT%"

echo ✅ 部署脚本创建完成

REM ---------------------------
REM 执行上传和部署
REM ---------------------------
echo.
echo [3/4] 执行上传和部署...

echo 正在连接服务器 %SERVER_IP%...

REM 使用WinSCP执行脚本
winscp.com /script="%DEPLOY_SCRIPT%" /log="%TEMP%\winscp.log"
if %errorlevel% neq 0 (
    echo ❌ 上传失败！
    echo 请检查日志: %TEMP%\winscp.log
    pause
    exit /b 1
)

echo ✅ 文件上传完成

REM ---------------------------
REM 显示完成信息
REM ---------------------------
echo.
echo [4/4] 部署完成！
echo.
echo ==========================================
echo 🎉 网上通讯录系统部署成功！
echo ==========================================
echo.
echo 访问地址: http://%SERVER_IP%:8080
echo 管理员账号: admin / admin123
echo.
echo 日志查看命令:
echo   ssh %SERVER_USER%@%SERVER_IP%
echo   tail -f /home/root/contact-system/contact-system.log
echo.
echo 如果需要重新部署，请运行此脚本
echo 或直接登录服务器执行:
echo   cd /home/root/contact-system
echo   ./deploy-to-cloud.sh
echo.
pause