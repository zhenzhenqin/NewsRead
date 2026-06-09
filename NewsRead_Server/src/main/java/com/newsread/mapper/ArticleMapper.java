package com.newsread.mapper;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.newsread.entity.Article;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;
import java.util.List;

@Mapper
public interface ArticleMapper extends BaseMapper<Article> {
    
    List<Article> selectRecommendList(@Param("limit") Integer limit);

    List<Article> selectFeaturedList(@Param("limit") Integer limit);

    List<Article> selectHotList(@Param("limit") Integer limit);

    List<Article> selectByCategoryId(@Param("categoryId") Long categoryId, @Param("limit") Integer limit);
}