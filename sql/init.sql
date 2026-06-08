-- ============================================================
-- 网上通讯录系统 数据库初始化脚本
-- ============================================================

CREATE DATABASE IF NOT EXISTS contact_system DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci;

USE contact_system;

-- -----------------------------------------------------------
-- 1. 用户表
-- -----------------------------------------------------------
DROP TABLE IF EXISTS `contact`;
DROP TABLE IF EXISTS `major`;
DROP TABLE IF EXISTS `sys_user`;

CREATE TABLE `sys_user` (
    `id`              BIGINT       NOT NULL AUTO_INCREMENT COMMENT '用户ID',
    `username`        VARCHAR(50)  NOT NULL COMMENT '用户名',
    `password`        VARCHAR(100) NOT NULL COMMENT '密码(BCrypt加密)',
    `real_name`       VARCHAR(50)  DEFAULT NULL COMMENT '真实姓名',
    `role`            VARCHAR(20)  NOT NULL DEFAULT 'STUDENT' COMMENT '角色: ADMIN/STUDENT',
    `status`          TINYINT      NOT NULL DEFAULT 0 COMMENT '审核状态: 0-待审核 1-已通过 2-已禁用',
    `login_count`     INT          NOT NULL DEFAULT 0 COMMENT '登录次数',
    `last_login_time` DATETIME     DEFAULT NULL COMMENT '最近登录时间',
    `create_time`     DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    `update_time`     DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    PRIMARY KEY (`id`),
    UNIQUE KEY `uk_username` (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='用户表';

-- -----------------------------------------------------------
-- 2. 专业表
-- -----------------------------------------------------------
CREATE TABLE `major` (
    `id`          BIGINT       NOT NULL AUTO_INCREMENT COMMENT '专业ID',
    `name`        VARCHAR(100) NOT NULL COMMENT '专业名称',
    `department`  VARCHAR(100) DEFAULT NULL COMMENT '所属学院',
    `create_time` DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    PRIMARY KEY (`id`),
    UNIQUE KEY `uk_name` (`name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='专业信息表';

-- -----------------------------------------------------------
-- 3. 通讯录信息表
-- -----------------------------------------------------------
CREATE TABLE `contact` (
    `id`             BIGINT       NOT NULL AUTO_INCREMENT COMMENT '记录ID',
    `user_id`        BIGINT       NOT NULL COMMENT '用户ID',
    `major_id`       BIGINT       DEFAULT NULL COMMENT '专业ID',
    `class_name`     VARCHAR(50)  DEFAULT NULL COMMENT '班级',
    `enroll_year`    INT          DEFAULT NULL COMMENT '入校年份',
    `graduate_year`  INT          DEFAULT NULL COMMENT '毕业年份',
    `employer`       VARCHAR(200) DEFAULT NULL COMMENT '就业单位',
    `city`           VARCHAR(50)  DEFAULT NULL COMMENT '所在城市',
    `phone`          VARCHAR(30)  DEFAULT NULL COMMENT '联系方式',
    `email`          VARCHAR(100) DEFAULT NULL COMMENT '电子邮箱',
    `avatar`         VARCHAR(500) DEFAULT NULL COMMENT '头像URL',
    `create_time`    DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    `update_time`    DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    PRIMARY KEY (`id`),
    UNIQUE KEY `uk_user_id` (`user_id`),
    KEY `idx_major_id` (`major_id`),
    CONSTRAINT `fk_contact_user` FOREIGN KEY (`user_id`) REFERENCES `sys_user` (`id`) ON DELETE CASCADE,
    CONSTRAINT `fk_contact_major` FOREIGN KEY (`major_id`) REFERENCES `major` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='通讯录信息表';

-- -----------------------------------------------------------
-- 初始数据
-- -----------------------------------------------------------
-- 管理员账号: admin / admin123
-- BCrypt哈希由应用启动时自动生成，此处插入明文标记，启动类会处理
INSERT INTO `sys_user` (`username`, `password`, `real_name`, `role`, `status`) VALUES
('admin', 'BCRYPT_ADMIN123', '系统管理员', 'ADMIN', 1);

-- 示例专业数据
INSERT INTO `major` (`name`, `department`) VALUES
('计算机科学与技术', '数学与计算机学院'),
('软件工程', '数学与计算机学院'),
('数据科学与大数据技术', '数学与计算机学院'),
('信息安全', '数学与计算机学院'),
('数学与应用数学', '数学与计算机学院'),
('信息与计算科学', '数学与计算机学院');
