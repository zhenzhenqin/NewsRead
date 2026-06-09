package com.newsread.controller;

import com.newsread.common.Result;
import com.newsread.entity.Category;
import com.newsread.entity.Article;
import com.newsread.service.ArticleService;
import com.newsread.service.CategoryService;
import com.newsread.service.CommentService;
import com.newsread.service.UserService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

import java.util.*;

@RestController
@RequestMapping("/api/admin")
public class StatisticsController {

    @Autowired
    private ArticleService articleService;

    @Autowired
    private CategoryService categoryService;

    @Autowired
    private CommentService commentService;

    @Autowired
    private UserService userService;

    @GetMapping("/statistics")
    public Result<Map<String, Object>> statistics() {
        Map<String, Object> data = new HashMap<>();

        // 文章统计
        long totalArticles = articleService.count();
        data.put("totalArticles", totalArticles);

        // 计算总阅读量（所有文章的viewCount之和）
        List<Article> articles = articleService.list();
        long totalViews = articles.stream().mapToLong(a -> a.getViewCount() != null ? a.getViewCount() : 0).sum();
        data.put("totalViews", totalViews);

        // 计算总点赞数
        long totalLikes = articles.stream().mapToLong(a -> a.getLikeCount() != null ? a.getLikeCount() : 0).sum();
        data.put("totalLikes", totalLikes);

        // 评论总数
        int totalComments = commentService.countByArticle(null);
        data.put("totalComments", totalComments);

        return Result.success(data);
    }

    @GetMapping("/categoryStats")
    public Result<List<Map<String, Object>>> categoryStats() {
        List<Category> categories = categoryService.list();
        List<Map<String, Object>> result = new ArrayList<>();

        for (Category category : categories) {
            Map<String, Object> item = new HashMap<>();
            item.put("name", category.getName());

            // 统计每个分类的文章数
            long count = articleService.countByCategory(category.getId());
            item.put("value", count)    ;
            result.add(item);
        }

        return Result.success(result);
    }

    @GetMapping("/topArticles")
    public Result<List<Article>> topArticles(@RequestParam(defaultValue = "10") Integer limit) {
        List<Article> articles = articleService.getTopArticles(limit);
        return Result.success(articles);
    }
}