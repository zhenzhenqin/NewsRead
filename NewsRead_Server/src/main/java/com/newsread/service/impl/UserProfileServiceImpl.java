package com.newsread.service.impl;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.newsread.entity.*;
import com.newsread.mapper.*;
import com.newsread.service.UserProfileService;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;

@Service
public class UserProfileServiceImpl implements UserProfileService {

    private static final Logger logger = LoggerFactory.getLogger(UserProfileServiceImpl.class);

    @Autowired
    private ArticleLikeMapper articleLikeMapper;

    @Autowired
    private ArticleMapper articleMapper;

    @Autowired
    private CommentMapper commentMapper;

    @Autowired
    private BrowseHistoryMapper browseHistoryMapper;

    @Override
    public List<Article> getLikedArticles(Long userId, Integer pageNum, Integer pageSize) {
        Page<ArticleLike> page = new Page<>(pageNum, pageSize);
        LambdaQueryWrapper<ArticleLike> wrapper = new LambdaQueryWrapper<>();
        wrapper.eq(ArticleLike::getUserId, userId);
        wrapper.orderByDesc(ArticleLike::getCreateTime);
        Page<ArticleLike> likePage = articleLikeMapper.selectPage(page, wrapper);
        
        List<Article> articles = new ArrayList<>();
        for (ArticleLike like : likePage.getRecords()) {
            Article article = articleMapper.selectById(like.getArticleId());
            if (article != null) {
                articles.add(article);
            }
        }
        return articles;
    }

    @Override
    public List<Comment> getUserComments(Long userId, Integer pageNum, Integer pageSize) {
        Page<Comment> page = new Page<>(pageNum, pageSize);
        LambdaQueryWrapper<Comment> wrapper = new LambdaQueryWrapper<>();
        wrapper.eq(Comment::getUserId, userId);
        wrapper.orderByDesc(Comment::getCreateTime);
        return commentMapper.selectPage(page, wrapper).getRecords();
    }

    @Override
    public List<Article> getBrowseHistory(Long userId, Integer pageNum, Integer pageSize) {
        Page<BrowseHistory> page = new Page<>(pageNum, pageSize);
        LambdaQueryWrapper<BrowseHistory> wrapper = new LambdaQueryWrapper<>();
        wrapper.eq(BrowseHistory::getUserId, userId);
        wrapper.orderByDesc(BrowseHistory::getCreateTime);
        Page<BrowseHistory> historyPage = browseHistoryMapper.selectPage(page, wrapper);
        
        logger.info("getBrowseHistory: userId={}, total records={}", userId, historyPage.getTotal());
        
        List<Article> articles = new ArrayList<>();
        for (BrowseHistory history : historyPage.getRecords()) {
            Article article = articleMapper.selectById(history.getArticleId());
            if (article != null) {
                articles.add(article);
            }
        }
        return articles;
    }

    @Override
    public void addBrowseHistory(Long userId, Long articleId) {
        logger.info("addBrowseHistory called: userId={}, articleId={}", userId, articleId);
        
        LambdaQueryWrapper<BrowseHistory> wrapper = new LambdaQueryWrapper<>();
        wrapper.eq(BrowseHistory::getUserId, userId);
        wrapper.eq(BrowseHistory::getArticleId, articleId);
        BrowseHistory existing = browseHistoryMapper.selectOne(wrapper);
        
        logger.info("addBrowseHistory: existing record = {}", existing);
        
        if (existing != null) {
            logger.info("Updating existing browse history, id={}", existing.getId());
            existing.setCreateTime(LocalDateTime.now());
            browseHistoryMapper.updateById(existing);
        } else {
            logger.info("Creating new browse history");
            BrowseHistory history = new BrowseHistory();
            history.setUserId(userId);
            history.setArticleId(articleId);
            history.setCreateTime(LocalDateTime.now());
            browseHistoryMapper.insert(history);
        }
    }

    @Override
    public void deleteBrowseHistory(Long userId, Long articleId) {
        LambdaQueryWrapper<BrowseHistory> wrapper = new LambdaQueryWrapper<>();
        wrapper.eq(BrowseHistory::getUserId, userId);
        wrapper.eq(BrowseHistory::getArticleId, articleId);
        browseHistoryMapper.delete(wrapper);
    }

    @Override
    public void clearBrowseHistory(Long userId) {
        LambdaQueryWrapper<BrowseHistory> wrapper = new LambdaQueryWrapper<>();
        wrapper.eq(BrowseHistory::getUserId, userId);
        browseHistoryMapper.delete(wrapper);
    }
}