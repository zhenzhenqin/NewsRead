package com.newsread.mapper;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.newsread.entity.SearchHistory;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;
import org.apache.ibatis.annotations.Select;

import java.util.List;
import java.util.Map;

@Mapper
public interface SearchHistoryMapper extends BaseMapper<SearchHistory> {

    /**
     * 最近 N 天搜索频次 Top N 关键词
     */
    @Select("SELECT keyword, SUM(search_count) AS totalCount " +
            "FROM search_history " +
            "WHERE last_search_time >= DATE_SUB(NOW(), INTERVAL #{days} DAY) " +
            "GROUP BY keyword " +
            "ORDER BY totalCount DESC " +
            "LIMIT #{limit}")
    List<Map<String, Object>> selectHotKeywords(@Param("days") int days, @Param("limit") int limit);

    /**
     * 查询用户最近的搜索关键词（去重，按 last_search_time 降序）
     */
    @Select("SELECT keyword FROM search_history " +
            "WHERE user_id = #{userId} " +
            "GROUP BY keyword " +
            "ORDER BY MAX(last_search_time) DESC " +
            "LIMIT #{limit}")
    List<String> selectByUserId(@Param("userId") Long userId, @Param("limit") int limit);
}
