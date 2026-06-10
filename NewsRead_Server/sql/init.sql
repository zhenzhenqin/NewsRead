-- NewsRead 数据库建表脚本
-- 创建数据库
CREATE DATABASE IF NOT EXISTS `newsread` DEFAULT CHARSET utf8mb4 COLLATE utf8mb4_unicode_ci;

USE `newsread`;

-- 1. 用户表
CREATE TABLE IF NOT EXISTS `user_info` (
                                           `id` BIGINT NOT NULL AUTO_INCREMENT COMMENT '用户ID',
                                           `username` VARCHAR(50) NOT NULL COMMENT '用户名',
                                           `password` VARCHAR(255) NOT NULL COMMENT '密码',
                                           `nickname` VARCHAR(50) DEFAULT NULL COMMENT '昵称',
                                           `avatar` VARCHAR(500) DEFAULT NULL COMMENT '头像URL',
                                           `email` VARCHAR(100) DEFAULT NULL COMMENT '邮箱',
                                           `phone` VARCHAR(20) DEFAULT NULL COMMENT '手机号',
                                           `status` TINYINT DEFAULT 1 COMMENT '状态 0-禁用 1-正常',
                                           `role` TINYINT DEFAULT 1 COMMENT '角色 1-普通用户 2-管理员',
                                           `create_time` DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
                                           `update_time` DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
                                           PRIMARY KEY (`id`),
                                           UNIQUE KEY `uk_username` (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='用户表';

-- 2. 分类表
CREATE TABLE IF NOT EXISTS `category` (
                                          `id` BIGINT NOT NULL AUTO_INCREMENT COMMENT '分类ID',
                                          `name` VARCHAR(50) NOT NULL COMMENT '分类名称',
                                          `icon` VARCHAR(500) DEFAULT NULL COMMENT '分类图标',
                                          `sort` INT DEFAULT 0 COMMENT '排序值',
                                          `status` TINYINT DEFAULT 1 COMMENT '状态 0-禁用 1-正常',
                                          `create_time` DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
                                          `update_time` DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
                                          PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='分类表';

-- 3. 文章表
CREATE TABLE IF NOT EXISTS `article` (
                                         `id` BIGINT NOT NULL AUTO_INCREMENT COMMENT '文章ID',
                                         `title` VARCHAR(200) NOT NULL COMMENT '文章标题',
                                         `content` TEXT NOT NULL COMMENT '文章内容',
                                         `summary` VARCHAR(500) DEFAULT NULL COMMENT '文章摘要',
                                         `cover_image` VARCHAR(500) DEFAULT NULL COMMENT '封面图',
                                         `category_id` BIGINT DEFAULT NULL COMMENT '分类ID',
                                         `author_id` BIGINT NOT NULL COMMENT '作者ID',
                                         `view_count` INT DEFAULT 0 COMMENT '阅读量',
                                         `like_count` INT DEFAULT 0 COMMENT '点赞数',
                                         `comment_count` INT DEFAULT 0 COMMENT '评论数',
                                         `is_featured` TINYINT DEFAULT 0 COMMENT '是否推荐 0-否 1-是',
                                         `is_published` TINYINT DEFAULT 1 COMMENT '是否发布 0-草稿 1-已发布',
                                         `status` TINYINT DEFAULT 1 COMMENT '状态 0-下架 1-正常',
                                         `publish_time` DATETIME DEFAULT NULL COMMENT '发布时间',
                                         `create_time` DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
                                         `update_time` DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
                                         PRIMARY KEY (`id`),
                                         KEY `idx_category_id` (`category_id`),
                                         KEY `idx_author_id` (`author_id`),
                                         KEY `idx_publish_time` (`publish_time`),
                                         KEY `idx_is_featured` (`is_featured`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='文章表';

-- 4. 评论表 (注意：comment是关键字，需要用反引号)
CREATE TABLE IF NOT EXISTS `comment` (
                                         `id` BIGINT NOT NULL AUTO_INCREMENT COMMENT '评论ID',
                                         `article_id` BIGINT NOT NULL COMMENT '文章ID',
                                         `user_id` BIGINT NOT NULL COMMENT '用户ID',
                                         `parent_id` BIGINT DEFAULT NULL COMMENT '父评论ID',
                                         `content` TEXT NOT NULL COMMENT '评论内容',
                                         `like_count` INT DEFAULT 0 COMMENT '点赞数',
                                         `status` TINYINT DEFAULT 1 COMMENT '状态 0-隐藏 1-显示',
                                         `create_time` DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
                                         `update_time` DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
                                         PRIMARY KEY (`id`),
                                         KEY `idx_article_id` (`article_id`),
                                         KEY `idx_user_id` (`user_id`),
                                         KEY `idx_parent_id` (`parent_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='评论表';

-- 5. 用户浏览历史表
CREATE TABLE IF NOT EXISTS `browse_history` (
                                                `id` BIGINT NOT NULL AUTO_INCREMENT COMMENT 'ID',
                                                `user_id` BIGINT NOT NULL COMMENT '用户ID',
                                                `article_id` BIGINT NOT NULL COMMENT '文章ID',
                                                `create_time` DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '浏览时间',
                                                PRIMARY KEY (`id`),
                                                KEY `idx_user_id` (`user_id`),
                                                KEY `idx_article_id` (`article_id`),
                                                KEY `idx_user_article` (`user_id`, `article_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='浏览历史表';

-- 6. 点赞记录表 (文章点赞)
CREATE TABLE IF NOT EXISTS `article_like` (
    `id` BIGINT NOT NULL AUTO_INCREMENT COMMENT 'ID',
    `user_id` BIGINT NOT NULL COMMENT '用户ID',
    `article_id` BIGINT NOT NULL COMMENT '文章ID',
    `create_time` DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '点赞时间',
    PRIMARY KEY (`id`),
    UNIQUE KEY `uk_user_article` (`user_id`, `article_id`),
    KEY `idx_article_id` (`article_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='文章点赞表';

-- 7. 评论点赞记录表
CREATE TABLE IF NOT EXISTS `comment_like` (
    `id` BIGINT NOT NULL AUTO_INCREMENT COMMENT 'ID',
    `user_id` BIGINT NOT NULL COMMENT '用户ID',
    `comment_id` BIGINT NOT NULL COMMENT '评论ID',
    `create_time` DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '点赞时间',
    PRIMARY KEY (`id`),
    UNIQUE KEY `uk_user_comment` (`user_id`, `comment_id`),
    KEY `idx_comment_id` (`comment_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='评论点赞表';

-- 初始化数据 - 分类
INSERT INTO `category` (`id`, `name`, `icon`, `sort`, `status`) VALUES
                                                                    (1, '科技前沿', '科技', 1, 1),
                                                                    (2, '财经资讯', '财经', 2, 1),
                                                                    (3, '体育运动', '体育', 3, 1),
                                                                    (4, '娱乐八卦', '娱乐', 4, 1),
                                                                    (5, '健康养生', '健康', 5, 1),
                                                                    (6, '教育培训', '教育', 6, 1);

-- 初始化数据 - 管理员用户 (密码: 123456)
-- Bcrypt Hash: $2a$10$c1/J3c0Zz84H5b63x5B1O.kC.d3A94/O2vG9uR11lR2yX0Xh9W0aK
INSERT INTO `user_info` (`id`, `username`, `password`, `nickname`, `role`, `status`) VALUES
    (1, 'admin', '$2a$10$c1/J3c0Zz84H5b63x5B1O.kC.d3A94/O2vG9uR11lR2yX0Xh9W0aK', '超级管理员', 2, 1);





USE `newsread`;

-- ==========================================
-- 1. 插入全新的分类数据 (ID从20开始)
-- ==========================================
INSERT INTO `category` (`id`, `name`, `icon`, `sort`, `status`) VALUES
                                                                    (20, '人工智能', 'AI', 7, 1),
                                                                    (21, '汽车出行', '汽车', 8, 1),
                                                                    (22, '旅游游记', '旅游', 9, 1),
                                                                    (23, '国际风云', '国际', 10, 1);

-- ==========================================
-- 2. 插入全新的测试用户 (ID从100开始，密码统一为: 123456)
-- Bcrypt Hash: $2a$10$c1/J3c0Zz84H5b63x5B1O.kC.d3A94/O2vG9uR11lR2yX0Xh9W0aK
-- ==========================================
INSERT INTO `user_info` (`id`, `username`, `password`, `nickname`, `avatar`, `email`, `phone`, `status`, `role`) VALUES
                                                                                                                     (100, 'sg_techie', '$2a$10$c1/J3c0Zz84H5b63x5B1O.kC.d3A94/O2vG9uR11lR2yX0Xh9W0aK', '新加坡极客小陈', 'https://picsum.photos/id/105/200/200', 'sg_techie@test.com', '+6591234567', 1, 1),
                                                                                                                     (101, 'globetrotter_ai', '$2a$10$c1/J3c0Zz84H5b63x5B1O.kC.d3A94/O2vG9uR11lR2yX0Xh9W0aK', '环球旅行家爱AI', 'https://picsum.photos/id/106/200/200', 'globetrotter_ai@test.com', '+12025550101', 1, 1),
                                                                                                                     (102, 'mobility_next', '$2a$10$c1/J3c0Zz84H5b63x5B1O.kC.d3A94/O2vG9uR11lR2yX0Xh9W0aK', '出行未来观察家', 'https://picsum.photos/id/107/200/200', 'mobility_next@test.com', '+4930123456', 1, 1),
                                                                                                                     (103, 'world_observer', '$2a$10$c1/J3c0Zz84H5b63x5B1O.kC.d3A94/O2vG9uR11lR2yX0Xh9W0aK', '国际局势观察员', 'https://picsum.photos/id/108/200/200', 'world_observer@test.com', '+442079460101', 1, 1);

-- ==========================================
-- 3. 插入全新的文章数据 (ID从200开始，覆盖新旧分类，作者为新用户ID 100-103)
-- 全部发布时间都设在 2026-04-14 当天或前一天
-- ==========================================
INSERT INTO `article` (`id`, `title`, `content`, `summary`, `cover_image`, `category_id`, `author_id`, `view_count`, `like_count`, `comment_count`, `is_featured`, `is_published`, `publish_time`) VALUES

-- 人工智能 (category_id = 20)
(200, 'GPT-5发布一周年：AI大模型如何彻底重塑了我们的职场？', '<p>距离GPT-5震撼发布已经过去整整一年，这一年里，从基础代码编写到复杂视频生成，AI的能力边界被不断拓宽。调查显示，超过60%的白领已经将AI作为日常办公不可或缺的超级助理，企业效率得到显著提升，但同时也引发了对部分初级岗位未来的深切担忧...</p>', '深度盘点GPT-5发布一年来带来的行业巨变与深远影响，探讨人机协作的新范式。', 'https://picsum.photos/id/11/600/300', 20, 100, 45600, 3200, 4, 1, 1, '2026-04-14 08:30:00'),
(201, '人形机器人“具身智能”迎拐点，首批家庭服务机器人年底正式发售', '<p>多家头部科技巨头联合宣布，搭载最新“具身智能”系统的全尺寸人形机器人已顺利通过安全审查。这种具备深度学习能力、能精准执行家庭清洁和陪护任务的机器人，售价预计在15万元人民币以内，年底将正式步入普通家庭，彻底改变我们的生活方式...</p>', '科幻走进现实，具备具身智能的家庭保姆机器人时代正式开启。', 'https://picsum.photos/id/12/600/300', 20, 101, 28900, 1500, 2, 1, 1, '2026-04-13 14:00:00'),

-- 汽车出行 (category_id = 21)
(202, 'L4级自动驾驶正式在新加坡、北上广深开放商业化试运营', '<p>交通部今日正式批复，允许具备L4级自动驾驶能力的无人出租车（Robotaxi）在新加坡核心区域、以及中国北上广深四大一线城市的核心区域进行全无人商业化试运营。市民可通过专属App一键呼叫无方向盘汽车，体验未来出行，这也标志着自动驾驶技术正式进入大规模商业化阶段...</p>', '无人驾驶全面铺开，网约车行业面临大洗牌，城市交通将迎来巨变。', 'https://picsum.photos/id/13/600/300', 21, 102, 38000, 2100, 3, 1, 1, '2026-04-14 10:15:00'),
(203, '固态电池汽车百公里衰减评测：极寒天气下表现究竟如何？', '<p>随着首批量产的半固态及全固态电池新能源车交付满半年，我们收集了数百位车主在极寒天气下的真实驾驶数据。本文将深度对比不同品牌固态电池在零下20度环境下的续航衰减报告，为大家带来最详尽、最真实的购买建议...</p>', '真实车主数据揭秘固态电池的抗冻神话，为新能源车主提供科学参考。', 'https://picsum.photos/id/14/600/300', 21, 100, 15000, 890, 0, 0, 1, '2026-04-12 09:00:00'),

-- 体育运动 (category_id = 3)
(204, '2026美加墨世界杯倒计时两个月：揭幕战球场准备就绪', '<p>距离史上规模最大、由三国联合举办的2026年世界杯开幕仅剩最后两个月！国际足联官员今日对墨西哥城阿兹特克体育场进行了最终巡视，这座传奇球场将第三次承办世界杯赛事，所有筹备工作均已就绪，全球狂欢即将拉开帷幕...</p>', '全球狂欢即将开启，美加墨世界杯进入最后冲刺阶段，传奇球场静候揭幕。', 'https://picsum.photos/id/15/600/300', 3, 103, 52000, 4800, 2, 1, 1, '2026-04-14 07:00:00'),

-- 科技前沿 (category_id = 1)
(205, 'iPhone 18 Pro 高清渲染图曝光：彻底取消实体按键？', '<p>知名科技博主今日曝光了即将于今年秋季发布的 iPhone 18 Pro 的最新渲染图。令人震惊的是，机身侧边首次彻底取消了所有实体按键，转而采用超声波压感触控技术，实现完美的无缝机身，果粉们都在热议这一设计上的重大突破...</p>', '果粉沸腾！iPhone迎来十年来最大外观变革，无实体按键时代或将到来。', 'https://picsum.photos/id/16/600/300', 1, 101, 67000, 5600, 3, 1, 1, '2026-04-13 20:00:00'),

-- 旅游游记 (category_id = 22)
(206, '2026“五一”黄金周出游预测：小众出境游目的地成新宠', '<p>随着国际航班的全面恢复和免签朋友圈的再次扩大，今年的“五一”小长假迎来了报复性出境游热潮。相比传统的新马泰，格鲁吉亚、塞尔维亚等冷门目的地搜索量暴增300%，这些极具性价比的小众目的地正在改变中国游客的出游习惯...</p>', '五一去哪玩？这份避开人从众的冷门出境游攻略请收好，体验不一样的风景。', 'https://picsum.photos/id/17/600/300', 22, 103, 21000, 1100, 0, 0, 1, '2026-04-12 16:30:00'),

-- 国际风云 (category_id = 23)
(207, '人类首次火星载人环绕任务飞船成功进入近火轨道', '<p>创造历史！联合航天局今日宣布，“探索者一号”载人飞船在经历了漫长的太空飞行后，于北京时间今日凌晨成功被火星引力捕获，3名宇航员传回了首张超高清火星背面照片。这标志着人类距离登陆火星仅一步之遥，开启了行星探索的新纪元...</p>', '航天史上的里程碑，人类载人飞船首次成功进入火星轨道，见证历史性一刻。', 'https://picsum.photos/id/18/600/300', 23, 100, 89000, 9999, 5, 1, 1, '2026-04-14 11:00:00');

-- ==========================================
-- 4. 插入全新的评论数据 (评论ID从1000开始，层级评论，作者为新用户ID 100-103)
-- 全部评论时间也设在 2026-04-14 当天
-- ==========================================
INSERT INTO `comment` (`id`, `article_id`, `user_id`, `parent_id`, `content`, `like_count`, `create_time`) VALUES
-- AI与职场 (文章200)
(1000, 200, 102, NULL, '现在的AI确实可怕，我们公司已经用大模型优化掉了一批基础校对和初级客服了。', 560, '2026-04-14 09:15:00'),
(1001, 200, 100, 1000, '不用太焦虑，掌握如何给AI写Prompt，让它成为你的工具才是出路。', 120, '2026-04-14 09:30:00'),
(1002, 200, 103, NULL, '期待GPT-6，不知道会不会有自主意识出现。', 45, '2026-04-14 10:00:00'),
(1003, 200, 101, 1002, '距离真正的强人工智能（AGI）还有一段路要走。', 22, '2026-04-14 10:15:00'),

-- L4自动驾驶 (文章202)
(1004, 202, 100, NULL, '我在新加坡已经坐过好几次无人出租车了，真的很平稳，而且比普通网约车便宜！', 340, '2026-04-14 10:45:00'),
(1005, 202, 102, 1004, '老司机表示不服，遇到加塞和复杂路况，机器还是不如人脑灵活。', 89, '2026-04-14 11:10:00'),
(1006, 202, 101, NULL, '出租车司机这个职业看来真的要被彻底颠覆了，时代抛弃你连招呼都不打。', 410, '2026-04-14 11:20:00'),

-- 美加墨世界杯 (文章204)
(1007, 204, 103, NULL, '扩军到48支球队了，国足这次总该进了吧？！', 888, '2026-04-14 08:00:00'),
(1008, 204, 102, 1007, '兄弟，你快醒醒，别做梦了...', 1024, '2026-04-14 08:05:00'),

-- 火星探测 (文章207)
(1009, 207, 100, NULL, '见证历史！这是全人类的一大步！向所有航天人致敬！', 2500, '2026-04-14 11:05:00'),
(1010, 207, 102, 1009, '有生之年希望能看到普通人买票去火星旅游。', 600, '2026-04-14 11:15:00'),
(1011, 207, 101, NULL, '这几张火星背面的照片拍得太震撼了，宇宙浩瀚无垠啊。', 1200, '2026-04-14 11:30:00'),
(1012, 207, 103, NULL, '这算不算地球人对火星的第一次“贴脸开大”？', 850, '2026-04-14 12:00:00'),
(1013, 207, 100, 1012, '哈哈哈，比喻很形象。下一步就是送人登陆了。', 110, '2026-04-14 12:15:00');

-- ==========================================
-- 5. 插入全新的浏览与点赞记录 (全部使用新用户ID和新文章/评论ID，时间设在当天)
-- 用于丰富个人中心的测试数据，这些条目不指定ID，使用自增。
-- ==========================================

-- 插入浏览历史
INSERT INTO `browse_history` (`user_id`, `article_id`, `create_time`) VALUES
-- 用户100 (科技/AI达人) 狂刷前沿技术和自动驾驶
(100, 200, '2026-04-14 09:20:00'),
(100, 205, '2026-04-13 20:30:00'),
(100, 202, '2026-04-14 11:15:00'),
(100, 207, '2026-04-14 11:02:00'),

-- 用户101 (环球旅行家/AI迷) 看机器人、iPhone和火星探测
(101, 201, '2026-04-13 15:00:00'),
(101, 205, '2026-04-13 21:00:00'),
(101, 207, '2026-04-14 11:03:00'),

-- 用户102 (出行未来观察家) 专注无人驾驶和电池评测
(102, 202, '2026-04-14 10:30:00'),
(102, 203, '2026-04-12 10:00:00'),

-- 用户103 (国际局势观察员) 吐槽世界杯、关心火星探测和五一旅游预测
(103, 204, '2026-04-14 07:30:00'),
(103, 207, '2026-04-14 11:28:00'),
(103, 206, '2026-04-12 17:00:00');

-- 插入文章点赞记录 (用于测试个人中心的"我的喜欢"列表)
INSERT INTO `article_like` (`user_id`, `article_id`, `create_time`) VALUES
                                                                        (100, 200, '2026-04-14 09:25:00'),
                                                                        (100, 207, '2026-04-14 11:05:00'),
                                                                        (101, 201, '2026-04-13 15:30:00'),
                                                                        (102, 202, '2026-04-14 10:45:00'),
                                                                        (102, 203, '2026-04-12 10:10:00'),
                                                                        (103, 207, '2026-04-14 11:40:00');

-- 8. 爬虫文章暂存表
CREATE TABLE IF NOT EXISTS `spider_article` (
    `id` BIGINT NOT NULL AUTO_INCREMENT COMMENT 'ID',
    `title` VARCHAR(200) NOT NULL COMMENT '新闻标题',
    `summary` VARCHAR(500) DEFAULT NULL COMMENT '摘要',
    `cover_image` VARCHAR(500) DEFAULT NULL COMMENT '封面图URL',
    `source_url` VARCHAR(500) DEFAULT NULL COMMENT '原始链接',
    `category_id` BIGINT DEFAULT NULL COMMENT '分类ID',
    `status` TINYINT DEFAULT 1 COMMENT '状态 1-正常 0-已删除',
    `fetch_time` DATETIME DEFAULT NULL COMMENT '抓取时间',
    `create_time` DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    PRIMARY KEY (`id`),
    KEY `idx_status` (`status`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='爬虫文章暂存表';

-- 插入评论点赞记录 (测试评论列表功能)
INSERT INTO `comment_like` (`user_id`, `comment_id`, `create_time`) VALUES
                                                                        (101, 1000, '2026-04-14 09:40:00'), -- 点赞职场评论
                                                                        (100, 1012, '2026-04-14 12:05:00'), -- 点赞"贴脸开大"评论
                                                                        (103, 1004, '2026-04-14 11:00:00'), -- 点赞新加坡无人出租评论
                                                                        (100, 1016, '2026-04-14 08:06:00'), -- 点赞"吐槽国足"的精彩回复
                                                                        (102, 1016, '2026-04-14 08:10:00'); -- 再次点赞
