package com.newsread.service.impl;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.newsread.entity.Article;
import com.newsread.mapper.ArticleMapper;
import com.newsread.service.ArticleService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

@Service
public class ArticleServiceImpl extends ServiceImpl<ArticleMapper, Article> implements ArticleService {

    @Override
    @Transactional
    public void incrementViewCount(Long articleId) {
        Article article = this.getById(articleId);
        if (article != null) {
            article.setViewCount(article.getViewCount() + 1);
            this.updateById(article);
        }
    }

    @Override
    @Transactional
    public void incrementLikeCount(Long articleId) {
        Article article = this.getById(articleId);
        if (article != null) {
            article.setLikeCount(article.getLikeCount() + 1);
            this.updateById(article);
        }
    }

    @Override
    public long countByCategory(Long categoryId) {
        LambdaQueryWrapper<Article> wrapper = new LambdaQueryWrapper<>();
        if (categoryId != null) {
            wrapper.eq(Article::getCategoryId, categoryId);
        }
        return this.count(wrapper);
    }

    @Override
    public long countByAuthor(Long authorId) {
        LambdaQueryWrapper<Article> wrapper = new LambdaQueryWrapper<>();
        if (authorId != null) {
            wrapper.eq(Article::getAuthorId, authorId);
        }
        return this.count(wrapper);
    }

    @Override
    public List<Article> getTopArticles(int limit) {
        LambdaQueryWrapper<Article> wrapper = new LambdaQueryWrapper<>();
        wrapper.orderByDesc(Article::getViewCount);
        wrapper.last("LIMIT " + limit);
        return this.list(wrapper);
    }
}