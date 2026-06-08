package com.contact.controller;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.contact.dto.Result;
import com.contact.entity.Major;
import com.contact.service.MajorService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/major")
public class MajorController {

    @Autowired
    private MajorService majorService;

    /**
     * 查询所有专业
     */
    @GetMapping("/list")
    public Result<?> list() {
        List<Major> list = majorService.list(
                new LambdaQueryWrapper<Major>().orderByAsc(Major::getCreateTime)
        );
        return Result.success(list);
    }

    /**
     * 新增专业（管理员）
     */
    @PostMapping
    public Result<?> add(@RequestBody Major major) {
        if (major.getName() == null || major.getName().isEmpty()) {
            return Result.error("专业名称不能为空");
        }
        long count = majorService.count(
                new LambdaQueryWrapper<Major>().eq(Major::getName, major.getName())
        );
        if (count > 0) {
            return Result.error("专业名称已存在");
        }
        majorService.save(major);
        return Result.success("新增成功");
    }

    /**
     * 修改专业（管理员）
     */
    @PutMapping
    public Result<?> update(@RequestBody Major major) {
        if (major.getId() == null) {
            return Result.error("专业ID不能为空");
        }
        majorService.updateById(major);
        return Result.success("修改成功");
    }

    /**
     * 删除专业（管理员）
     */
    @DeleteMapping("/{id}")
    public Result<?> delete(@PathVariable Long id) {
        majorService.removeById(id);
        return Result.success("删除成功");
    }
}
