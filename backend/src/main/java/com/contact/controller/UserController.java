package com.contact.controller;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.contact.dto.Result;
import com.contact.entity.SysUser;
import com.contact.service.SysUserService;
import jakarta.servlet.http.HttpServletRequest;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api/admin/user")
public class UserController {

    @Autowired
    private SysUserService sysUserService;

    /**
     * 分页查询用户列表
     */
    @GetMapping("/list")
    public Result<?> list(@RequestParam(defaultValue = "1") Integer pageNum,
                          @RequestParam(defaultValue = "10") Integer pageSize,
                          @RequestParam(required = false) String realName,
                          @RequestParam(required = false) Integer status) {
        LambdaQueryWrapper<SysUser> wrapper = new LambdaQueryWrapper<>();
        wrapper.eq(SysUser::getRole, "STUDENT");
        if (realName != null && !realName.isEmpty()) {
            wrapper.like(SysUser::getRealName, realName);
        }
        if (status != null) {
            wrapper.eq(SysUser::getStatus, status);
        }
        wrapper.orderByDesc(SysUser::getCreateTime);

        Page<SysUser> page = new Page<>(pageNum, pageSize);
        Page<SysUser> result = sysUserService.page(page, wrapper);
        // 不返回密码
        result.getRecords().forEach(u -> u.setPassword(null));
        return Result.success(result);
    }

    /**
     * 审核通过
     */
    @PutMapping("/approve/{id}")
    public Result<?> approve(@PathVariable Long id) {
        SysUser user = sysUserService.getById(id);
        if (user == null) {
            return Result.error("用户不存在");
        }
        user.setStatus(1);
        sysUserService.updateById(user);
        return Result.success("审核通过");
    }

    /**
     * 批量审核通过
     */
    @PutMapping("/approveBatch")
    public Result<?> approveBatch(@RequestBody List<Long> ids) {
        for (Long id : ids) {
            SysUser user = sysUserService.getById(id);
            if (user != null) {
                user.setStatus(1);
                sysUserService.updateById(user);
            }
        }
        return Result.success("批量审核通过");
    }

    /**
     * 禁用账号
     */
    @PutMapping("/disable/{id}")
    public Result<?> disable(@PathVariable Long id) {
        SysUser user = sysUserService.getById(id);
        if (user == null) {
            return Result.error("用户不存在");
        }
        user.setStatus(2);
        sysUserService.updateById(user);
        return Result.success("已禁用该账号");
    }

    /**
     * 启用账号
     */
    @PutMapping("/enable/{id}")
    public Result<?> enable(@PathVariable Long id) {
        SysUser user = sysUserService.getById(id);
        if (user == null) {
            return Result.error("用户不存在");
        }
        user.setStatus(1);
        sysUserService.updateById(user);
        return Result.success("已启用该账号");
    }

    /**
     * 删除未审核通过的账号
     */
    @DeleteMapping("/delete/{id}")
    public Result<?> delete(@PathVariable Long id) {
        SysUser user = sysUserService.getById(id);
        if (user == null) {
            return Result.error("用户不存在");
        }
        if (user.getStatus() == 1) {
            return Result.error("只能删除未通过审核的账户");
        }
        sysUserService.removeById(id);
        return Result.success("删除成功");
    }
}
