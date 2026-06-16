package com.newsread.service;

import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.baomidou.mybatisplus.extension.service.IService;
import com.newsread.entity.Article;

public interface ArticleService extends IService<Article> {

    void incrementViewCount(Long articleId);

    void incrementLikeCount(Long articleId);

    long countByCategory(Long categoryId);

    long countByAuthor(Long authorId);

    java.util.List<Article> getTopArticles(int limit);

    /**
     * 关注频道文章流（分页）
     */
    Page<Article> getFollowingFeed(Long userId, int pageNum, int pageSize);
}