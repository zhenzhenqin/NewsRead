package com.newsread.service.impl;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.newsread.entity.User;
import com.newsread.entity.UserFollow;
import com.newsread.mapper.UserFollowMapper;
import com.newsread.service.FollowService;
import com.newsread.service.UserService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.Collections;
import java.util.List;
import java.util.stream.Collectors;

@Service
public class FollowServiceImpl extends ServiceImpl<UserFollowMapper, UserFollow> implements FollowService {

    @Autowired
    private UserService userService;

    @Override
    public boolean toggleFollow(Long followerId, Long followedId) {
        if (followerId.equals(followedId)) {
            throw new RuntimeException("不能关注自己");
        }
        LambdaQueryWrapper<UserFollow> wrapper = new LambdaQueryWrapper<>();
        wrapper.eq(UserFollow::getFollowerId, followerId)
               .eq(UserFollow::getFollowedId, followedId);
        UserFollow existing = this.getOne(wrapper);
        if (existing != null) {
            this.removeById(existing.getId());
            return false; // 已取消关注
        } else {
            UserFollow follow = new UserFollow();
            follow.setFollowerId(followerId);
            follow.setFollowedId(followedId);
            this.save(follow);
            return true; // 已关注
        }
    }

    @Override
    public boolean isFollowing(Long followerId, Long followedId) {
        LambdaQueryWrapper<UserFollow> wrapper = new LambdaQueryWrapper<>();
        wrapper.eq(UserFollow::getFollowerId, followerId)
               .eq(UserFollow::getFollowedId, followedId);
        return this.count(wrapper) > 0;
    }

    @Override
    public Page<User> getFollowingList(Long userId, int pageNum, int pageSize) {
        // 1. 分页查询关注记录
        LambdaQueryWrapper<UserFollow> wrapper = new LambdaQueryWrapper<>();
        wrapper.eq(UserFollow::getFollowerId, userId)
               .orderByDesc(UserFollow::getCreateTime);
        Page<UserFollow> followPage = this.page(new Page<>(pageNum, pageSize), wrapper);

        // 2. 提取 followedId 列表
        List<Long> followedIds = followPage.getRecords().stream()
                .map(UserFollow::getFollowedId)
                .collect(Collectors.toList());

        // 3. 批量查询用户详情
        Page<User> result = new Page<>(pageNum, pageSize, followPage.getTotal());
        if (followedIds.isEmpty()) {
            result.setRecords(Collections.emptyList());
        } else {
            List<User> users = userService.listByIds(followedIds);
            result.setRecords(users);
        }
        return result;
    }

    @Override
    public List<Long> getFollowingUserIds(Long userId) {
        LambdaQueryWrapper<UserFollow> wrapper = new LambdaQueryWrapper<>();
        wrapper.eq(UserFollow::getFollowerId, userId)
               .select(UserFollow::getFollowedId);
        return this.list(wrapper).stream()
                .map(UserFollow::getFollowedId)
                .collect(Collectors.toList());
    }
}
