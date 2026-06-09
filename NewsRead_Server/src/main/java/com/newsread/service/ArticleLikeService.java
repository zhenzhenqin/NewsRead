package com.newsread.service;

import com.newsread.entity.ArticleLike;

import java.util.List;

public interface ArticleLikeService {

    void likeArticle(Long articleId, Long userId);

    void unlikeArticle(Long articleId, Long userId);

    boolean hasLikedArticle(Long articleId, Long userId);

    List<ArticleLike> list();

    int count(Long articleId);
}