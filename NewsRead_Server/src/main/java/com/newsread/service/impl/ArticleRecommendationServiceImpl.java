package com.newsread.service.impl;

import com.newsread.entity.Article;
import com.newsread.mapper.ArticleMapper;
import com.newsread.service.ArticleRecommendationService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import java.util.List;

@Service
public class ArticleRecommendationServiceImpl implements ArticleRecommendationService {

    @Autowired
    private ArticleMapper articleMapper;

    @Override
    public List<Article> getRecommendations(Long userId, Integer limit) {
        return articleMapper.selectRecommendList(limit);
    }

    @Override
    public List<Article> getFeaturedArticles(Integer limit) {
        return articleMapper.selectFeaturedList(limit);
    }

    @Override
    public List<Article> getHotArticles(Integer limit) {
        return articleMapper.selectHotList(limit);
    }
}