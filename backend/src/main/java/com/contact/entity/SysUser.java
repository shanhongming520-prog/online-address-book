package com.contact.entity;

import com.baomidou.mybatisplus.annotation.*;
import lombok.Data;
import java.time.LocalDateTime;

@Data
@TableName("sys_user")
public class SysUser {
    @TableId(type = IdType.AUTO)
    private Long id;

    /** 用户名 */
    private String username;

    /** 密码(BCrypt加密) */
    private String password;

    /** 真实姓名 */
    private String realName;

    /** 角色: ADMIN/STUDENT */
    private String role;

    /** 审核状态: 0-待审核 1-已通过 2-已禁用 */
    private Integer status;

    /** 登录次数 */
    private Integer loginCount;

    /** 最近登录时间 */
    private LocalDateTime lastLoginTime;

    private LocalDateTime createTime;
    private LocalDateTime updateTime;
}
