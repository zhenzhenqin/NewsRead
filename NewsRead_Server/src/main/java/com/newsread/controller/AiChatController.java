package com.newsread.controller;

import com.newsread.common.Result;
import com.newsread.service.AiChatService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api/ai")
public class AiChatController {

    @Autowired
    private AiChatService aiChatService;

    /**
     * AI 聊天接口
     */
    @PostMapping("/chat")
    public Result<String> chat(@RequestBody Map<String, Object> body,
                               @RequestAttribute("userId") Long userId) {
        @SuppressWarnings("unchecked")
        List<Map<String, String>> messages = (List<Map<String, String>>) body.get("messages");
        if (messages == null || messages.isEmpty()) {
            return Result.error("消息不能为空");
        }
        String reply = aiChatService.chat(messages);
        return Result.success(reply);
    }
}
