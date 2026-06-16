package com.newsread.controller;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.newsread.common.Result;
import com.newsread.entity.Article;
import com.newsread.service.ArticleService;
import com.newsread.service.ArticleRecommendationService;
import com.newsread.service.SearchService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;
import java.time.LocalDateTime;
import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api/article")
public class ArticleController {

    @Autowired
    private ArticleService articleService;
    
    @Autowired
    private ArticleRecommendationService recommendationService;

    @Autowired
    private SearchService searchService;

    @GetMapping("/list")
    public Result<Page<Article>> list(
            @RequestParam(defaultValue = "1") Integer pageNum,
            @RequestParam(defaultValue = "10") Integer pageSize,
            @RequestParam(required = false) Long categoryId,
            @RequestParam(required = false) Integer isPublished) {
        Page<Article> page = new Page<>(pageNum, pageSize);
        LambdaQueryWrapper<Article> wrapper = new LambdaQueryWrapper<>();
        if (categoryId != null) {
            wrapper.eq(Article::getCategoryId, categoryId);
        }
        if (isPublished != null) {
            wrapper.eq(Article::getIsPublished, isPublished);
        }
        wrapper.orderByDesc(Article::getCreateTime);
        return Result.success(articleService.page(page, wrapper));
    }

    @GetMapping("/detail/{id}")
    public Result<Article> detail(@PathVariable Long id) {
        Article article = articleService.getById(id);
        if (article == null) {
            return Result.error("文章不存在");
        }
        articleService.incrementViewCount(id);
        return Result.success(article);
    }

    @GetMapping("/recommend")
    public Result<List<Article>> recommend(
            @RequestParam(required = false) Long userId,
            @RequestParam(defaultValue = "10") Integer limit) {
        List<Article> list = recommendationService.getRecommendations(userId, limit);
        return Result.success(list);
    }

    @GetMapping("/featured")
    public Result<List<Article>> featured(@RequestParam(defaultValue = "5") Integer limit) {
        List<Article> list = recommendationService.getFeaturedArticles(limit);
        return Result.success(list);
    }

    @GetMapping("/hot")
    public Result<List<Article>> hot(@RequestParam(defaultValue = "10") Integer limit) {
        List<Article> list = recommendationService.getHotArticles(limit);
        return Result.success(list);
    }

    /**
     * 全文搜索
     */
    @GetMapping("/search")
    public Result<Page<Article>> search(
            @RequestParam String keyword,
            @RequestParam(defaultValue = "1") Integer page,
            @RequestParam(defaultValue = "10") Integer size,
            @RequestAttribute(value = "userId", required = false) Long userId) {
        Page<Article> result = searchService.search(keyword, page, size);
        // 异步记录搜索历史，不阻塞响应
        searchService.recordSearchHistory(userId, keyword);
        return Result.success(result);
    }

    /**
     * 最近 7 天搜索热词 Top10
     */
    @GetMapping("/hot-keywords")
    public Result<List<Map<String, Object>>> hotKeywords() {
        return Result.success(searchService.getHotKeywords());
    }

    /**
     * 当前用户最近搜索历史（去重，最多10条）
     */
    @GetMapping("/my-search-history")
    public Result<List<String>> mySearchHistory(@RequestAttribute(value = "userId", required = false) Long userId) {
        return Result.success(searchService.getMySearchHistory(userId));
    }

    @PostMapping("/create")
    public Result<Void> create(@RequestBody Article article, @RequestAttribute("userId") Long userId) {
        article.setCreateTime(LocalDateTime.now());
        article.setUpdateTime(LocalDateTime.now());
        article.setViewCount(0);
        article.setLikeCount(0);
        article.setCommentCount(0);
        article.setAuthorId(userId);
        articleService.save(article);
        return Result.success();

    }

    @PutMapping("/update")
    public Result<Void> update(@RequestBody Article article) {
        article.setUpdateTime(LocalDateTime.now());
        articleService.updateById(article);
        return Result.success();
    }

    @DeleteMapping("/delete/{id}")
    public Result<Void> delete(@PathVariable Long id) {
        articleService.removeById(id);
        return Result.success();
    }

    @PostMapping("/like")
    public Result<Void> like(@RequestBody Map<String, Long> params) {
        Long id = params.get("id");
        articleService.incrementLikeCount(id);
        return Result.success();
    }

    /**
     * 关注频道文章流（分页，需登录）
     */
    @GetMapping("/following-feed")
    public Result<Page<Article>> followingFeed(
            @RequestAttribute("userId") Long userId,
            @RequestParam(defaultValue = "1") Integer pageNum,
            @RequestParam(defaultValue = "10") Integer pageSize) {
        return Result.success(articleService.getFollowingFeed(userId, pageNum, pageSize));
    }
}