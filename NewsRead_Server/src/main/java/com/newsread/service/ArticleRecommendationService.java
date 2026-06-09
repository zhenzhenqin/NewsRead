package com.newsread.service;

import com.newsread.entity.Article;
import java.util.List;

public interface ArticleRecommendationService {
    
    List<Article> getRecommendations(Long userId, Integer limit);
    
    List<Article> getFeaturedArticles(Integer limit);
    
    List<Article> getHotArticles(Integer limit);
}