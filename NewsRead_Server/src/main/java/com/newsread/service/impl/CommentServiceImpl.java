package com.newsread.service.impl;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.newsread.entity.Comment;
import com.newsread.entity.CommentLike;
import com.newsread.entity.User;
import com.newsread.mapper.CommentLikeMapper;
import com.newsread.mapper.CommentMapper;
import com.newsread.mapper.UserMapper;
import com.newsread.service.CommentService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.List;

@Service
public class CommentServiceImpl implements CommentService {

    @Autowired
    private CommentMapper commentMapper;

    @Autowired
    private CommentLikeMapper commentLikeMapper;

    @Autowired
    private UserMapper userMapper;

    @Override
    public List<Comment> getCommentsByArticleId(Long articleId, Integer pageNum, Integer pageSize) {
        Page<Comment> page = new Page<>(pageNum, pageSize);
        LambdaQueryWrapper<Comment> wrapper = new LambdaQueryWrapper<>();
        wrapper.eq(Comment::getArticleId, articleId)
                .eq(Comment::getStatus, 1)
                .orderByAsc(Comment::getCreateTime);
        Page<Comment> result = commentMapper.selectPage(page, wrapper);
        List<Comment> comments = result.getRecords();

        for (Comment comment : comments) {
            User user = userMapper.selectById(comment.getUserId());
            if (user != null) {
                comment.setNickname(user.getNickname());
                comment.setAvatar(user.getAvatar());
            }
        }
        return comments;
    }

    @Override
    @Transactional
    public Comment addComment(Long articleId, Long userId, Long parentId, String content) {
        Comment comment = new Comment();
        comment.setArticleId(articleId);
        comment.setUserId(userId);
        comment.setParentId(parentId);
        comment.setContent(content);
        comment.setLikeCount(0);
        comment.setStatus(1);
        comment.setCreateTime(LocalDateTime.now());
        commentMapper.insert(comment);

        User user = userMapper.selectById(userId);
        if (user != null) {
            comment.setNickname(user.getNickname());
            comment.setAvatar(user.getAvatar());
        }
        return comment;
    }

    @Override
    @Transactional
    public void deleteComment(Long commentId, Long userId) {
        Comment comment = commentMapper.selectById(commentId);
        if (comment != null && comment.getUserId().equals(userId)) {
            commentMapper.deleteById(commentId);
        }
    }

    @Override
    @Transactional
    public void likeComment(Long commentId, Long userId) {
        LambdaQueryWrapper<CommentLike> wrapper = new LambdaQueryWrapper<>();
        wrapper.eq(CommentLike::getCommentId, commentId)
                .eq(CommentLike::getUserId, userId);
        long count = commentLikeMapper.selectCount(wrapper);
        if (count == 0) {
            CommentLike like = new CommentLike();
            like.setCommentId(commentId);
            like.setUserId(userId);
            like.setCreateTime(LocalDateTime.now());
            commentLikeMapper.insert(like);

            Comment comment = commentMapper.selectById(commentId);
            if (comment != null) {
                comment.setLikeCount(comment.getLikeCount() + 1);
                commentMapper.updateById(comment);
            }
        }
    }

    @Override
    @Transactional
    public void unlikeComment(Long commentId, Long userId) {
        LambdaQueryWrapper<CommentLike> wrapper = new LambdaQueryWrapper<>();
        wrapper.eq(CommentLike::getCommentId, commentId)
                .eq(CommentLike::getUserId, userId);
        commentLikeMapper.delete(wrapper);

        Comment comment = commentMapper.selectById(commentId);
        if (comment != null && comment.getLikeCount() > 0) {
            comment.setLikeCount(comment.getLikeCount() - 1);
            commentMapper.updateById(comment);
        }
    }

    @Override
    public boolean hasLikedComment(Long commentId, Long userId) {
        LambdaQueryWrapper<CommentLike> wrapper = new LambdaQueryWrapper<>();
        wrapper.eq(CommentLike::getCommentId, commentId)
                .eq(CommentLike::getUserId, userId);
        return commentLikeMapper.selectCount(wrapper) > 0;
    }

    @Override
    public List<Comment> list() {
        return commentMapper.selectList(null);
    }

    @Override
    public int countByArticle(Long articleId) {
        LambdaQueryWrapper<Comment> wrapper = new LambdaQueryWrapper<>();
        if (articleId != null) {
            wrapper.eq(Comment::getArticleId, articleId);
        }
        return commentMapper.selectCount(wrapper).intValue();
    }

    @Override
    public List<Comment> getAllComments(Integer pageNum, Integer pageSize, String keyword) {
        Page<Comment> page = new Page<>(pageNum, pageSize);
        LambdaQueryWrapper<Comment> wrapper = new LambdaQueryWrapper<>();
        if (keyword != null && !keyword.isEmpty()) {
            wrapper.like(Comment::getContent, keyword);
        }
        wrapper.orderByDesc(Comment::getCreateTime);
        Page<Comment> result = commentMapper.selectPage(page, wrapper);
        List<Comment> comments = result.getRecords();

        for (Comment comment : comments) {
            User user = userMapper.selectById(comment.getUserId());
            if (user != null) {
                comment.setNickname(user.getNickname());
                comment.setAvatar(user.getAvatar());
            }
        }
        return comments;
    }

    @Override
    public void hideComment(Long commentId) {
        Comment comment = commentMapper.selectById(commentId);
        if (comment != null) {
            comment.setStatus(0);
            commentMapper.updateById(comment);
        }
    }

    @Override
    public void showComment(Long commentId) {
        Comment comment = commentMapper.selectById(commentId);
        if (comment != null) {
            comment.setStatus(1);
            commentMapper.updateById(comment);
        }
    }
}