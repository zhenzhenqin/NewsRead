package com.newsread.service;

import com.fasterxml.jackson.core.type.TypeReference;
import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.newsread.entity.Article;
import com.newsread.mapper.ArticleMapper;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.*;
import org.springframework.http.client.SimpleClientHttpRequestFactory;
import org.springframework.stereotype.Service;
import org.springframework.web.client.RestTemplate;

import java.util.*;

@Service
public class AiChatService {

    private static final Logger log = LoggerFactory.getLogger(AiChatService.class);

    @Value("${ai.mimo.base-url}")
    private String baseUrl;

    @Value("${ai.mimo.api-key}")
    private String apiKey;

    @Value("${ai.mimo.model-name}")
    private String modelName;

    @Value("${ai.mimo.max-tokens:2048}")
    private int maxTokens;

    @Autowired
    private ArticleMapper articleMapper;

    private final ObjectMapper objectMapper = new ObjectMapper();

    private static final String SYSTEM_PROMPT =
            "你是一个名为\"NewsRead小助手\"的智能阅读伴侣。你的主要职责是解答用户的疑问、总结资讯，并基于NewsRead平台的数据为用户推荐最相关的文章。\n" +
            "\n" +
            "【核心能力与工作流程】\n" +
            "1. 当用户提出一般性问题时，利用你的常识进行解答。\n" +
            "2. 当用户明确要求\"推荐文章\"、\"查找资讯\"，或者他们的问题暗示需要平台内的真实数据来支撑时，你必须使用 search_articles 工具来查询本地数据库。\n" +
            "3. 如果工具返回了文章列表（包含 id, title, summary 等），你必须基于这些真实数据为用户生成推荐语。\n" +
            "4. 绝对不要凭空捏造平台内不存在的文章。如果查询不到相关文章，请礼貌地告知用户目前平台暂无相关内容，并给出你自己的通用解答。\n" +
            "\n" +
            "【回答风格】\n" +
            "- 语气亲切、专业、客观。\n" +
            "- 回答要精炼，推荐文章时，可以附带一两句话解释为什么推荐这篇文章（基于文章的 summary）。\n" +
            "- 排版清晰，多使用列表和换行。\n" +
            "\n" +
            "【推荐文章格式 — 必须严格遵守】\n" +
            "推荐文章时，必须使用以下 Markdown 链接格式：\n" +
            "[文章标题](newsread://article/{id})\n" +
            "其中 {id} 是文章的数字 ID。例如：[5G技术突破](newsread://article/42)\n" +
            "绝对不要编造不存在的文章 ID。";

    private static final String TOOL_NAME = "search_articles";

    private static final int MAX_TOOL_ROUNDS = 5;

    /**
     * 调用 Mimo API 进行 AI 聊天，支持 Tool Calling
     *
     * @param messages 对话历史 [{role: "user"/"assistant", content: "..."}]
     * @return AI 最终文本回复
     */
    public String chat(List<Map<String, String>> messages) {
        try {
            // 将前端传来的简单消息格式转为 Anthropic 格式
            List<Map<String, Object>> anthropicMessages = convertMessages(messages);

            // 构造 tools 定义
            List<Map<String, Object>> tools = buildTools();

            // Tool Calling 循环
            for (int round = 0; round < MAX_TOOL_ROUNDS; round++) {
                JsonNode responseNode = callMimoApi(anthropicMessages, tools);
                if (responseNode == null) {
                    return "抱歉，AI 服务暂时不可用，请稍后再试。";
                }

                String stopReason = responseNode.path("stop_reason").asText("");
                JsonNode contentArray = responseNode.path("content");

                if ("end_turn".equals(stopReason) || "stop".equals(stopReason)) {
                    // 提取纯文本回复
                    return extractTextContent(contentArray);
                }

                if ("tool_use".equals(stopReason)) {
                    // 找到 tool_use 块
                    JsonNode toolUseBlock = null;
                    for (JsonNode block : contentArray) {
                        if ("tool_use".equals(block.path("type").asText(""))) {
                            toolUseBlock = block;
                            break;
                        }
                    }

                    if (toolUseBlock == null) {
                        return extractTextContent(contentArray);
                    }

                    String toolUseId = toolUseBlock.path("id").asText("");
                    String toolName = toolUseBlock.path("name").asText("");
                    JsonNode toolInput = toolUseBlock.path("input");

                    // 执行工具
                    String toolResult = executeTool(toolName, toolInput);

                    // 将 assistant 的 tool_use 回复加入消息列表
                    Map<String, Object> assistantMsg = new HashMap<>();
                    assistantMsg.put("role", "assistant");
                    assistantMsg.put("content", convertContentToJson(contentArray));
                    anthropicMessages.add(assistantMsg);

                    // 将 tool_result 加入消息列表
                    Map<String, Object> toolResultMsg = new HashMap<>();
                    toolResultMsg.put("role", "user");
                    toolResultMsg.put("content", List.of(
                            Map.of("type", "tool_result", "tool_use_id", toolUseId, "content", toolResult)
                    ));
                    anthropicMessages.add(toolResultMsg);

                    // 继续循环，让 AI 基于工具结果生成最终回复
                    continue;
                }

                // 其他 stop_reason，直接返回文本
                return extractTextContent(contentArray);
            }

            return "抱歉，处理超时，请尝试简化您的问题。";

        } catch (Exception e) {
            log.error("AI 聊天异常: {}", e.getMessage(), e);
            return "抱歉，AI 服务出现异常，请稍后再试。";
        }
    }

    /**
     * 调用 Mimo / Anthropic Messages API
     */
    private JsonNode callMimoApi(List<Map<String, Object>> messages, List<Map<String, Object>> tools) {
        try {
            // 自建 RestTemplate，120 秒读超时
            SimpleClientHttpRequestFactory factory = new SimpleClientHttpRequestFactory();
            factory.setConnectTimeout(10000);
            factory.setReadTimeout(300000);
            RestTemplate rt = new RestTemplate(factory);

            // 构造请求体
            Map<String, Object> body = new HashMap<>();
            body.put("model", modelName);
            body.put("max_tokens", maxTokens);
            body.put("system", SYSTEM_PROMPT);
            body.put("messages", messages);
            body.put("tools", tools);

            HttpHeaders headers = new HttpHeaders();
            headers.setContentType(MediaType.APPLICATION_JSON);
            headers.set("x-api-key", apiKey);
            headers.set("anthropic-version", "2023-06-01");

            HttpEntity<Map<String, Object>> request = new HttpEntity<>(body, headers);

            String url = baseUrl + "/v1/messages";
            log.info("调用 Mimo API: {}, 消息数: {}", url, messages.size());

            ResponseEntity<String> response = rt.exchange(url, HttpMethod.POST, request, String.class);

            if (response.getStatusCode() != HttpStatus.OK || response.getBody() == null) {
                log.warn("Mimo API 返回非200: {}", response.getStatusCode());
                return null;
            }

            log.debug("Mimo API 响应: {}", response.getBody());
            return objectMapper.readTree(response.getBody());

        } catch (Exception e) {
            log.error("调用 Mimo API 失败: {}", e.getMessage(), e);
            return null;
        }
    }

    /**
     * 将前端简单消息格式转为 Anthropic 格式
     */
    private List<Map<String, Object>> convertMessages(List<Map<String, String>> messages) {
        List<Map<String, Object>> result = new ArrayList<>();
        for (Map<String, String> msg : messages) {
            Map<String, Object> converted = new HashMap<>();
            converted.put("role", msg.get("role"));
            converted.put("content", msg.get("content"));
            result.add(converted);
        }
        return result;
    }

    /**
     * 将 JsonNode content array 转为 List<Map> 格式（用于后续消息）
     */
    private List<Map<String, Object>> convertContentToJson(JsonNode contentArray) {
        List<Map<String, Object>> result = new ArrayList<>();
        for (JsonNode block : contentArray) {
            Map<String, Object> blockMap = new HashMap<>();
            blockMap.put("type", block.path("type").asText("text"));

            if ("text".equals(block.path("type").asText(""))) {
                blockMap.put("text", block.path("text").asText(""));
            } else if ("tool_use".equals(block.path("type").asText(""))) {
                blockMap.put("id", block.path("id").asText(""));
                blockMap.put("name", block.path("name").asText(""));
                blockMap.put("input", objectMapper.convertValue(block.path("input"), new TypeReference<Map<String, Object>>() {}));
            }

            result.add(blockMap);
        }
        return result;
    }

    /**
     * 从 content 数组中提取纯文本（JsonNode 版本）
     */
    private String extractTextContent(JsonNode contentArray) {
        StringBuilder sb = new StringBuilder();
        for (JsonNode block : contentArray) {
            if ("text".equals(block.path("type").asText(""))) {
                sb.append(block.path("text").asText(""));
            }
        }
        String text = sb.toString().trim();
        return text.isEmpty() ? "抱歉，我暂时无法回答这个问题。" : text;
    }

    /**
     * 构造 tools 定义
     */
    private List<Map<String, Object>> buildTools() {
        Map<String, Object> tool = new HashMap<>();
        tool.put("name", TOOL_NAME);
        tool.put("description", "根据关键词搜索平台内的新闻文章。当用户想要查找、推荐或了解特定主题的文章时使用此工具。");

        Map<String, Object> inputSchema = new HashMap<>();
        inputSchema.put("type", "object");

        Map<String, Object> properties = new HashMap<>();
        Map<String, Object> keywordProp = new HashMap<>();
        keywordProp.put("type", "string");
        keywordProp.put("description", "搜索关键词，如\"科技\"、\"财经\"、\"体育\"等");
        properties.put("keyword", keywordProp);

        inputSchema.put("properties", properties);
        inputSchema.put("required", List.of("keyword"));

        tool.put("input_schema", inputSchema);
        return List.of(tool);
    }

    /**
     * 执行工具调用
     */
    private String executeTool(String toolName, JsonNode toolInput) {
        if (!TOOL_NAME.equals(toolName)) {
            return "未知工具: " + toolName;
        }

        String keyword = toolInput.path("keyword").asText("");
        if (keyword.isEmpty()) {
            return "搜索关键词不能为空";
        }

        try {
            List<Article> articles = articleMapper.selectByFulltext(keyword, 0, 5);
            if (articles == null || articles.isEmpty()) {
                return "未找到与\"" + keyword + "\"相关的文章。";
            }

            StringBuilder sb = new StringBuilder();
            sb.append("找到 ").append(articles.size()).append(" 篇相关文章：\n");
            for (Article article : articles) {
                sb.append("id: ").append(article.getId())
                  .append(" | title: ").append(article.getTitle())
                  .append(" | summary: ").append(article.getSummary())
                  .append("\n");
            }
            return sb.toString();

        } catch (Exception e) {
            log.error("搜索文章失败: {}", e.getMessage());
            return "搜索文章时出现错误: " + e.getMessage();
        }
    }
}
