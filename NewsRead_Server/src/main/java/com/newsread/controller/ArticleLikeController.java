package com.newsread.controller;

import com.newsread.common.Result;
import com.newsread.service.ArticleLikeService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

import java.util.HashMap;
import java.util.Map;

@RestController
@RequestMapping("/api/article")
public class ArticleLikeController {

    @Autowired
    private ArticleLikeService articleLikeService;

    @PostMapping("/like/{id}")
    public Result<Void> like(@PathVariable Long id,
                         @RequestAttribute("userId") Long userId) {
        articleLikeService.likeArticle(id, userId);
        return Result.success();
    }

    @DeleteMapping("/unlike/{id}")
    public Result<Void> unlike(@PathVariable Long id,
                          @RequestAttribute("userId") Long userId) {
        articleLikeService.unlikeArticle(id, userId);
        return Result.success();
    }

    @GetMapping("/hasLiked/{id}")
    public Result<Map<String, Boolean>> hasLiked(@PathVariable Long id,
                                           @RequestAttribute("userId") Long userId) {
        Map<String, Boolean> data = new HashMap<>();
        data.put("liked", articleLikeService.hasLikedArticle(id, userId));
        return Result.success(data);
    }
}