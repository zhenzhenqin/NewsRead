package com.newsread.controller;

import com.newsread.common.Result;
import com.newsread.entity.Article;
import com.newsread.entity.Comment;
import com.newsread.service.UserProfileService;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api/user")
public class UserProfileController {

    private static final Logger logger = LoggerFactory.getLogger(UserProfileController.class);

    @Autowired
    private UserProfileService userProfileService;

    @GetMapping("/likes")
    public Result<Map<String, Object>> getLikedArticles(
            @RequestAttribute("userId") Long userId,
            @RequestParam(defaultValue = "1") Integer pageNum,
            @RequestParam(defaultValue = "10") Integer pageSize) {
        List<Article> articles = userProfileService.getLikedArticles(userId, pageNum, pageSize);
        Map<String, Object> data = new HashMap<>();
        data.put("records", articles);
        data.put("total", articles.size());
        return Result.success(data);
    }

    @GetMapping("/comments")
    public Result<Map<String, Object>> getUserComments(
            @RequestAttribute("userId") Long userId,
            @RequestParam(defaultValue = "1") Integer pageNum,
            @RequestParam(defaultValue = "10") Integer pageSize) {
        List<Comment> comments = userProfileService.getUserComments(userId, pageNum, pageSize);
        Map<String, Object> data = new HashMap<>();
        data.put("records", comments);
        data.put("total", comments.size());
        return Result.success(data);
    }

    @GetMapping("/history")
    public Result<Map<String, Object>> getBrowseHistory(
            @RequestAttribute("userId") Long userId,
            @RequestParam(defaultValue = "1") Integer pageNum,
            @RequestParam(defaultValue = "10") Integer pageSize) {
        List<Article> articles = userProfileService.getBrowseHistory(userId, pageNum, pageSize);
        Map<String, Object> data = new HashMap<>();
        data.put("records", articles);
        data.put("total", articles.size());
        return Result.success(data);
    }

    @PostMapping("/history/add")
    public Result<Void> addBrowseHistory(
            @RequestAttribute("userId") Long userId,
            @RequestBody Map<String, Long> request) {
        logger.info("addBrowseHistory request: userId={}, request={}", userId, request);
        Long articleId = request.get("articleId");
        logger.info("addBrowseHistory: userId={}, articleId={}, articleId type={}", userId, articleId, articleId != null ? articleId.getClass() : "null");
        if (articleId == null) {
            logger.warn("addBrowseHistory: articleId is null");
            return Result.error("文章ID不能为空");
        }
        try {
            userProfileService.addBrowseHistory(userId, articleId);
            logger.info("addBrowseHistory: success");
            return Result.success(null);
        } catch (Exception e) {
            logger.error("addBrowseHistory error: ", e);
            return Result.error("添加浏览记录失败: " + e.getMessage());
        }
    }
}