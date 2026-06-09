package com.newsread.mapper;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.newsread.entity.BrowseHistory;
import org.apache.ibatis.annotations.Mapper;

@Mapper
public interface BrowseHistoryMapper extends BaseMapper<BrowseHistory> {
}