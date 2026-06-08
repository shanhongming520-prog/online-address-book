package com.contact.mapper;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.contact.entity.Contact;
import org.apache.ibatis.annotations.Param;
import org.apache.ibatis.annotations.Select;
import java.util.List;

public interface ContactMapper extends BaseMapper<Contact> {

    @Select("<script>" +
            "SELECT c.*, u.real_name, m.name AS major_name, m.department " +
            "FROM contact c " +
            "LEFT JOIN sys_user u ON c.user_id = u.id " +
            "LEFT JOIN major m ON c.major_id = m.id " +
            "WHERE u.status = 1 AND u.role = 'STUDENT' " +
            "<if test='realName != null and realName != \"\"'> AND u.real_name LIKE CONCAT('%', #{realName}, '%') </if>" +
            "<if test='majorId != null'> AND c.major_id = #{majorId} </if>" +
            "<if test='className != null and className != \"\"'> AND c.class_name LIKE CONCAT('%', #{className}, '%') </if>" +
            "<if test='enrollYear != null'> AND c.enroll_year = #{enrollYear} </if>" +
            "<if test='graduateYear != null'> AND c.graduate_year = #{graduateYear} </if>" +
            "<if test='city != null and city != \"\"'> AND c.city LIKE CONCAT('%', #{city}, '%') </if>" +
            "<if test='employer != null and employer != \"\"'> AND c.employer LIKE CONCAT('%', #{employer}, '%') </if>" +
            "ORDER BY c.update_time DESC" +
            "</script>")
    List<Contact> selectContactList(@Param("realName") String realName,
                                     @Param("majorId") Long majorId,
                                     @Param("className") String className,
                                     @Param("enrollYear") Integer enrollYear,
                                     @Param("graduateYear") Integer graduateYear,
                                     @Param("city") String city,
                                     @Param("employer") String employer);
}
