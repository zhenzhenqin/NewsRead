package com.newsread.service;

import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.*;
import org.springframework.stereotype.Service;
import org.springframework.web.client.RestTemplate;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

@Service
public class AiSummaryService {

    private static final Logger log = LoggerFactory.getLogger(AiSummaryService.class);

    @Value("${ai.model.api-url}")
    private String apiUrl;

    @Value("${ai.model.api-key}")
    private String apiKey;

    @Value("${ai.model.model-name}")
    private String modelName;

    @Autowired
    private RestTemplate restTemplate;

    private final ObjectMapper objectMapper = new ObjectMapper();

    private static final String SYSTEM_PROMPT =
            "你是一个新闻编辑助手。用户会给你一篇新闻的标题和摘要。" +
            "你需要做两件事：\n" +
            "1. 生成一段150字以内的中文精简摘要。\n" +
            "2. 从以下分类中推荐最匹配的一个，返回其ID：\n" +
            "   1-科技前沿, 2-财经资讯, 3-体育运动, 4-娱乐八卦, " +
            "5-健康养生, 6-教育培训, 7-人工智能, 8-汽车出行, 9-旅游游记, 10-国际风云\n\n" +
            "你必须且只能返回如下严格JSON格式，不要有任何多余文字、不要用Markdown代码块：\n" +
            "{\"summary\":\"精简摘要内容\",\"categoryId\":分类ID}";

    /**
     * 调用 AI 接口生成摘要和推荐分类
     * 返回 [summary, categoryId]，失败时返回 null
     */
    public String[] generate(String title, String originalSummary) {
        try {
            String userContent = "标题：" + title + "\n摘要：" + originalSummary;

            // 构造请求体（兼容 OpenAI 格式）
            Map<String, Object> body = new HashMap<>();
            body.put("model", modelName);
            body.put("temperature", 0.3);
            body.put("messages", List.of(
                    Map.of("role", "system", "content", SYSTEM_PROMPT),
                    Map.of("role", "user", "content", userContent)
            ));

            HttpHeaders headers = new HttpHeaders();
            headers.setContentType(MediaType.APPLICATION_JSON);
            headers.set("Authorization", "Bearer " + apiKey);

            HttpEntity<Map<String, Object>> request = new HttpEntity<>(body, headers);

            ResponseEntity<String> response = restTemplate.exchange(apiUrl, HttpMethod.POST, request, String.class);

            if (response.getStatusCode() != HttpStatus.OK || response.getBody() == null) {
                log.warn("AI接口返回非200: {}", response.getStatusCode());
                return null;
            }

            // 解析 OpenAI 格式响应: choices[0].message.content
            JsonNode root = objectMapper.readTree(response.getBody());
            String content = root.path("choices").path(0).path("message").path("content").asText("");

            if (content.isEmpty()) {
                log.warn("AI返回内容为空");
                return null;
            }

            // 清理可能的 Markdown 代码块包裹
            content = content.trim();
            if (content.startsWith("```")) {
                content = content.replaceAll("^```(json)?\\s*", "").replaceAll("```\\s*$", "").trim();
            }

            // 解析 AI 返回的 JSON
            JsonNode result = objectMapper.readTree(content);
            String summary = result.path("summary").asText("");
            int categoryId = result.path("categoryId").asInt(1);

            if (summary.isEmpty()) {
                log.warn("AI返回的summary为空");
                return null;
            }

            // 校验 categoryId 范围
            if (categoryId < 1 || categoryId > 10) {
                categoryId = 1;
            }

            return new String[]{summary, String.valueOf(categoryId)};

        } catch (Exception e) {
            log.error("AI摘要生成失败，执行降级策略: {}", e.getMessage());
            return null;
        }
    }
}
