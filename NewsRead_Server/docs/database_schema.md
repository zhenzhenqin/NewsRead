# NewsRead 数据库表结构文档

## 数据库信息
- 数据库名: `newsread`
- 字符集: `utf8mb4`
- 排序规则: `utf8mb4_unicode_ci`
- 存储引擎: `InnoDB`

---

## 1. user_info - 用户表

| 字段名 | 类型 | 约束 | 说明 |
|--------|------|------|------|
| id | BIGINT | PK, AUTO_INCREMENT | 用户ID |
| username | VARCHAR(50) | NOT NULL, UNIQUE | 用户名 |
| password | VARCHAR(255) | NOT NULL | 密码(BCrypt加密) |
| nickname | VARCHAR(50) | - | 昵称 |
| avatar | VARCHAR(500) | - | 头像URL |
| email | VARCHAR(100) | - | 邮箱 |
| phone | VARCHAR(20) | - | 手机号 |
| status | TINYINT | DEFAULT 1 | 状态: 0-禁用, 1-正常 |
| role | TINYINT | DEFAULT 1 | 角色: 1-普通用户, 2-管理员 |
| create_time | DATETIME | DEFAULT CURRENT_TIMESTAMP | 创建时间 |
| update_time | DATETIME | ON UPDATE CURRENT_TIMESTAMP | 更新时间 |

**索引:**
- PRIMARY KEY (id)
- UNIQUE KEY uk_username (username)

---

## 2. category - 分类表

| 字段名 | 类型 | 约束 | 说明 |
|--------|------|------|------|
| id | BIGINT | PK, AUTO_INCREMENT | 分类ID |
| name | VARCHAR(50) | NOT NULL | 分类名称 |
| icon | VARCHAR(500) | - | 分类图标 |
| sort | INT | DEFAULT 0 | 排序值 |
| status | TINYINT | DEFAULT 1 | 状态: 0-禁用, 1-正常 |
| create_time | DATETIME | DEFAULT CURRENT_TIMESTAMP | 创建时间 |
| update_time | DATETIME | ON UPDATE CURRENT_TIMESTAMP | 更新时间 |

**索引:**
- PRIMARY KEY (id)

---

## 3. article - 文章表

| 字段名 | 类型 | 约束 | 说明 |
|--------|------|------|------|
| id | BIGINT | PK, AUTO_INCREMENT | 文章ID |
| title | VARCHAR(200) | NOT NULL | 文章标题 |
| content | TEXT | NOT NULL | 文章内容 |
| summary | VARCHAR(500) | - | 文章摘要 |
| cover_image | VARCHAR(500) | - | 封面图 |
| category_id | BIGINT | FK -> category.id | 分类ID |
| author_id | BIGINT | FK -> user_info.id, NOT NULL | 作者ID |
| view_count | INT | DEFAULT 0 | 阅读量 |
| like_count | INT | DEFAULT 0 | 点赞数 |
| comment_count | INT | DEFAULT 0 | 评论数 |
| is_featured | TINYINT | DEFAULT 0 | 是否推荐: 0-否, 1-是 |
| is_published | TINYINT | DEFAULT 1 | 是否发布: 0-草稿, 1-已发布 |
| status | TINYINT | DEFAULT 1 | 状态: 0-下架, 1-正常 |
| publish_time | DATETIME | - | 发布时间 |
| create_time | DATETIME | DEFAULT CURRENT_TIMESTAMP | 创建时间 |
| update_time | DATETIME | ON UPDATE CURRENT_TIMESTAMP | 更新时间 |

**索引:**
- PRIMARY KEY (id)
- KEY idx_category_id (category_id)
- KEY idx_author_id (author_id)
- KEY idx_publish_time (publish_time)
- KEY idx_is_featured (is_featured)
- FULLTEXT INDEX ft_title_summary (title, summary) - ngram解析器

---

## 4. comment - 评论表

| 字段名 | 类型 | 约束 | 说明 |
|--------|------|------|------|
| id | BIGINT | PK, AUTO_INCREMENT | 评论ID |
| article_id | BIGINT | FK -> article.id, NOT NULL | 文章ID |
| user_id | BIGINT | FK -> user_info.id, NOT NULL | 用户ID |
| parent_id | BIGINT | FK -> comment.id | 父评论ID(支持层级评论) |
| content | TEXT | NOT NULL | 评论内容 |
| like_count | INT | DEFAULT 0 | 点赞数 |
| status | TINYINT | DEFAULT 1 | 状态: 0-隐藏, 1-显示 |
| create_time | DATETIME | DEFAULT CURRENT_TIMESTAMP | 创建时间 |
| update_time | DATETIME | ON UPDATE CURRENT_TIMESTAMP | 更新时间 |

**索引:**
- PRIMARY KEY (id)
- KEY idx_article_id (article_id)
- KEY idx_user_id (user_id)
- KEY idx_parent_id (parent_id)

---

## 5. browse_history - 浏览历史表

| 字段名 | 类型 | 约束 | 说明 |
|--------|------|------|------|
| id | BIGINT | PK, AUTO_INCREMENT | ID |
| user_id | BIGINT | FK -> user_info.id, NOT NULL | 用户ID |
| article_id | BIGINT | FK -> article.id, NOT NULL | 文章ID |
| create_time | DATETIME | DEFAULT CURRENT_TIMESTAMP | 浏览时间 |

**索引:**
- PRIMARY KEY (id)
- KEY idx_user_id (user_id)
- KEY idx_article_id (article_id)
- KEY idx_user_article (user_id, article_id)

---

## 6. article_like - 文章点赞表

| 字段名 | 类型 | 约束 | 说明 |
|--------|------|------|------|
| id | BIGINT | PK, AUTO_INCREMENT | ID |
| user_id | BIGINT | FK -> user_info.id, NOT NULL | 用户ID |
| article_id | BIGINT | FK -> article.id, NOT NULL | 文章ID |
| create_time | DATETIME | DEFAULT CURRENT_TIMESTAMP | 点赞时间 |

**索引:**
- PRIMARY KEY (id)
- UNIQUE KEY uk_user_article (user_id, article_id)
- KEY idx_article_id (article_id)

---

## 7. comment_like - 评论点赞表

| 字段名 | 类型 | 约束 | 说明 |
|--------|------|------|------|
| id | BIGINT | PK, AUTO_INCREMENT | ID |
| user_id | BIGINT | FK -> user_info.id, NOT NULL | 用户ID |
| comment_id | BIGINT | FK -> comment.id, NOT NULL | 评论ID |
| create_time | DATETIME | DEFAULT CURRENT_TIMESTAMP | 点赞时间 |

**索引:**
- PRIMARY KEY (id)
- UNIQUE KEY uk_user_comment (user_id, comment_id)
- KEY idx_comment_id (comment_id)

---

## 8. article_favorite - 文章收藏表

| 字段名 | 类型 | 约束 | 说明 |
|--------|------|------|------|
| id | BIGINT | PK, AUTO_INCREMENT | ID |
| user_id | BIGINT | FK -> user_info.id, NOT NULL | 用户ID |
| article_id | BIGINT | FK -> article.id, NOT NULL | 文章ID |
| folder_name | VARCHAR(50) | DEFAULT '默认收藏夹' | 收藏夹名称 |
| create_time | DATETIME | DEFAULT CURRENT_TIMESTAMP | 收藏时间 |

**索引:**
- PRIMARY KEY (id)
- UNIQUE KEY uk_user_article (user_id, article_id)
- KEY idx_user_id (user_id)
- KEY idx_article_id (article_id)

---

## 9. spider_article - 爬虫文章暂存表

| 字段名 | 类型 | 约束 | 说明 |
|--------|------|------|------|
| id | BIGINT | PK, AUTO_INCREMENT | ID |
| title | VARCHAR(200) | NOT NULL | 新闻标题 |
| summary | VARCHAR(500) | - | 摘要 |
| cover_image | VARCHAR(500) | - | 封面图URL |
| source_url | VARCHAR(500) | - | 原始链接 |
| category_id | BIGINT | FK -> category.id | 分类ID |
| status | TINYINT | DEFAULT 1 | 状态: 1-正常, 0-已删除 |
| fetch_time | DATETIME | - | 抓取时间 |
| create_time | DATETIME | DEFAULT CURRENT_TIMESTAMP | 创建时间 |

**索引:**
- PRIMARY KEY (id)
- KEY idx_status (status)

---

## 10. search_history - 搜索历史表

| 字段名 | 类型 | 约束 | 说明 |
|--------|------|------|------|
| id | BIGINT | PK, AUTO_INCREMENT | ID |
| user_id | BIGINT | FK -> user_info.id, NOT NULL | 用户ID |
| keyword | VARCHAR(100) | NOT NULL | 搜索关键词 |
| search_count | INT | DEFAULT 1 | 搜索次数 |
| last_search_time | DATETIME | DEFAULT CURRENT_TIMESTAMP | 最近搜索时间 |

**索引:**
- PRIMARY KEY (id)
- UNIQUE KEY uk_user_keyword (user_id, keyword)
- KEY idx_user_id (user_id)
- KEY idx_last_search (last_search_time)

---

## 11. user_follow - 用户关注表

| 字段名 | 类型 | 约束 | 说明 |
|--------|------|------|------|
| id | BIGINT | PK, AUTO_INCREMENT | ID |
| follower_id | BIGINT | FK -> user_info.id, NOT NULL | 关注者ID |
| followed_id | BIGINT | FK -> user_info.id, NOT NULL | 被关注者ID |
| create_time | DATETIME | DEFAULT CURRENT_TIMESTAMP | 关注时间 |

**索引:**
- PRIMARY KEY (id)
- UNIQUE KEY uk_follower_followed (follower_id, followed_id)
- KEY idx_followed_id (followed_id)

---

## 表关系图 (UML参考)

```
┌─────────────────────────────────────────────────────────────────────────────────────┐
│                                   NewsRead 数据库ER图                                 │
└─────────────────────────────────────────────────────────────────────────────────────┘

                              ┌──────────────┐
                              │   category   │
                              │──────────────│
                              │ id (PK)      │
                              │ name         │
                              │ icon         │
                              │ sort         │
                              │ status       │
                              └──────┬───────┘
                                     │
                                     │ 1:N
                                     │
       ┌─────────────────────────────┼─────────────────────────────┐
       │                             │                             │
       ▼                             ▼                             ▼
┌──────────────┐             ┌──────────────┐             ┌──────────────┐
│    article   │             │    article   │             │spider_article│
│──────────────│             │──────────────│             │──────────────│
│ id (PK)      │◄────────────│ category_id  │             │ id (PK)      │
│ title        │             │ author_id(FK)│             │ category_id  │
│ content      │             └──────┬───────┘             └──────────────┘
│ summary      │                    │
│ cover_image  │                    │ N:1
│ view_count   │                    │
│ like_count   │                    ▼
│ comment_count│             ┌──────────────┐
│ is_featured  │             │  user_info   │
│ is_published │             │──────────────│
│ status       │             │ id (PK)      │
│ publish_time │             │ username(UQ) │
└──────┬───────┘             │ password     │
       │                     │ nickname     │
       │ 1:N                 │ avatar       │
       │                     │ email        │
       │                     │ phone        │
       ├────────────────────►│ status       │
       │                     │ role         │
       │                     └──────┬───────┘
       │                            │
       │                            │
       ▼                            │
┌──────────────┐                    │
│   comment    │                    │
│──────────────│                    │
│ id (PK)      │                    │
│ article_id   │────────────────────┤
│ user_id (FK) │────────────────────┤
│ parent_id(FK)│──┐                 │
│ content      │  │                 │
│ like_count   │  │                 │
│ status       │  │                 │
└──────┬───────┘  │                 │
       │          │                 │
       │          │ 1:N(自引用)      │
       │          │                 │
       │          ▼                 │
       │    ┌──────────────┐        │
       │    │   comment    │        │
       │    │ (parent_id)  │        │
       │    └──────────────┘        │
       │                            │
       │                            │
       ▼                            ▼
┌──────────────┐             ┌──────────────┐
│ comment_like │             │browse_history│
│──────────────│             │──────────────│
│ id (PK)      │             │ id (PK)      │
│ user_id (FK) │             │ user_id (FK) │
│ comment_id   │             │ article_id   │
└──────────────┘             └──────────────┘
                                     │
┌──────────────┐                     │
│ article_like │◄────────────────────┘
│──────────────│
│ id (PK)      │
│ user_id (FK) │
│ article_id   │
└──────────────┘

┌──────────────────┐
│ article_favorite  │
│──────────────────│
│ id (PK)          │
│ user_id (FK)     │
│ article_id (FK)  │
│ folder_name      │
└──────────────────┘

┌──────────────────┐
│ search_history   │
│──────────────────│
│ id (PK)          │
│ user_id (FK)     │
│ keyword          │
│ search_count     │
└──────────────────┘

┌──────────────────┐
│  user_follow     │
│──────────────────│
│ id (PK)          │
│ follower_id (FK) │──► user_info.id
│ followed_id (FK) │──► user_info.id
└──────────────────┘
```

---

## 实体关系汇总

| 关系 | 类型 | 说明 |
|------|------|------|
| category → article | 1:N | 一个分类下有多篇文章 |
| user_info → article | 1:N | 一个用户可以发布多篇文章(作者) |
| article → comment | 1:N | 一篇文章可以有多条评论 |
| user_info → comment | 1:N | 一个用户可以发表多条评论 |
| comment → comment | 1:N | 评论可以有子评论(自引用) |
| user_info → article_like | 1:N | 一个用户可以点赞多篇文章 |
| article → article_like | 1:N | 一篇文章可以被多个用户点赞 |
| user_info → comment_like | 1:N | 一个用户可以点赞多条评论 |
| comment → comment_like | 1:N | 一条评论可以被多个用户点赞 |
| user_info → article_favorite | 1:N | 一个用户可以收藏多篇文章 |
| article → article_favorite | 1:N | 一篇文章可以被多个用户收藏 |
| user_info → browse_history | 1:N | 一个用户可以有多条浏览历史 |
| article → browse_history | 1:N | 一篇文章可以被多个用户浏览 |
| user_info → search_history | 1:N | 一个用户可以有多条搜索历史 |
| user_info → user_follow | 1:N | 一个用户可以关注多个用户(作为follower) |
| user_info → user_follow | 1:N | 一个用户可以被多个用户关注(作为followed) |
| category → spider_article | 1:N | 一个分类下可以有多篇爬虫文章 |
