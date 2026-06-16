package com.newsread.controller;

import com.newsread.common.Result;
import com.newsread.service.AiChatService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.MediaType;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.servlet.mvc.method.annotation.SseEmitter;

import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api/ai")
public class AiChatController {

    @Autowired
    private AiChatService aiChatService;

    /**
     * AI 聊天接口（非流式）
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

    /**
     * AI 聊天接口（SSE 流式）
     */
    @PostMapping(value = "/chat/stream", produces = MediaType.TEXT_EVENT_STREAM_VALUE)
    public SseEmitter chatStream(@RequestBody Map<String, Object> body,
                                 @RequestAttribute("userId") Long userId) {
        @SuppressWarnings("unchecked")
        List<Map<String, String>> messages = (List<Map<String, String>>) body.get("messages");
        SseEmitter emitter = new SseEmitter(300000L);
        aiChatService.streamChat(messages, emitter);
        return emitter;
    }
}
