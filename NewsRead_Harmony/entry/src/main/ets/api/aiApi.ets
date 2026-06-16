import { post } from '../utils/HttpUtil';

export class ChatMessage {
  role: string = '';
  content: string = '';
}

class ChatRequest {
  messages: ChatMessage[] = [];
}

export async function sendAiChat(messages: ChatMessage[]): Promise<string> {
  const req: ChatRequest = new ChatRequest();
  req.messages = messages;
  const jsonStr: string = JSON.stringify(req);
  console.info('[AiApi] sendAiChat 请求URL: /ai/chat');
  console.info('[AiApi] sendAiChat 请求体: ' + jsonStr);
  try {
    const result: string = await post<string>('/ai/chat', req);
    console.info('[AiApi] sendAiChat 响应成功: ' + result.substring(0, 200));
    return result;
  } catch (e) {
    let errMsg: string = '未知错误';
    if (e instanceof Error) {
      errMsg = e.message;
    } else {
      errMsg = JSON.stringify(e);
    }
    console.error('[AiApi] sendAiChat 请求异常: ' + errMsg);
    throw new Error(errMsg);
  }
}

