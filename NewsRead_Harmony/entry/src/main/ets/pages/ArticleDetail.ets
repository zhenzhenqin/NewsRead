import router from '@ohos.router';
import { getArticleDetail, likeArticle, unlikeArticle, hasLikedArticle } from '../api/articleApi';
import { getCommentsByArticle, addComment, likeComment, Comment } from '../api/commentApi';
import { addBrowseHistory } from '../api/userApi';
import { AuthUtil } from '../utils/AuthUtil';
import { getToken } from '../utils/HttpUtil';
import promptAction from '@ohos.promptAction';

class ArticleDetailData {
  id: number = 0;
  title: string = '';
  content: string = '';
  summary: string = '';
  coverImage: string = '';
  categoryId: number = 0;
  authorId: number = 0;
  viewCount: number = 0;
  likeCount: number = 0;
  commentCount: number = 0;
  isFeatured: number = 0;
  isPublished: number = 0;
  publishTime: string = '';
  isLiked: boolean = false;
}

@Entry
@Component
struct ArticleDetail {
  @State article: ArticleDetailData | null = null;
  @State comments: Comment[] = [];
  @State commentText: string = '';
  @State isLoading: boolean = true;
  @State isLoggedIn: boolean = false;
  private scroller: Scroller = new Scroller();

  async aboutToAppear() {
    await AuthUtil.restoreLogin();
    const params = router.getParams() as Record<string, number>;
    if (params && params['id']) {
      this.loadDetail(params['id']);
    }
  }

  async loadDetail(id: number) {
    this.isLoading = true;
    const loggedIn = await AuthUtil.restoreLogin();
    this.isLoggedIn = loggedIn;
    console.log('loadDetail: loggedIn=' + loggedIn + ', HttpUtil token=' + (getToken() ? getToken().substring(0, 20) + '...' : 'empty'));
    try {
      const data = await getArticleDetail(id);
      const article = new ArticleDetailData();
      article.id = data.id;
      article.title = data.title;
      article.content = data.content;
      article.summary = data.summary;
      article.coverImage = data.coverImage;
      article.categoryId = data.categoryId;
      article.authorId = data.authorId;
      article.viewCount = data.viewCount;
      article.likeCount = data.likeCount;
      article.commentCount = data.commentCount;
      article.isFeatured = data.isFeatured;
      article.isPublished = data.isPublished;
      article.publishTime = data.publishTime;

      this.article = article;

      console.log('loadDetail: isLoggedIn=' + this.isLoggedIn + ', articleId=' + id);

      if (this.isLoggedIn) {
        console.log('Calling addBrowseHistory...');
        try {
          await addBrowseHistory(id);
          console.log('addBrowseHistory succeeded');
        } catch (e) {
          console.error('添加浏览历史失败:', JSON.stringify(e));
        }

        const likeResult = await hasLikedArticle(id);
        this.article.isLiked = likeResult.liked;
      }

      const commentResult = await getCommentsByArticle(id);
      this.comments = commentResult.records || [];
    } catch (e) {
      console.error('加载文章失败:', JSON.stringify(e));
    } finally {
      this.isLoading = false;
    }
  }

  async handleLike() {
    if (!this.article) return;
    if (!this.isLoggedIn) {
      promptAction.showToast({ message: '请先登录' });
      return;
    }
    try {
      if (this.article.isLiked) {
        await unlikeArticle(this.article.id);
        this.article.likeCount = (this.article.likeCount || 1) - 1;
      } else {
        await likeArticle(this.article.id);
        this.article.likeCount = (this.article.likeCount || 0) + 1;
      }
      this.article.isLiked = !this.article.isLiked;
    } catch (e) {
      console.error('点赞操作失败:', JSON.stringify(e));
      promptAction.showToast({ message: '操作失败' });
    }
  }

  async handleComment() {
    if (!this.article) return;
    if (!this.commentText || !this.commentText.trim()) {
      promptAction.showToast({ message: '请输入评论内容' });
      return;
    }
    if (!this.isLoggedIn) {
      promptAction.showToast({ message: '请先登录' });
      return;
    }
    try {
      await addComment(this.article.id, this.commentText.trim());
      promptAction.showToast({ message: '评论成功' });
      this.commentText = '';
      // 刷新评论列表
      const commentResult = await getCommentsByArticle(this.article.id);
      this.comments = commentResult.records || [];
    } catch (e) {
      console.error('评论失败:', JSON.stringify(e));
      promptAction.showToast({ message: '评论失败' });
    }
  }

  build() {
    Column() {
      if (this.isLoading) {
        Row() {
          LoadingProgress()
            .width(32)
            .height(32)
          Text('加载中...')
            .fontSize(14)
            .fontColor('#999999')
            .margin({ left: 8 })
        }
        .justifyContent(FlexAlign.Center)
        .layoutWeight(1)
      } else if (this.article) {
        Column() {
          Scroll(this.scroller) {
            Column() {
              Text(this.article.title)
                .fontSize(24)
                .fontWeight(FontWeight.Bold)
                .fontColor('#1A1A1A')
                .lineHeight(32)
                .margin({ bottom: 16 })

              Row({ space: 12 }) {
                Text(this.article.categoryId ? this.article.categoryId.toString() : '默认')
                  .fontSize(13)
                  .fontColor('#409EFF')
                  .padding({ left: 10, right: 10, top: 4, bottom: 4 })
                  .backgroundColor('rgba(64,158,255,0.1)')
                  .borderRadius(4)

                Text(this.article.publishTime || '')
                  .fontSize(13)
                  .fontColor('#999999')
              }
              .width('100%')
              .margin({ bottom: 24 })

              Row({ space: 16 }) {
                Row({ space: 4 }) {
                  Text('阅读 ')
                    .fontSize(13)
                    .fontColor('#999999')
                  Text((this.article.viewCount || 0).toString())
                    .fontSize(13)
                    .fontColor('#666666')
                }

                Row({ space: 4 }) {
                  Text('点赞 ')
                    .fontSize(13)
                    .fontColor('#999999')
                  Text((this.article.likeCount || 0).toString())
                    .fontSize(13)
                    .fontColor('#666666')
                }
              }
              .width('100%')
              .margin({ bottom: 24 })

              Text(this.article.content || '')
                .fontSize(16)
                .fontColor('#333333')
                .lineHeight(28)
                .textAlign(TextAlign.JUSTIFY)
            }
            .padding({ left: 20, right: 20, top: 20 })
          }
          .scrollBar(BarState.Off)
        }
        .layoutWeight(1)

        // 底部评论区与操作栏
        Column() {
          Column() {
            Row({ space: 12 }) {
              Text('评论')
                .fontSize(16)
                .fontWeight(600)
                .fontColor('#1A1A1A')
              Text('(' + this.comments.length.toString() + ')')
                .fontSize(14)
                .fontColor('#999999')
            }
            .width('100%')
            .margin({ bottom: 16 })

            if (this.comments.length > 0) {
              Column() {
                ForEach(this.comments, (comment: Comment) => {
                  Column() {
                    Row() {
                      Text(comment.nickname || '匿名用户')
                        .fontSize(14)
                        .fontWeight(FontWeight.Medium)
                        .fontColor('#333333')
                      Text(comment.createTime ? comment.createTime.slice(0, 16) : '')
                        .fontSize(12)
                        .fontColor('#999999')
                    }
                    .width('100%')
                    .margin({ bottom: 8 })

                    Text(comment.content)
                      .fontSize(14)
                      .fontColor('#666666')
                      .lineHeight(20)
                  }
                  .width('100%')
                  .alignItems(HorizontalAlign.Start)
                  .padding({ bottom: 16 })
                  .border({
                    width: { bottom: 1 },
                    color: '#F5F5F5'
                  })
                })
              }
            } else {
              Text('暂无评论，快来抢沙发吧~')
                .fontSize(14)
                .fontColor('#999999')
                .padding({ top: 20, bottom: 20 })
            }
          }
          .width('100%')
          .padding({ left: 20, right: 20, top: 20, bottom: 12 })
          .backgroundColor('#FFFFFF')

          Row() {
            // 点赞按钮
            Row({ space: 8 }) {
              Text(this.article.isLiked ? '❤️' : '🤍')
                .fontSize(20)
              Text((this.article.likeCount || 0).toString())
                .fontSize(14)
                .fontColor(this.article.isLiked ? '#FF4D4F' : '#999999')
            }
            .onClick(() => {
              this.handleLike();
            })

            TextInput({ placeholder: '说点什么...', text: this.commentText })
              .placeholderColor('#999999')
              .fontSize(14)
              .backgroundColor('#F5F5F5')
              .borderRadius(20)
              .padding({ left: 16, right: 16, top: 8, bottom: 8 })
              .layoutWeight(1)
              .onChange((value: string) => {
                this.commentText = value;
              })

            Text('发布')
              .fontSize(14)
              .fontColor('#FFFFFF')
              .padding({ left: 16, right: 16, top: 8, bottom: 8 })
              .backgroundColor(this.commentText.length > 0 ? '#409EFF' : '#CCCCCC')
              .borderRadius(16)
              .onClick(() => {
                this.handleComment();
              })
          }
          .width('100%')
          .padding({ left: 20, right: 20, top: 12, bottom: 12 })
          .backgroundColor('#FFFFFF')
          .border({
            width: { top: 1 },
            color: '#F5F5F5'
          })
        }
      } else {
        Text('文章不存在')
          .fontSize(16)
          .fontColor('#999999')
          .layoutWeight(1)
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F8F8F8')
  }
}