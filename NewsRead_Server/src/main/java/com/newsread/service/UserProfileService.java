package com.newsread.service;

import com.newsread.entity.Article;
import com.newsread.entity.Comment;
import com.newsread.entity.BrowseHistory;

import java.util.List;

public interface UserProfileService {

    List<Article> getLikedArticles(Long userId, Integer pageNum, Integer pageSize);

    List<Comment> getUserComments(Long userId, Integer pageNum, Integer pageSize);

    List<Article> getBrowseHistory(Long userId, Integer pageNum, Integer pageSize);

    void addBrowseHistory(Long userId, Long articleId);

    void deleteBrowseHistory(Long userId, Long articleId);

    void clearBrowseHistory(Long userId);
}