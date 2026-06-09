import router from '@ohos.router';
import { getLikedArticles, getUserComments, getBrowseHistory } from '../api/userApi';
import { Article } from '../api/articleApi';
import { Comment } from '../api/commentApi';
import { AuthUtil } from '../utils/AuthUtil';
import promptAction from '@ohos.promptAction';

class ArticleRouteParams {
  id: number = 0;
}

@Entry
@Component
struct ProfileDetailPage {
  @State currentTab: number = 0;
  @State likedArticles: Article[] = [];
  @State userComments: Comment[] = [];
  @State browseHistory: Article[] = [];
  @State isLoading: boolean = false;
  @State isLoggedIn: boolean = false;
  private scroller: Scroller = new Scroller();

  async aboutToAppear() {
    const loggedIn = await AuthUtil.restoreLogin();
    this.isLoggedIn = loggedIn;
    if (!this.isLoggedIn) {
      promptAction.showToast({ message: '请先登录' });
      router.back();
      return;
    }
    this.loadData();
  }

  async loadData() {
    this.isLoading = true;
    try {
      if (this.currentTab === 0) {
        const result = await getLikedArticles();
        this.likedArticles = result.records || [];
      } else if (this.currentTab === 1) {
        const result = await getUserComments();
        this.userComments = result.records || [];
      } else {
        const result = await getBrowseHistory();
        this.browseHistory = result.records || [];
      }
    } catch (e) {
      console.error('加载数据失败:', JSON.stringify(e));
    } finally {
      this.isLoading = false;
    }
  }

  onTabClick(index: number) {
    this.currentTab = index;
    this.loadData();
  }

  build() {
    // 【关键修复1】最外层 Column 强制顶部对齐
    Column() {
      // --- 1. 顶部导航栏 (使用 Stack 实现完美的标题居中) ---
      Stack({ alignContent: Alignment.Start }) {
        Row() {
          Text('个人中心')
            .fontSize(18)
            .fontWeight(FontWeight.Bold)
            .fontColor('#1A1A1A')
        }
        .width('100%')
        .height('100%')
        .justifyContent(FlexAlign.Center)

        Row() {
          Text('< 返回')
            .fontSize(15)
            .fontColor('#409EFF')
            .padding({ left: 16, right: 16, top: 12, bottom: 12 })
            .onClick(() => {
              router.back();
            })
        }
        .height('100%')
      }
      .width('100%')
      .height(56)
      .backgroundColor('#FFFFFF')

      // --- 2. 标签切换栏 ---
      Row({ space: 0 }) {
        Column() {
          Text('我的喜欢')
            .fontSize(15)
            .fontColor(this.currentTab === 0 ? '#409EFF' : '#666666')
            .fontWeight(this.currentTab === 0 ? FontWeight.Medium : FontWeight.Normal)
          if (this.currentTab === 0) {
            Divider()
              .width(24)
              .height(3)
              .backgroundColor('#409EFF')
              .borderRadius(2)
              .margin({ top: 6 })
          } else {
            Divider().width(24).height(3).color('transparent').margin({ top: 6 }) // 占位防抖动
          }
        }
        .layoutWeight(1)
        .justifyContent(FlexAlign.Center)
        .height('100%')
        .onClick(() => this.onTabClick(0))

        Column() {
          Text('我的评论')
            .fontSize(15)
            .fontColor(this.currentTab === 1 ? '#409EFF' : '#666666')
            .fontWeight(this.currentTab === 1 ? FontWeight.Medium : FontWeight.Normal)
          if (this.currentTab === 1) {
            Divider()
              .width(24)
              .height(3)
              .backgroundColor('#409EFF')
              .borderRadius(2)
              .margin({ top: 6 })
          } else {
            Divider().width(24).height(3).color('transparent').margin({ top: 6 })
          }
        }
        .layoutWeight(1)
        .justifyContent(FlexAlign.Center)
        .height('100%')
        .onClick(() => this.onTabClick(1))

        Column() {
          Text('浏览历史')
            .fontSize(15)
            .fontColor(this.currentTab === 2 ? '#409EFF' : '#666666')
            .fontWeight(this.currentTab === 2 ? FontWeight.Medium : FontWeight.Normal)
          if (this.currentTab === 2) {
            Divider()
              .width(24)
              .height(3)
              .backgroundColor('#409EFF')
              .borderRadius(2)
              .margin({ top: 6 })
          } else {
            Divider().width(24).height(3).color('transparent').margin({ top: 6 })
          }
        }
        .layoutWeight(1)
        .justifyContent(FlexAlign.Center)
        .height('100%')
        .onClick(() => this.onTabClick(2))
      }
      .width('100%')
      .height(48) // 固定高度
      .backgroundColor('#FFFFFF')
      .border({ width: { bottom: 1 }, color: '#F0F0F0' })

      // --- 3. 核心内容区 ---
      if (this.isLoading) {
        Column() {
          LoadingProgress().width(32).height(32)
          Text('加载中...')
            .fontSize(14)
            .fontColor('#999999')
            .margin({ top: 12 })
        }
        .width('100%')
        .layoutWeight(1)
        .justifyContent(FlexAlign.Center) // 加载动画可以居中
      } else {
        Scroll(this.scroller) {
          // 【关键修复2】内部 Column 强制宽度 100% 且顶部对齐
          Column() {
            if (this.currentTab === 0) {
              if (this.likedArticles.length === 0) {
                this.emptyState('暂无喜欢的文章')
              } else {
                ForEach(this.likedArticles, (article: Article) => {
                  this.articleItem(article)
                }, (article: Article) => article.id.toString())
              }
            } else if (this.currentTab === 1) {
              if (this.userComments.length === 0) {
                this.emptyState('暂无评论')
              } else {
                ForEach(this.userComments, (comment: Comment) => {
                  this.commentItem(comment)
                }, (comment: Comment) => comment.id.toString())
              }
            } else {
              if (this.browseHistory.length === 0) {
                this.emptyState('暂无浏览记录')
              } else {
                ForEach(this.browseHistory, (article: Article) => {
                  this.articleItem(article)
                }, (article: Article) => article.id.toString())
              }
            }
          }
          .width('100%')
          .justifyContent(FlexAlign.Start)
          .padding({ top: 16, left: 16, right: 16, bottom: 40 })
        }
        .width('100%')
        .layoutWeight(1)
        .align(Alignment.Top) // 【关键修复3】强制 Scroll 内容停靠在顶部
        .scrollBar(BarState.Off)
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F8F8F8')
    .justifyContent(FlexAlign.Start)
  }

  @Builder
  emptyState(message: string) {
    Column() {
      Text(message)
        .fontSize(14)
        .fontColor('#999999')
        .padding({ top: 80 }) // 给空状态单独加点顶部边距，让它不至于太贴头
    }
    .width('100%')
    .alignItems(HorizontalAlign.Center)
  }

  @Builder
  articleItem(article: Article) {
    Column() {
      Row({ space: 12 }) {
        Column() {
          Text(article.title)
            .fontSize(16)
            .fontWeight(FontWeight.Medium)
            .fontColor('#1A1A1A')
            .maxLines(2)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
            .margin({ bottom: 8 })

          Row({ space: 8 }) {
            Text(article.publishTime ? article.publishTime.slice(0, 10) : '')
              .fontSize(12)
              .fontColor('#999999')

            Text('·')
              .fontSize(12)
              .fontColor('#CCCCCC')

            Row({ space: 4 }) {
              Text((article.viewCount || 0).toString()).fontSize(12).fontColor('#999999')
              Text('阅读').fontSize(12).fontColor('#999999')
            }

            Text('·')
              .fontSize(12)
              .fontColor('#CCCCCC')

            Row({ space: 4 }) {
              Text((article.likeCount || 0).toString()).fontSize(12).fontColor('#999999')
              Text('赞').fontSize(12).fontColor('#999999')
            }
          }
        }
        .alignItems(HorizontalAlign.Start)
        .layoutWeight(1)

        if (article.coverImage) {
          Image(article.coverImage)
            .width(100)
            .height(75)
            .borderRadius(8)
            .objectFit(ImageFit.Cover)
        }
      }
      .width('100%')
      .padding(16)
    }
    .width('100%')
    .backgroundColor('#FFFFFF')
    .borderRadius(12)
    .margin({ bottom: 12 })
    .shadow({ radius: 8, color: 'rgba(0, 0, 0, 0.03)', offsetX: 0, offsetY: 2 })
    .onClick(() => {
      let params = new ArticleRouteParams();
      params.id = article.id;
      router.pushUrl({ url: 'pages/ArticleDetail', params: params }).catch((err: Error) => {
        console.error('跳转失败', err.message);
      });
    })
  }

  @Builder
  commentItem(comment: Comment) {
    Column() {
      Row() {
        Text('你评论了文章')
          .fontSize(13)
          .fontColor('#666666')
        Text(' #' + comment.articleId.toString())
          .fontSize(13)
          .fontColor('#409EFF')
          .margin({ left: 4 })
      }
      .width('100%')
      .margin({ bottom: 10 })

      Text(comment.content)
        .fontSize(15)
        .fontColor('#1A1A1A')
        .lineHeight(22)
        .maxLines(3)
        .textOverflow({ overflow: TextOverflow.Ellipsis })
        .width('100%')

      Row() {
        Text(comment.createTime ? comment.createTime.slice(0, 16) : '')
          .fontSize(12)
          .fontColor('#999999')
      }
      .width('100%')
      .margin({ top: 12 })
    }
    .width('100%')
    .padding(16)
    .backgroundColor('#FFFFFF')
    .borderRadius(12)
    .margin({ bottom: 12 })
    .alignItems(HorizontalAlign.Start)
    .shadow({ radius: 8, color: 'rgba(0, 0, 0, 0.03)', offsetX: 0, offsetY: 2 })
    .onClick(() => {
      // 预留：点击评论也可以跳转到对应的文章
      let params = new ArticleRouteParams();
      params.id = comment.articleId;
      router.pushUrl({ url: 'pages/ArticleDetail', params: params }).catch((err: Error) => {
        console.error('跳转失败', err.message);
      });
    })
  }
}