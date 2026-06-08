@echo off
REM ============================================================
REM 网上通讯录系统 - 本地打包脚本 (Windows)
REM 需要: Java 17+, Maven 3.8+
REM ============================================================

echo 正在构建前端...
cd frontend
call npm install
call npm run build
if errorlevel 1 (
    echo 前端构建失败！
    pause
    exit /b 1
)
echo 前端构建完成！

REM 复制前端产物到后端 static 目录
if not exist "..\backend\src\main\resources\static" mkdir "..\backend\src\main\resources\static"
node -e "var fs=require('fs'),path=require('path');function cp(s,d){fs.mkdirSync(d,{recursive:true});fs.readdirSync(s,{withFileTypes:true}).forEach(f=>{var sp=path.join(s,f.name),dp=path.join(d,f.name);f.isDirectory()?cp(sp,dp):fs.copyFileSync(sp,dp)})}cp('dist','..\backend\src\main\resources\static');console.log('done')"

echo 正在构建后端...
cd ..\backend
call mvnw.cmd clean package -DskipTests
if errorlevel 1 (
    echo 后端构建失败！
    pause
    exit /b 1
)

echo.
echo ============================================
echo  打包完成！
echo  JAR 文件位置: backend\target\contact-system-1.0.0.jar
echo ============================================
pause
