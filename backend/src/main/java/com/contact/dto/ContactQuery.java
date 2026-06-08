package com.contact.dto;

import lombok.Data;

@Data
public class ContactQuery {
    private String realName;
    private Long majorId;
    private String className;
    private Integer enrollYear;
    private Integer graduateYear;
    private String city;
    private String employer;
    private Integer pageNum = 1;
    private Integer pageSize = 10;
}
