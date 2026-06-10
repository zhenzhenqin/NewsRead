package com.newsread.service;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.newsread.entity.ArticleFavorite;
import com.newsread.mapper.ArticleFavoriteMapper;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;
import java.util.List;
import java.util.Map;

@Service
public class ArticleFavoriteService extends ServiceImpl<ArticleFavoriteMapper, ArticleFavorite> {

    /**
     * 添加收藏
     */
    public boolean addFavorite(Long userId, Long articleId, String folderName) {
        // 检查是否已收藏
        LambdaQueryWrapper<ArticleFavorite> wrapper = new LambdaQueryWrapper<>();
        wrapper.eq(ArticleFavorite::getUserId, userId)
               .eq(ArticleFavorite::getArticleId, articleId);
        if (this.count(wrapper) > 0) {
            return false; // 已收藏
        }
        ArticleFavorite fav = new ArticleFavorite();
        fav.setUserId(userId);
        fav.setArticleId(articleId);
        fav.setFolderName(folderName != null && !folderName.isEmpty() ? folderName : "默认收藏夹");
        fav.setCreateTime(LocalDateTime.now());
        return this.save(fav);
    }

    /**
     * 取消收藏
     */
    public boolean removeFavorite(Long userId, Long articleId) {
        LambdaQueryWrapper<ArticleFavorite> wrapper = new LambdaQueryWrapper<>();
        wrapper.eq(ArticleFavorite::getUserId, userId)
               .eq(ArticleFavorite::getArticleId, articleId);
        return this.remove(wrapper);
    }

    /**
     * 检查是否已收藏
     */
    public boolean isFavorited(Long userId, Long articleId) {
        LambdaQueryWrapper<ArticleFavorite> wrapper = new LambdaQueryWrapper<>();
        wrapper.eq(ArticleFavorite::getUserId, userId)
               .eq(ArticleFavorite::getArticleId, articleId);
        return this.count(wrapper) > 0;
    }

    /**
     * 获取用户某收藏夹下的收藏列表
     */
    public List<ArticleFavorite> getFavorites(Long userId, String folderName) {
        LambdaQueryWrapper<ArticleFavorite> wrapper = new LambdaQueryWrapper<>();
        wrapper.eq(ArticleFavorite::getUserId, userId);
        if (folderName != null && !folderName.isEmpty()) {
            wrapper.eq(ArticleFavorite::getFolderName, folderName);
        }
        wrapper.orderByDesc(ArticleFavorite::getCreateTime);
        return this.list(wrapper);
    }

    /**
     * 获取用户所有收藏夹名称及数量
     */
    public List<Map<String, Object>> getFolderStats(Long userId) {
        return baseMapper.selectFolderStats(userId);
    }

    /**
     * 收藏数量 Top N 文章（管理视角）
     */
    public List<Map<String, Object>> getTopFavoritedArticles(int limit) {
        return baseMapper.selectTopFavoritedArticles(limit);
    }
}
