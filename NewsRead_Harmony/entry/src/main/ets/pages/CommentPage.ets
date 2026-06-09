import router from '@ohos.router';
import { getCommentsByArticle, addComment, likeComment, hasLikedComment, Comment } from '../api/commentApi';
import { AuthUtil } from '../utils/AuthUtil';
import promptAction from '@ohos.promptAction';

class ArticleRouteParams {
  id: number = 0;
}

@Entry
@Component
struct CommentPage {
  @State articleId: number = 0;
  @State comments: Comment[] = [];
  @State newComment: string = '';
  @State isLoading: boolean = false;
  @State isLoggedIn: boolean = false;
  private scroller: Scroller = new Scroller();

  async aboutToAppear() {
    await AuthUtil.restoreLogin();
    this.isLoggedIn = AuthUtil.isLoggedIn();
    let params = router.getParams() as ArticleRouteParams;
    if (params) {
      this.articleId = params.id;
      this.loadComments();
    }
  }

  async loadComments() {
    this.isLoading = true;
    try {
      const result = await getCommentsByArticle(this.articleId);
      this.comments = result.records || [];
    } catch (e) {
      console.error('加载评论失败:', JSON.stringify(e));
    } finally {
      this.isLoading = false;
    }
  }

  async submitComment() {
    if (!this.newComment || !this.newComment.trim()) {
      promptAction.showToast({ message: '请输入评论内容' });
      return;
    }
    if (!this.isLoggedIn) {
      promptAction.showToast({ message: '请先登录' });
      return;
    }

    try {
      await addComment(this.articleId, this.newComment.trim());
      promptAction.showToast({ message: '评论成功' });
      this.newComment = '';
      this.loadComments();
    } catch (e) {
      promptAction.showToast({ message: '评论失败' });
    }
  }

  async doLike(commentId: number) {
    if (!this.isLoggedIn) {
      promptAction.showToast({ message: '请先登录' });
      return;
    }
    try {
      await likeComment(commentId);
      await this.loadComments();
    } catch (e) {
      promptAction.showToast({ message: '点赞失败' });
    }
  }

  build() {
    Column() {
      Row() {
        Text('评论')
          .fontSize(20)
          .fontWeight(FontWeight.Bold)
        Blank()
        Text('< 返回')
          .fontSize(14)
          .fontColor('#409EFF')
          .onClick(() => {
            router.back();
          })
      }
      .width('100%')
      .padding(20)
      .backgroundColor('#FFFFFF')

      if (this.isLoading) {
        Row() {
          LoadingProgress()
          Text('加载中...')
            .fontSize(14)
            .margin({ left: 8 })
        }
        .width('100%')
        .layoutWeight(1)
        .justifyContent(FlexAlign.Center)
      } else {
        Scroll(this.scroller) {
          Column() {
            if (this.comments.length === 0) {
              Text('暂无评论，快来抢沙发吧')
                .fontSize(14)
                .fontColor('#999999')
                .padding(20)
            } else {
              ForEach(this.comments, (comment: Comment) => {
                this.commentItem(comment)
              })
            }
          }
        }
        .width('100%')
        .layoutWeight(1)
      }

      Column() {
        Row() {
          TextInput({ placeholder: '说点什么...', text: this.newComment })
            .placeholderColor('#999999')
            .backgroundColor('#F5F5F5')
            .padding(12)
            .borderRadius(20)
            .layoutWeight(1)
            .onChange((value: string) => {
              this.newComment = value;
            })

          Text('发送')
            .fontSize(14)
            .fontColor('#409EFF')
            .margin({ left: 12 })
            .onClick(() => {
              this.submitComment();
            })
        }
        .width('100%')
        .padding(12)
        .backgroundColor('#FFFFFF')
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F8F8F8')
  }

  @Builder
  commentItem(comment: Comment) {
    Column() {
      Row() {
        Column() {
          Text(comment.nickname || '匿名用户')
            .fontSize(14)
            .fontWeight(FontWeight.Medium)
            .fontColor('#333333')

          Text(comment.createTime ? comment.createTime.slice(0, 16) : '')
            .fontSize(12)
            .fontColor('#999999')
            .margin({ top: 4 })
        }
        .alignItems(HorizontalAlign.Start)
        .layoutWeight(1)

        Row({ space: 8 }) {
          Text((comment.likeCount || 0).toString())
            .fontSize(12)
            .fontColor('#999999')

          Text('赞')
            .fontSize(12)
            .fontColor('#999999')
        }
        .onClick(() => {
          this.doLike(comment.id);
        })
      }
      .width('100%')

      Text(comment.content)
        .fontSize(14)
        .fontColor('#333333')
        .margin({ top: 8 })
        .width('100%')
    }
    .width('100%')
    .padding(16)
    .backgroundColor('#FFFFFF')
    .margin({ bottom: 1 })
  }
}