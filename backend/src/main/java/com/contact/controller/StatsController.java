package com.contact.controller;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.contact.dto.Result;
import com.contact.entity.Contact;
import com.contact.entity.SysUser;
import com.contact.service.ContactService;
import com.contact.service.SysUserService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.HashMap;
import java.util.Map;

@RestController
@RequestMapping("/api/stats")
public class StatsController {

    @Autowired
    private SysUserService sysUserService;

    @Autowired
    private ContactService contactService;

    @GetMapping
    public Result<?> getStats() {
        Map<String, Object> stats = new HashMap<>();
        stats.put("totalUsers", sysUserService.count(
                new LambdaQueryWrapper<SysUser>().eq(SysUser::getRole, "STUDENT")));
        stats.put("pendingUsers", sysUserService.count(
                new LambdaQueryWrapper<SysUser>().eq(SysUser::getRole, "STUDENT").eq(SysUser::getStatus, 0)));
        stats.put("approvedUsers", sysUserService.count(
                new LambdaQueryWrapper<SysUser>().eq(SysUser::getRole, "STUDENT").eq(SysUser::getStatus, 1)));
        stats.put("totalContacts", contactService.count());
        return Result.success(stats);
    }
}
