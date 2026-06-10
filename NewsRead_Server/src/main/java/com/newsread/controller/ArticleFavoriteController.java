package com.newsread.controller;

import com.newsread.common.Result;
import com.newsread.entity.ArticleFavorite;
import com.newsread.service.ArticleFavoriteService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api/favorite")
public class ArticleFavoriteController {

    @Autowired
    private ArticleFavoriteService favoriteService;

    /**
     * 添加收藏
     */
    @PostMapping("/add")
    public Result<Void> add(@RequestBody Map<String, Object> params) {
        Long userId = Long.valueOf(params.get("userId").toString());
        Long articleId = Long.valueOf(params.get("articleId").toString());
        String folderName = params.get("folderName") != null ? params.get("folderName").toString() : null;
        boolean ok = favoriteService.addFavorite(userId, articleId, folderName);
        return ok ? Result.success(null) : Result.error("已收藏");
    }

    /**
     * 取消收藏
     */
    @PostMapping("/remove")
    public Result<Void> remove(@RequestBody Map<String, Long> params) {
        Long userId = params.get("userId");
        Long articleId = params.get("articleId");
        favoriteService.removeFavorite(userId, articleId);
        return Result.success(null);
    }

    /**
     * 检查是否已收藏
     */
    @GetMapping("/check")
    public Result<Boolean> check(@RequestParam Long userId, @RequestParam Long articleId) {
        return Result.success(favoriteService.isFavorited(userId, articleId));
    }

    /**
     * 获取收藏列表
     */
    @GetMapping("/list")
    public Result<List<ArticleFavorite>> list(
            @RequestParam Long userId,
            @RequestParam(required = false) String folderName) {
        return Result.success(favoriteService.getFavorites(userId, folderName));
    }

    /**
     * 获取用户所有收藏夹名称及数量
     */
    @GetMapping("/folders")
    public Result<List<Map<String, Object>>> folders(@RequestParam Long userId) {
        return Result.success(favoriteService.getFolderStats(userId));
    }

    /**
     * 管理视角：收藏数量 Top10 文章
     */
    @GetMapping("/top")
    public Result<List<Map<String, Object>>> top(@RequestParam(defaultValue = "10") int limit) {
        return Result.success(favoriteService.getTopFavoritedArticles(limit));
    }
}
