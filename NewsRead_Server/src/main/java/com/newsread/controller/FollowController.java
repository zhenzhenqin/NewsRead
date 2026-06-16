package com.newsread.controller;

import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.newsread.common.Result;
import com.newsread.entity.User;
import com.newsread.service.FollowService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

import java.util.Map;

@RestController
@RequestMapping("/api/follow")
public class FollowController {

    @Autowired
    private FollowService followService;

    /**
     * 关注/取消关注（已关注则取消，未关注则新增）
     */
    @PostMapping("/toggle")
    public Result<Boolean> toggle(@RequestBody Map<String, Long> params,
                                  @RequestAttribute("userId") Long userId) {
        Long followedId = params.get("followedId");
        if (followedId == null) {
            return Result.error("followedId 不能为空");
        }
        boolean nowFollowing = followService.toggleFollow(userId, followedId);
        return Result.success(nowFollowing);
    }

    /**
     * 查询是否已关注
     */
    @GetMapping("/check")
    public Result<Boolean> check(@RequestParam Long followedId,
                                 @RequestAttribute("userId") Long userId) {
        return Result.success(followService.isFollowing(userId, followedId));
    }

    /**
     * 我的关注列表（分页，返回用户详情）
     */
    @GetMapping("/list")
    public Result<Page<User>> list(@RequestAttribute("userId") Long userId,
                                   @RequestParam(defaultValue = "1") Integer pageNum,
                                   @RequestParam(defaultValue = "10") Integer pageSize) {
        return Result.success(followService.getFollowingList(userId, pageNum, pageSize));
    }
}
