package com.newsread.service;

import com.baomidou.mybatisplus.extension.service.IService;
import com.newsread.entity.User;

public interface UserService extends IService<User> {
    
    User login(String username, String password);
    
    User register(String username, String password, String nickname);
    
    User getCurrentUser(Long userId);
    
    void updatePassword(Long userId, String oldPassword, String newPassword);
    
    void updateProfile(Long userId, String nickname, String email, String phone, String avatar);
}