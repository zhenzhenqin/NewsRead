package com.newsread.controller;

import com.newsread.common.Result;
import com.newsread.entity.Comment;
import com.newsread.service.CommentService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api/comment")
public class CommentController {

    @Autowired
    private CommentService commentService;

    @GetMapping("/list")
    public Result<Map<String, Object>> list(
            @RequestParam Long articleId,
            @RequestParam(defaultValue = "1") Integer pageNum,
            @RequestParam(defaultValue = "10") Integer pageSize) {
        List<Comment> comments = commentService.getCommentsByArticleId(articleId, pageNum, pageSize);
        Map<String, Object> data = new HashMap<>();
        data.put("records", comments);
        data.put("total", comments.size());
        return Result.success(data);
    }

    @PostMapping("/add")
    public Result<Comment> add(@RequestBody Map<String, Object> params,
                             @RequestAttribute("userId") Long userId) {
        Long articleId = Long.parseLong(params.get("articleId").toString());
        Long parentId = params.get("parentId") != null ? Long.parseLong(params.get("parentId").toString()) : null;
        String content = params.get("content").toString();
        Comment comment = commentService.addComment(articleId, userId, parentId, content);
        return Result.success(comment);
    }

    @DeleteMapping("/delete/{id}")
    public Result<Void> delete(@PathVariable Long id,
                             @RequestAttribute("userId") Long userId) {
        commentService.deleteComment(id, userId);
        return Result.success();
    }

    @PostMapping("/like/{id}")
    public Result<Void> like(@PathVariable Long id,
                        @RequestAttribute("userId") Long userId) {
        commentService.likeComment(id, userId);
        return Result.success();
    }

    @DeleteMapping("/unlike/{id}")
    public Result<Void> unlike(@PathVariable Long id,
                           @RequestAttribute("userId") Long userId) {
        commentService.unlikeComment(id, userId);
        return Result.success();
    }

    @GetMapping("/hasLiked/{id}")
    public Result<Map<String, Boolean>> hasLiked(@PathVariable Long id,
                                        @RequestAttribute("userId") Long userId) {
        Map<String, Boolean> data = new HashMap<>();
        data.put("liked", commentService.hasLikedComment(id, userId));
        return Result.success(data);
    }

    @GetMapping("/all")
    public Result<Map<String, Object>> all(
            @RequestParam(defaultValue = "1") Integer pageNum,
            @RequestParam(defaultValue = "10") Integer pageSize,
            @RequestParam(required = false) String keyword) {
        List<Comment> comments = commentService.getAllComments(pageNum, pageSize, keyword);
        Map<String, Object> data = new HashMap<>();
        data.put("records", comments);
        data.put("total", comments.size());
        return Result.success(data);
    }

    @PostMapping("/hide/{id}")
    public Result<Void> hide(@PathVariable Long id) {
        commentService.hideComment(id);
        return Result.success();
    }

    @PostMapping("/show/{id}")
    public Result<Void> show(@PathVariable Long id) {
        commentService.showComment(id);
        return Result.success();
    }
}