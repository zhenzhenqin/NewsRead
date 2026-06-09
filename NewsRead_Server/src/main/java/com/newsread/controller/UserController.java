package com.newsread.controller;

import com.newsread.common.JwtUtil;
import com.newsread.common.Result;
import com.newsread.entity.User;
import com.newsread.service.UserService;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

import java.util.HashMap;
import java.util.Map;

@RestController
@RequestMapping("/api/user")
public class UserController {

    private static final Logger log = LoggerFactory.getLogger(UserController.class);

    @Autowired
    private UserService userService;

    @Autowired
    private JwtUtil jwtUtil;

    @PostMapping("/login")
    public Result<Map<String, Object>> login(@RequestBody Map<String, String> params) {
        String username = params.get("username");
        String password = params.get("password");

        log.info("Login attempt: username={}", username);

        try {
            User user = userService.login(username, password);
            log.info("Login success, user={}", user.getUsername());

            String token = jwtUtil.generateToken(user.getId(), user.getUsername(), user.getRole());
            log.debug("Token generated");
            
            Map<String, Object> data = new HashMap<>();
            data.put("token", token);
            data.put("user", user);
            
            return Result.success(data);
        } catch (Exception e) {
            e.printStackTrace();
            return Result.error(e.getMessage());
        }
    }

    @PostMapping("/register")
    public Result<User> register(@RequestBody Map<String, String> params) {
        String username = params.get("username");
        String password = params.get("password");
        String nickname = params.get("nickname");
        
        try {
            User user = userService.register(username, password, nickname);
            return Result.success(user);
        } catch (Exception e) {
            return Result.error(e.getMessage());
        }
    }

    @GetMapping("/info")
    public Result<User> getUserInfo(@RequestAttribute("userId") Long userId) {
        User user = userService.getCurrentUser(userId);
        return Result.success(user);
    }

    @PostMapping("/logout")
    public Result<Void> logout() {
        return Result.success();
    }

    @PutMapping("/password")
    public Result<Void> updatePassword(@RequestBody Map<String, String> params, @RequestAttribute("userId") Long userId) {
        String oldPassword = params.get("oldPassword");
        String newPassword = params.get("newPassword");

        try {
            userService.updatePassword(userId, oldPassword, newPassword);
            return Result.success();
        } catch (Exception e) {
            return Result.error(e.getMessage());
        }
    }

    @PutMapping("/profile")
    public Result<Void> updateProfile(@RequestBody Map<String, String> params, @RequestAttribute("userId") Long userId) {
        String nickname = params.get("nickname");
        String email = params.get("email");
        String phone = params.get("phone");
        String avatar = params.get("avatar");

        try {
            userService.updateProfile(userId, nickname, email, phone, avatar);
            return Result.success();
        } catch (Exception e) {
            return Result.error(e.getMessage());
        }
    }
}