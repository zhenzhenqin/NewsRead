package com.newsread.service;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.newsread.entity.Article;
import com.newsread.entity.SearchHistory;
import com.newsread.mapper.ArticleMapper;
import com.newsread.mapper.SearchHistoryMapper;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.scheduling.annotation.Async;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;
import java.util.List;
import java.util.Map;

@Service
public class SearchService {

    @Autowired
    private ArticleMapper articleMapper;

    @Autowired
    private SearchHistoryMapper searchHistoryMapper;

    /**
     * 全文搜索文章
     */
    public Page<Article> search(String keyword, int pageNum, int pageSize) {
        int offset = (pageNum - 1) * pageSize;
        List<Article> records = articleMapper.selectByFulltext(keyword, offset, pageSize);
        int total = articleMapper.countByFulltext(keyword);

        Page<Article> page = new Page<>(pageNum, pageSize);
        page.setRecords(records);
        page.setTotal(total);
        return page;
    }

    /**
     * 异步记录搜索历史（存在则更新次数和时间，不存在则插入）
     */
    @Async
    public void recordSearchHistory(Long userId, String keyword) {
        if (userId == null || keyword == null || keyword.trim().isEmpty()) {
            return;
        }
        try {
            LambdaQueryWrapper<SearchHistory> wrapper = new LambdaQueryWrapper<>();
            wrapper.eq(SearchHistory::getUserId, userId)
                   .eq(SearchHistory::getKeyword, keyword.trim());
            SearchHistory existing = searchHistoryMapper.selectOne(wrapper);

            if (existing != null) {
                existing.setSearchCount(existing.getSearchCount() + 1);
                existing.setLastSearchTime(LocalDateTime.now());
                searchHistoryMapper.updateById(existing);
            } else {
                SearchHistory history = new SearchHistory();
                history.setUserId(userId);
                history.setKeyword(keyword.trim());
                history.setSearchCount(1);
                history.setLastSearchTime(LocalDateTime.now());
                searchHistoryMapper.insert(history);
            }
        } catch (Exception e) {
            // 异步记录失败不影响主流程
        }
    }

    /**
     * 最近 7 天搜索热词 Top10
     */
    public List<Map<String, Object>> getHotKeywords() {
        return searchHistoryMapper.selectHotKeywords(7, 10);
    }

    /**
     * 用户最近搜索历史（去重，最多10条）
     */
    public List<String> getMySearchHistory(Long userId) {
        if (userId == null) {
            return List.of();
        }
        return searchHistoryMapper.selectByUserId(userId, 10);
    }
}
