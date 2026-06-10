package com.newsread.service;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.newsread.dto.SpiderArticleDTO;
import com.newsread.entity.Article;
import com.newsread.entity.SpiderArticle;
import com.newsread.mapper.SpiderArticleMapper;
import org.jsoup.Jsoup;
import org.jsoup.nodes.Document;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;
import java.util.Set;
import java.util.stream.Collectors;

@Service
public class SpiderService {

    @Autowired
    private ArticleService articleService;

    @Autowired
    private SpiderArticleMapper spiderArticleMapper;

    private final ObjectMapper objectMapper = new ObjectMapper();

    /**
     * 从百度热搜抓取（PC版API，含封面图和摘要）并持久化，新数据插入到旧数据之前（按标题去重）
     */
    public List<SpiderArticle> fetchHotNews() {
        // 获取已有数据的标题集合，用于去重
        List<SpiderArticle> existing = spiderArticleMapper.selectList(
                new LambdaQueryWrapper<SpiderArticle>()
                        .eq(SpiderArticle::getStatus, 1)
                        .select(SpiderArticle::getTitle)
        );
        Set<String> existingTitles = existing.stream()
                .map(SpiderArticle::getTitle)
                .collect(Collectors.toSet());

        List<SpiderArticle> newItems = new ArrayList<>();
        LocalDateTime now = LocalDateTime.now();

        try {
            Document doc = Jsoup.connect("https://top.baidu.com/api/board?platform=pc&tab=realtime")
                    .userAgent("Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36")
                    .ignoreContentType(true)
                    .timeout(10000)
                    .get();

            String json = doc.body().text();
            JsonNode root = objectMapper.readTree(json);
            JsonNode cards = root.path("data").path("cards");

            if (cards.isArray() && cards.size() > 0) {
                JsonNode items = cards.get(0).path("content");
                if (items.isArray()) {
                    for (JsonNode item : items) {
                        String word = item.path("word").asText("");
                        if (word.isEmpty() || existingTitles.contains(word)) {
                            continue;
                        }
                        SpiderArticle sa = new SpiderArticle();
                        sa.setTitle(word);
                        String desc = item.path("desc").asText("");
                        sa.setSummary(desc.isEmpty() ? word : desc);
                        sa.setCoverImage(item.path("img").asText(""));
                        sa.setSourceUrl(item.path("rawUrl").asText(""));
                        sa.setStatus(1);
                        sa.setFetchTime(now);
                        sa.setCreateTime(now);
                        spiderArticleMapper.insert(sa);
                        newItems.add(sa);
                    }
                }
            }
        } catch (Exception e) {
            throw new RuntimeException("爬取失败: " + e.getMessage());
        }

        // 返回全部数据（新 + 旧），按 fetchTime 倒序
        return getSavedArticles();
    }

    /**
     * 从数据库读取已保存的爬虫文章
     */
    public List<SpiderArticle> getSavedArticles() {
        return spiderArticleMapper.selectList(
                new LambdaQueryWrapper<SpiderArticle>()
                        .eq(SpiderArticle::getStatus, 1)
                        .orderByDesc(SpiderArticle::getFetchTime)
        );
    }

    /**
     * 删除单条爬虫文章（软删除）
     */
    public void deleteArticle(Long id) {
        SpiderArticle sa = spiderArticleMapper.selectById(id);
        if (sa != null) {
            sa.setStatus(0);
            spiderArticleMapper.updateById(sa);
        }
    }

    /**
     * 将爬虫文章发布到正式文章表
     */
    public void publishArticle(SpiderArticleDTO dto, Long adminUserId) {
        Article article = new Article();
        article.setTitle(dto.getTitle());
        article.setContent(dto.getSummary());
        article.setSummary(dto.getSummary());
        article.setCoverImage(dto.getCoverImage());
        article.setCategoryId(dto.getCategoryId());
        article.setAuthorId(adminUserId);
        article.setIsPublished(1);
        article.setStatus(1);
        article.setIsFeatured(0);
        article.setViewCount(0);
        article.setLikeCount(0);
        article.setCommentCount(0);
        article.setPublishTime(LocalDateTime.now());
        article.setCreateTime(LocalDateTime.now());
        article.setUpdateTime(LocalDateTime.now());
        articleService.save(article);
    }
}
