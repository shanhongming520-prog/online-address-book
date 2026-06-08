package com.contact.config;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.contact.entity.Major;
import com.contact.entity.SysUser;
import com.contact.service.MajorService;
import com.contact.service.SysUserService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.CommandLineRunner;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.stereotype.Component;

import java.util.List;

/**
 * 应用启动时初始化管理员账号和专业数据
 */
@Component
public class DataInitializer implements CommandLineRunner {

    @Autowired
    private SysUserService sysUserService;

    @Autowired
    private MajorService majorService;

    private final BCryptPasswordEncoder passwordEncoder = new BCryptPasswordEncoder();

    @Override
    public void run(String... args) {
        // 检查是否存在管理员，不存在则创建
        SysUser admin = sysUserService.getOne(
                new LambdaQueryWrapper<SysUser>().eq(SysUser::getUsername, "admin")
        );
        if (admin == null) {
            admin = new SysUser();
            admin.setUsername("admin");
            admin.setPassword(passwordEncoder.encode("admin123"));
            admin.setRealName("系统管理员");
            admin.setRole("ADMIN");
            admin.setStatus(1);
            admin.setLoginCount(0);
            sysUserService.save(admin);
            System.out.println("✅ 管理员账号已创建: admin / admin123");
        } else if ("BCRYPT_ADMIN123".equals(admin.getPassword())) {
            // 修复SQL中插入的占位符密码
            admin.setPassword(passwordEncoder.encode("admin123"));
            sysUserService.updateById(admin);
            System.out.println("✅ 管理员密码已更新: admin / admin123");
        }

        // 初始化专业数据
        long majorCount = majorService.count();
        if (majorCount == 0) {
            String[][] majors = {
                    {"计算机科学与技术", "数学与计算机学院"},
                    {"软件工程", "数学与计算机学院"},
                    {"数据科学与大数据技术", "数学与计算机学院"},
                    {"信息安全", "数学与计算机学院"},
                    {"数学与应用数学", "数学与计算机学院"},
                    {"信息与计算科学", "数学与计算机学院"}
            };
            for (String[] m : majors) {
                Major major = new Major();
                major.setName(m[0]);
                major.setDepartment(m[1]);
                majorService.save(major);
            }
            System.out.println("✅ 专业数据已初始化");
        }
    }
}
