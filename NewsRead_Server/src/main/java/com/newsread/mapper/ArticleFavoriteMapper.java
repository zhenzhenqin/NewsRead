package com.newsread.mapper;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.newsread.entity.ArticleFavorite;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;
import org.apache.ibatis.annotations.Select;

import java.util.List;
import java.util.Map;

@Mapper
public interface ArticleFavoriteMapper extends BaseMapper<ArticleFavorite> {

    /**
     * 获取用户所有收藏夹名称及各收藏夹数量
     */
    @Select("SELECT folder_name AS folderName, COUNT(*) AS count " +
            "FROM article_favorite WHERE user_id = #{userId} " +
            "GROUP BY folder_name ORDER BY count DESC")
    List<Map<String, Object>> selectFolderStats(@Param("userId") Long userId);

    /**
     * 收藏数量 Top N 文章（管理视角）
     */
    @Select("SELECT af.article_id AS articleId, a.title AS title, a.cover_image AS coverImage, " +
            "a.category_id AS categoryId, COUNT(*) AS favCount " +
            "FROM article_favorite af " +
            "LEFT JOIN article a ON af.article_id = a.id " +
            "GROUP BY af.article_id, a.title, a.cover_image, a.category_id " +
            "ORDER BY favCount DESC LIMIT #{limit}")
    List<Map<String, Object>> selectTopFavoritedArticles(@Param("limit") int limit);
}
