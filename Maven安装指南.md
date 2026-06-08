# Maven 手动安装指南

## 下载 Apache Maven 3.9.6

**国内镜像（推荐）：**
- 阿里云: https://mirrors.aliyun.com/apache/maven/maven-3/3.9.6/binaries/apache-maven-3.9.6-bin.zip
- 华为云: https://mirrors.huaweicloud.com/apache/maven/maven-3/3.9.6/binaries/apache-maven-3.9.6-bin.zip

**官方下载：**
- https://archive.apache.org/dist/maven/maven-3/3.9.6/binaries/apache-maven-3.9.6-bin.zip

## 安装步骤

### 1. 下载并解压
```cmd
# 下载 apache-maven-3.9.6-bin.zip
# 解压到 E:\maven
# 最终目录结构: E:\maven\bin\mvn.cmd
```

### 2. 配置环境变量
```cmd
# 设置 MAVEN_HOME = E:\maven
# 在 PATH 中添加 %MAVEN_HOME%\bin
```

### 3. 验证安装
```cmd
mvn -version
# 应显示:
# Apache Maven 3.9.6
# Java version: 17.0.19
```

### 4. 构建项目
```cmd
cd E:\py\1\contact-system\backend
mvn clean package -DskipTests
# 生成的 JAR 文件位置: target\contact-system-1.0.0.jar
```

## 注意事项

- 确保 JDK 17 已正确配置（JAVA_HOME 和 PATH）
- Maven 需要访问 Maven Central 仓库下载依赖（约 200MB）
- 如果网络受限，可以配置阿里云 Maven 镜像加速

## 阿里云 Maven 镜像配置

创建文件 `%USERPROFILE%\.m2\settings.xml`：

```xml
<?xml version="1.0" encoding="UTF-8"?>
<settings xmlns="http://maven.apache.org/SETTINGS/1.0.0"
          xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
          xsi:schemaLocation="http://maven.apache.org/SETTINGS/1.0.0
                              http://maven.apache.org/xsd/settings-1.0.0.xsd">
  <mirrors>
    <mirror>
      <id>aliyunmaven</id>
      <mirrorOf>*</mirrorOf>
      <name>阿里云公共仓库</name>
      <url>https://maven.aliyun.com/repository/public</url>
    </mirror>
  </mirrors>
</settings>
```
