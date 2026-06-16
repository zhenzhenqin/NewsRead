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

    /**
     * 全文搜索（MATCH...AGAINST + ngram）
     */
    List<Article> selectByFulltext(@Param("keyword") String keyword,
                                   @Param("offset") int offset,
                                   @Param("size") int size);

    /**
     * 全文搜索结果总数
     */
    int countByFulltext(@Param("keyword") String keyword);

    /**
     * 按作者ID列表查询文章（关注频道）
     */
    List<Article> selectByAuthorIds(@Param("authorIds") List<Long> authorIds,
                                    @Param("offset") int offset,
                                    @Param("size") int size);

    /**
     * 按作者ID列表统计文章总数
     */
    int countByAuthorIds(@Param("authorIds") List<Long> authorIds);
}