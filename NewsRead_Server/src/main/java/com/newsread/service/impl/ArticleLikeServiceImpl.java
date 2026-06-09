package com.newsread.service.impl;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.newsread.entity.Article;
import com.newsread.entity.ArticleLike;
import com.newsread.mapper.ArticleLikeMapper;
import com.newsread.service.ArticleLikeService;
import com.newsread.service.ArticleService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.List;

@Service
public class ArticleLikeServiceImpl implements ArticleLikeService {

    @Autowired
    private ArticleLikeMapper articleLikeMapper;

    @Autowired
    private ArticleService articleService;

    @Override
    @Transactional
    public void likeArticle(Long articleId, Long userId) {
        LambdaQueryWrapper<ArticleLike> wrapper = new LambdaQueryWrapper<>();
        wrapper.eq(ArticleLike::getArticleId, articleId)
                .eq(ArticleLike::getUserId, userId);
        long count = articleLikeMapper.selectCount(wrapper);
        if (count == 0) {
            ArticleLike like = new ArticleLike();
            like.setArticleId(articleId);
            like.setUserId(userId);
            like.setCreateTime(LocalDateTime.now());
            articleLikeMapper.insert(like);

            Article article = articleService.getById(articleId);
            if (article != null) {
                article.setLikeCount(article.getLikeCount() + 1);
                articleService.updateById(article);
            }
        }
    }

    @Override
    @Transactional
    public void unlikeArticle(Long articleId, Long userId) {
        LambdaQueryWrapper<ArticleLike> wrapper = new LambdaQueryWrapper<>();
        wrapper.eq(ArticleLike::getArticleId, articleId)
                .eq(ArticleLike::getUserId, userId);
        articleLikeMapper.delete(wrapper);

        Article article = articleService.getById(articleId);
        if (article != null && article.getLikeCount() > 0) {
            article.setLikeCount(article.getLikeCount() - 1);
            articleService.updateById(article);
        }
    }

    @Override
    public boolean hasLikedArticle(Long articleId, Long userId) {
        LambdaQueryWrapper<ArticleLike> wrapper = new LambdaQueryWrapper<>();
        wrapper.eq(ArticleLike::getArticleId, articleId)
                .eq(ArticleLike::getUserId, userId);
        return articleLikeMapper.selectCount(wrapper) > 0;
    }

    @Override
    public List<ArticleLike> list() {
        return articleLikeMapper.selectList(null);
    }

    @Override
    public int count(Long articleId) {
        LambdaQueryWrapper<ArticleLike> wrapper = new LambdaQueryWrapper<>();
        wrapper.eq(ArticleLike::getArticleId, articleId);
        return articleLikeMapper.selectCount(wrapper).intValue();
    }
}