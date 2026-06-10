package com.newsread.entity;

import com.baomidou.mybatisplus.annotation.*;
import lombok.Data;
import java.time.LocalDateTime;

@Data
@TableName("spider_article")
public class SpiderArticle {

    @TableId(type = IdType.AUTO)
    private Long id;

    private String title;

    private String summary;

    private String coverImage;

    private String sourceUrl;

    private Long categoryId;

    private Integer status;

    private LocalDateTime fetchTime;

    @TableField(fill = FieldFill.INSERT)
    private LocalDateTime createTime;
}
