package com.newsread.service;

import com.newsread.entity.Comment;

import java.util.List;

public interface CommentService {

    List<Comment> getCommentsByArticleId(Long articleId, Integer pageNum, Integer pageSize);

    Comment addComment(Long articleId, Long userId, Long parentId, String content);

    void deleteComment(Long commentId, Long userId);

    void likeComment(Long commentId, Long userId);

    void unlikeComment(Long commentId, Long userId);

    boolean hasLikedComment(Long commentId, Long userId);

    List<Comment> list();

    int countByArticle(Long articleId);

    List<Comment> getAllComments(Integer pageNum, Integer pageSize, String keyword);

    void hideComment(Long commentId);

    void showComment(Long commentId);
}