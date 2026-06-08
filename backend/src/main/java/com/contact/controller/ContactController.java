package com.contact.controller;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.contact.dto.ContactQuery;
import com.contact.dto.Result;
import com.contact.entity.Contact;
import com.contact.service.ContactService;
import com.contact.mapper.ContactMapper;
import jakarta.servlet.http.HttpServletRequest;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/contact")
public class ContactController {

    @Autowired
    private ContactService contactService;

    @Autowired
    private ContactMapper contactMapper;

    /**
     * 获取当前用户通讯录信息
     */
    @GetMapping("/my")
    public Result<?> getMyContact(HttpServletRequest request) {
        Long userId = (Long) request.getAttribute("userId");
        Contact contact = contactService.getOne(
                new LambdaQueryWrapper<Contact>().eq(Contact::getUserId, userId)
        );
        return Result.success(contact);
    }

    /**
     * 保存/更新我的通讯录信息
     */
    @PostMapping("/my")
    public Result<?> saveMyContact(HttpServletRequest request, @RequestBody Contact contact) {
        Long userId = (Long) request.getAttribute("userId");
        contact.setUserId(userId);

        // 检查是否已存在
        Contact existing = contactService.getOne(
                new LambdaQueryWrapper<Contact>().eq(Contact::getUserId, userId)
        );

        if (existing != null) {
            contact.setId(existing.getId());
            contactService.updateById(contact);
            return Result.success("更新成功");
        } else {
            contactService.save(contact);
            return Result.success("保存成功");
        }
    }

    /**
     * 分页查询通讯录列表
     */
    @PostMapping("/list")
    public Result<?> list(@RequestBody ContactQuery query) {
        Page<Contact> page = new Page<>(query.getPageNum(), query.getPageSize());

        List<Contact> list = contactMapper.selectContactList(
                query.getRealName(),
                query.getMajorId(),
                query.getClassName(),
                query.getEnrollYear(),
                query.getGraduateYear(),
                query.getCity(),
                query.getEmployer()
        );

        // 手动分页
        int total = list.size();
        int fromIndex = (query.getPageNum() - 1) * query.getPageSize();
        int toIndex = Math.min(fromIndex + query.getPageSize(), total);
        List<Contact> pageList = (fromIndex < total) ? list.subList(fromIndex, toIndex) : List.of();

        page.setRecords(pageList);
        page.setTotal(total);

        return Result.success(page);
    }

    /**
     * 根据ID获取通讯录详情
     */
    @GetMapping("/{id}")
    public Result<?> getById(@PathVariable Long id) {
        Contact contact = contactService.getById(id);
        if (contact == null) {
            return Result.error("通讯录信息不存在");
        }
        return Result.success(contact);
    }
}
