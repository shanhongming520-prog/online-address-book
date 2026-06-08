package com.contact.entity;

import com.baomidou.mybatisplus.annotation.*;
import lombok.Data;
import java.time.LocalDateTime;

@Data
@TableName("contact")
public class Contact {
    @TableId(type = IdType.AUTO)
    private Long id;

    /** 用户ID */
    private Long userId;

    /** 专业ID */
    private Long majorId;

    /** 班级 */
    private String className;

    /** 入校年份 */
    private Integer enrollYear;

    /** 毕业年份 */
    private Integer graduateYear;

    /** 就业单位 */
    private String employer;

    /** 所在城市 */
    private String city;

    /** 联系方式 */
    private String phone;

    /** 电子邮箱 */
    private String email;

    /** 头像URL */
    private String avatar;

    private LocalDateTime createTime;
    private LocalDateTime updateTime;

    // ---- 非数据库字段，用于查询结果关联 ----
    @TableField(exist = false)
    private String realName;

    @TableField(exist = false)
    private String majorName;

    @TableField(exist = false)
    private String department;
}
