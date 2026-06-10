package com.newsread.controller;

import com.newsread.common.Result;
import com.newsread.dto.SpiderArticleDTO;
import com.newsread.entity.SpiderArticle;
import com.newsread.service.SpiderService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/admin/spider")
public class SpiderController {

    @Autowired
    private SpiderService spiderService;

    /**
     * 从百度热搜抓取并持久化，同时异步抓取封面图
     */
    @GetMapping("/fetch")
    public Result<List<SpiderArticle>> fetchHotNews() {
        return Result.success(spiderService.fetchHotNews());
    }

    /**
     * 从数据库读取已保存的爬虫文章
     */
    @GetMapping("/list")
    public Result<List<SpiderArticle>> list() {
        return Result.success(spiderService.getSavedArticles());
    }

    /**
     * 删除单条爬虫文章
     */
    @DeleteMapping("/{id}")
    public Result<Void> delete(@PathVariable Long id) {
        spiderService.deleteArticle(id);
        return Result.success(null);
    }

    /**
     * 发布到正式文章表
     */
    @PostMapping("/publish")
    public Result<Void> publishArticle(@RequestBody SpiderArticleDTO dto,
                                        @RequestAttribute("userId") Long userId) {
        spiderService.publishArticle(dto, userId);
        return Result.success(null);
    }
}
