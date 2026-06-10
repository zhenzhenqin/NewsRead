package com.newsread.dto;

import lombok.Data;

@Data
public class SpiderArticleDTO {
    private String title;
    private String summary;
    private String coverImage;
    private String sourceUrl;
    private Long categoryId;
}
