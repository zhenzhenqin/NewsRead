package com.newsread.service;

import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.baomidou.mybatisplus.extension.service.IService;
import com.newsread.entity.User;
import com.newsread.entity.UserFollow;

import java.util.List;

public interface FollowService extends IService<UserFollow> {

    /**
     * 关注/取消关注（已关注则取消，未关注则新增）
     * @return true=已关注, false=已取消
     */
    boolean toggleFollow(Long followerId, Long followedId);

    /**
     * 查询是否已关注
     */
    boolean isFollowing(Long followerId, Long followedId);

    /**
     * 我的关注列表（分页，返回用户详情）
     */
    Page<User> getFollowingList(Long userId, int pageNum, int pageSize);

    /**
     * 获取关注的所有用户ID列表（内部使用）
     */
    List<Long> getFollowingUserIds(Long userId);
}
