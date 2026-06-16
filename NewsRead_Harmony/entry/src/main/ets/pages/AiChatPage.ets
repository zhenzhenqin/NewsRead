import router from '@ohos.router';
import promptAction from '@ohos.promptAction';
import { sendAiChat, ChatMessage } from '../api/aiApi';
import { AuthUtil } from '../utils/AuthUtil';

class LinkSegment {
  text: string = '';
  isLink: boolean = false;
  articleId: number = 0;
}

class DisplayMessage {
  role: string = '';
  content: string = '';
  segments: LinkSegment[] = [];
}

@Entry
@Component
struct AiChatPage {
  @State messages: DisplayMessage[] = [];
  @State inputText: string = '';
  @State isSending: boolean = false;
  @State streamingIndex: number = -1;
  @State cursorVisible: boolean = true;
  private cursorTimer: number = -1;
  scroller: Scroller = new Scroller();

  async aboutToAppear() {
    await AuthUtil.restoreLogin();
    const welcome: DisplayMessage = new DisplayMessage();
    welcome.role = 'assistant';
    welcome.content = '你好！我是 NewsRead 小助手，可以帮你查找和推荐文章。试着问我：\n\n- 推荐科技新闻\n- 有什么体育资讯？\n- 搜索人工智能相关文章';
    welcome.segments = this.parseContent(welcome.content);
    this.messages = [welcome];
    this.startCursorTimer();
  }

  startCursorTimer() {
    if (this.cursorTimer >= 0) {
      clearInterval(this.cursorTimer);
    }
    this.cursorTimer = setInterval(() => {
      this.cursorVisible = !this.cursorVisible;
    }, 500);
  }

  stopCursorTimer() {
    if (this.cursorTimer >= 0) {
      clearInterval(this.cursorTimer);
      this.cursorTimer = -1;
    }
    this.cursorVisible = true;
  }

  scrollToBottom() {
    setTimeout(() => {
      if (this.messages.length > 0) {
        this.scroller.scrollToIndex(this.messages.length - 1);
      }
    }, 100);
  }

  parseContent(text: string): LinkSegment[] {
    const segments: LinkSegment[] = [];
    let pos: number = 0;
    const marker: string = '](newsread://article/';

    while (pos < text.length) {
      const bracketStart: number = text.indexOf('[', pos);
      if (bracketStart < 0) {
        break;
      }

      const markerPos: number = text.indexOf(marker, bracketStart);
      if (markerPos < 0) {
        break;
      }

      const titleEnd: number = markerPos;
      const title: string = text.substring(bracketStart + 1, titleEnd);

      const idStart: number = markerPos + marker.length;
      const idEnd: number = text.indexOf(')', idStart);
      if (idEnd < 0) {
        break;
      }

      const idStr: string = text.substring(idStart, idEnd);
      const articleId: number = Number(idStr);

      if (bracketStart > pos) {
        const seg: LinkSegment = new LinkSegment();
        seg.text = text.substring(pos, bracketStart);
        seg.isLink = false;
        segments.push(seg);
      }

      const linkSeg: LinkSegment = new LinkSegment();
      linkSeg.text = title;
      linkSeg.isLink = true;
      linkSeg.articleId = articleId;
      segments.push(linkSeg);

      pos = idEnd + 1;
    }

    if (pos < text.length) {
      const seg: LinkSegment = new LinkSegment();
      seg.text = text.substring(pos);
      seg.isLink = false;
      segments.push(seg);
    }

    if (segments.length === 0) {
      const seg: LinkSegment = new LinkSegment();
      seg.text = text;
      seg.isLink = false;
      segments.push(seg);
    }

    return segments;
  }

  async sendMessage() {
    const trimmed: string = this.inputText.trim();
    if (trimmed.length === 0 || this.isSending) {
      return;
    }

    const userMsg: DisplayMessage = new DisplayMessage();
    userMsg.role = 'user';
    userMsg.content = trimmed;
    userMsg.segments = [];
    this.messages.push(userMsg);
    this.inputText = '';
    this.isSending = true;
    this.scrollToBottom();

    const chatMessages: ChatMessage[] = [];
    for (let i = 0; i < this.messages.length - 1; i++) {
      const m: DisplayMessage = this.messages[i];
      const cm: ChatMessage = new ChatMessage();
      cm.role = m.role;
      cm.content = m.content;
      chatMessages.push(cm);
    }

    // 添加 AI 消息占位
    const aiMsg: DisplayMessage = new DisplayMessage();
    aiMsg.role = 'assistant';
    aiMsg.content = '';
    aiMsg.segments = [];
    this.messages.push(aiMsg);
    this.streamingIndex = this.messages.length - 1;
    this.startCursorTimer();
    this.scrollToBottom();

    try {
      const reply: string = await sendAiChat(chatMessages);
      // 模拟逐字输出效果
      await this.typewriterEffect(reply);
    } catch (e) {
      let errorDetail: string = '未知错误';
      if (e instanceof Error) {
        errorDetail = e.message;
      } else {
        errorDetail = JSON.stringify(e);
      }
      if (this.streamingIndex >= 0 && this.streamingIndex < this.messages.length) {
        const msg: DisplayMessage = this.messages[this.streamingIndex];
        msg.content = '抱歉，请求失败：' + errorDetail;
        msg.segments = [];
      }
      promptAction.showToast({ message: '发送失败: ' + errorDetail });
    } finally {
      this.isSending = false;
      this.streamingIndex = -1;
      this.stopCursorTimer();
      // 最终解析链接
      if (this.messages.length > 0) {
        const lastMsg: DisplayMessage = this.messages[this.messages.length - 1];
        if (lastMsg.role === 'assistant') {
          lastMsg.segments = this.parseContent(lastMsg.content);
        }
      }
      this.scrollToBottom();
    }
  }

  typewriterEffect(fullText: string): Promise<void> {
    return new Promise<void>((resolve) => {
      let charIndex: number = 0;
      const speed: number = 15;
      const timer = setInterval(() => {
        if (charIndex >= fullText.length) {
          clearInterval(timer);
          if (this.streamingIndex >= 0 && this.streamingIndex < this.messages.length) {
            const msg: DisplayMessage = this.messages[this.streamingIndex];
            msg.content = fullText;
          }
          resolve();
          return;
        }
        // 每次追加 1-3 个字符，模拟自然节奏
        const step: number = 1 + Math.floor(Math.random() * 3);
        charIndex = Math.min(charIndex + step, fullText.length);
        if (this.streamingIndex >= 0 && this.streamingIndex < this.messages.length) {
          const msg: DisplayMessage = this.messages[this.streamingIndex];
          msg.content = fullText.substring(0, charIndex);
        }
        this.scrollToBottom();
      }, speed);
    });
  }

  navigateToArticle(articleId: number) {
    const params: Record<string, Object> = {};
    params['id'] = articleId;
    router.pushUrl({ url: 'pages/ArticleDetail', params: params });
  }

  @Builder
  messageBubbleBuilder(msg: DisplayMessage, index: number) {
    Row() {
      if (msg.role === 'user') {
        Blank()
        Column() {
          Text(msg.content)
            .fontSize(15)
            .fontColor('#FFFFFF')
            .padding(12)
        }
        .backgroundColor('#409EFF')
        .borderRadius({ topLeft: 16, topRight: 16, bottomLeft: 16, bottomRight: 4 })
        .constraintSize({ maxWidth: '75%' })
      } else {
        Column() {
          if (this.streamingIndex === index) {
            // 流式输出中：显示纯文本 + 光标
            Row() {
              Text(msg.content)
                .fontSize(15)
                .fontColor('#1A1A1A')
              Text('|')
                .fontSize(15)
                .fontColor('#409EFF')
                .opacity(this.cursorVisible ? 1 : 0)
            }
            .padding(12)
          } else if (msg.segments.length === 0) {
            Text(msg.content)
              .fontSize(15)
              .fontColor('#1A1A1A')
              .padding(12)
          } else {
            Flex({ wrap: FlexWrap.Wrap }) {
              ForEach(msg.segments, (seg: LinkSegment) => {
                if (seg.isLink) {
                  Text(seg.text)
                    .fontSize(15)
                    .fontColor('#409EFF')
                    .decoration({ type: TextDecorationType.Underline })
                    .backgroundColor('#EBF5FF')
                    .borderRadius(4)
                    .padding({ left: 4, right: 4, top: 2, bottom: 2 })
                    .onClick(() => {
                      this.navigateToArticle(seg.articleId);
                    })
                } else {
                  Text(seg.text)
                    .fontSize(15)
                    .fontColor('#1A1A1A')
                }
              })
            }
            .padding(12)
          }
        }
        .backgroundColor('#FFFFFF')
        .borderRadius({ topLeft: 4, topRight: 16, bottomLeft: 16, bottomRight: 16 })
        .constraintSize({ maxWidth: '75%' })
        .shadow({ radius: 4, color: 'rgba(0,0,0,0.05)' })
        Blank()
      }
    }
    .width('100%')
    .padding({ left: 16, right: 16, top: 6, bottom: 6 })
    .alignItems(VerticalAlign.Top)
  }

  build() {
    Column() {
      Row() {
        Text('< 返回')
          .fontSize(15)
          .fontColor('#409EFF')
          .onClick(() => {
            router.back();
          })
        Text('NewsRead 小助手')
          .fontSize(18)
          .fontWeight(FontWeight.Bold)
          .fontColor('#1A1A1A')
        Text('  ')
          .fontSize(15)
      }
      .width('100%')
      .height(56)
      .padding({ left: 16, right: 16 })
      .backgroundColor('#FFFFFF')
      .justifyContent(FlexAlign.SpaceBetween)
      .alignItems(VerticalAlign.Center)

      List({ scroller: this.scroller, space: 0 }) {
        ForEach(this.messages, (msg: DisplayMessage, index: number) => {
          ListItem() {
            this.messageBubbleBuilder(msg, index)
          }
        })
      }
      .layoutWeight(1)
      .scrollBar(BarState.Off)
      .edgeEffect(EdgeEffect.Spring)
      .backgroundColor('#F5F5F5')

      if (this.isSending && this.streamingIndex < 0) {
        Row() {
          LoadingProgress().width(16).height(16)
          Text('AI 思考中...')
            .fontSize(13)
            .fontColor('#999999')
            .margin({ left: 8 })
        }
        .width('100%')
        .height(36)
        .justifyContent(FlexAlign.Center)
        .backgroundColor('#F5F5F5')
      }

      Divider()

      Row({ space: 10 }) {
        TextInput({ text: this.inputText, placeholder: '输入消息...' })
          .layoutWeight(1)
          .height(40)
          .fontSize(15)
          .borderRadius(20)
          .backgroundColor('#F5F5F5')
          .padding({ left: 16, right: 16 })
          .onChange((value: string) => {
            this.inputText = value;
          })
          .onSubmit(() => {
            this.sendMessage();
          })

        Button('发送')
          .height(40)
          .fontSize(15)
          .borderRadius(20)
          .backgroundColor('#409EFF')
          .fontColor('#FFFFFF')
          .enabled(!this.isSending && this.inputText.trim().length > 0)
          .onClick(() => {
            this.sendMessage();
          })
      }
      .width('100%')
      .padding({ left: 16, right: 16, top: 10, bottom: 10 })
      .backgroundColor('#FFFFFF')
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F5F5F5')
  }
}
