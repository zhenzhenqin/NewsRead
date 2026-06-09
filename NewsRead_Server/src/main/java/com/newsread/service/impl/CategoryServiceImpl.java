package com.newsread.service.impl;

import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.newsread.entity.Category;
import com.newsread.mapper.CategoryMapper;
import com.newsread.service.CategoryService;
import org.springframework.stereotype.Service;

@Service
public class CategoryServiceImpl extends ServiceImpl<CategoryMapper, Category> implements CategoryService {
}