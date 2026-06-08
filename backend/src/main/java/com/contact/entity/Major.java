package com.contact.entity;

import com.baomidou.mybatisplus.annotation.*;
import lombok.Data;
import java.time.LocalDateTime;

@Data
@TableName("major")
public class Major {
    @TableId(type = IdType.AUTO)
    private Long id;

    /** 专业名称 */
    private String name;

    /** 所属学院 */
    private String department;

    private LocalDateTime createTime;
}
