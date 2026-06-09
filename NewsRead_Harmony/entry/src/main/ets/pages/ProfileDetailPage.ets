import router from '@ohos.router';
import { getLikedArticles, getUserComments, getBrowseHistory, deleteBrowseHistory, clearBrowseHistory } from '../api/userApi';
import { Article } from '../api/articleApi';
import { Comment } from '../api/commentApi';
import { AuthUtil } from '../utils/AuthUtil';
import promptAction from '@ohos.promptAction';

class ArticleRouteParams {
  id: number = 0;
}

// --- 浏览历史列表项（独立组件，支持原生 swipeAction） ---
@Observed
@Component
struct HistoryListItem {
  @ObjectLink article: Article;
  onDelete: (id: number) => void = () => {};

  @Builder
  endBuilder() {
    Row() {
      Text('删除')
        .fontSize(14)
        .fontColor('#FFFFFF')
    }
    .width(80)
    .height('100%')
    .backgroundColor('#FF4D4F')
    .justifyContent(FlexAlign.Center)
    .onClick(() => {
      this.onDelete(this.article.id);
    })
  }

  build() {
    ListItem() {
      Row({ space: 12 }) {
        Column() {
          Text(this.article.title)
            .fontSize(16)
            .fontWeight(FontWeight.Medium)
            .fontColor('#1A1A1A')
            .maxLines(2)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
            .margin({ bottom: 8 })

          Row({ space: 8 }) {
            Text(this.article.publishTime ? this.article.publishTime.slice(0, 10) : '')
              .fontSize(12)
              .fontColor('#999999')
            Text('·')
              .fontSize(12)
              .fontColor('#CCCCCC')
            Text((this.article.viewCount || 0) + '阅读')
              .fontSize(12)
              .fontColor('#999999')
            Text('·')
              .fontSize(12)
              .fontColor('#CCCCCC')
            Text((this.article.likeCount || 0) + '赞')
              .fontSize(12)
              .fontColor('#999999')
          }
        }
        .alignItems(HorizontalAlign.Start)
        .layoutWeight(1)

        if (this.article.coverImage) {
          Image(this.article.coverImage)
            .width(100)
            .height(75)
            .borderRadius(8)
            .objectFit(ImageFit.Cover)
        }
      }
      .width('100%')
      .padding(16)
      .backgroundColor('#FFFFFF')
      .borderRadius(12)
      .shadow({ radius: 8, color: 'rgba(0, 0, 0, 0.03)', offsetX: 0, offsetY: 2 })
      .onClick(() => {
        let params = new ArticleRouteParams();
        params.id = this.article.id;
        router.pushUrl({ url: 'pages/ArticleDetail', params: params }).catch((err: Error) => {
          console.error('跳转失败', err.message);
        });
      })
    }
    .swipeAction({ end: this.endBuilder })
  }
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

  doDeleteHistory(articleId: number) {
    deleteBrowseHistory(articleId).then(() => {
      this.browseHistory = this.browseHistory.filter((a: Article) => a.id !== articleId);
      promptAction.showToast({ message: '已删除' });
    }).catch(() => {
      promptAction.showToast({ message: '删除失败' });
    });
  }

  doClearHistory() {
    clearBrowseHistory().then(() => {
      this.browseHistory = [];
      promptAction.showToast({ message: '已清空浏览记录' });
    }).catch(() => {
      promptAction.showToast({ message: '清空失败' });
    });
  }

  build() {
    Column() {
      // --- 顶部导航栏：SpaceBetween 三栏布局 ---
      Row() {
        Text('< 返回')
          .fontSize(15)
          .fontColor('#409EFF')
          .onClick(() => {
            router.back();
          })

        Text(this.currentTab === 2 ? '浏览记录' : '个人中心')
          .fontSize(18)
          .fontWeight(FontWeight.Bold)
          .fontColor('#1A1A1A')

        if (this.currentTab === 2 && this.browseHistory.length > 0) {
          Text('清空')
            .fontSize(14)
            .fontColor('#FF4D4F')
            .onClick(() => {
              AlertDialog.show({
                title: '提示',
                message: '确认清空所有浏览记录？',
                primaryButton: {
                  value: '确认',
                  action: () => {
                    this.doClearHistory();
                  }
                },
                secondaryButton: { value: '取消', action: () => {} }
              });
            })
        } else {
          Text('  ')
            .fontSize(14)
        }
      }
      .width('100%')
      .height(56)
      .padding({ left: 16, right: 16 })
      .backgroundColor('#FFFFFF')
      .justifyContent(FlexAlign.SpaceBetween)
      .alignItems(VerticalAlign.Center)

      // --- 标签切换栏 ---
      Row({ space: 0 }) {
        ForEach(['我的喜欢', '我的评论', '浏览历史'], (title: string, index: number) => {
          Column() {
            Text(title)
              .fontSize(15)
              .fontColor(this.currentTab === index ? '#409EFF' : '#666666')
              .fontWeight(this.currentTab === index ? FontWeight.Medium : FontWeight.Normal)
            Divider()
              .width(24)
              .height(3)
              .backgroundColor(this.currentTab === index ? '#409EFF' : 'transparent')
              .borderRadius(2)
              .margin({ top: 6 })
          }
          .layoutWeight(1)
          .justifyContent(FlexAlign.Center)
          .height('100%')
          .onClick(() => this.onTabClick(index))
        })
      }
      .width('100%')
      .height(48)
      .backgroundColor('#FFFFFF')
      .border({ width: { bottom: 1 }, color: '#F0F0F0' })

      // --- 核心内容区 ---
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
        .justifyContent(FlexAlign.Center)
      } else if (this.currentTab === 0) {
        if (this.likedArticles.length === 0) {
          this.emptyState('暂无喜欢的文章')
        } else {
          List({ space: 12 }) {
            ForEach(this.likedArticles, (article: Article) => {
              ListItem() {
                this.articleCard(article)
              }
            }, (article: Article) => article.id.toString())
          }
          .width('100%')
          .layoutWeight(1)
          .padding({ left: 16, right: 16, top: 16 })
        }
      } else if (this.currentTab === 1) {
        if (this.userComments.length === 0) {
          this.emptyState('暂无评论')
        } else {
          List({ space: 12 }) {
            ForEach(this.userComments, (comment: Comment) => {
              ListItem() {
                this.commentCard(comment)
              }
            }, (comment: Comment) => comment.id.toString())
          }
          .width('100%')
          .layoutWeight(1)
          .padding({ left: 16, right: 16, top: 16 })
        }
      } else {
        if (this.browseHistory.length === 0) {
          this.emptyState('暂无浏览记录')
        } else {
          Text('共 ' + this.browseHistory.length + ' 条记录')
            .fontSize(13)
            .fontColor('#999999')
            .width('100%')
            .padding({ left: 16, top: 16, bottom: 8 })

          List({ space: 12 }) {
            ForEach(this.browseHistory, (article: Article) => {
              HistoryListItem({
                article: article,
                onDelete: (id: number) => {
                  this.doDeleteHistory(id);
                }
              })
            }, (article: Article) => article.id.toString())
          }
          .width('100%')
          .layoutWeight(1)
          .padding({ left: 16, right: 16 })
        }
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F8F8F8')
  }

  // --- 空状态 ---
  @Builder
  emptyState(message: string) {
    Column() {
      Text(message)
        .fontSize(14)
        .fontColor('#999999')
    }
    .width('100%')
    .layoutWeight(1)
    .justifyContent(FlexAlign.Center)
    .alignItems(HorizontalAlign.Center)
  }

  // --- 文章卡片（喜欢列表用） ---
  @Builder
  articleCard(article: Article) {
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
          Text((article.viewCount || 0) + '阅读')
            .fontSize(12)
            .fontColor('#999999')
          Text('·')
            .fontSize(12)
            .fontColor('#CCCCCC')
          Text((article.likeCount || 0) + '赞')
            .fontSize(12)
            .fontColor('#999999')
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
    .backgroundColor('#FFFFFF')
    .borderRadius(12)
    .shadow({ radius: 8, color: 'rgba(0, 0, 0, 0.03)', offsetX: 0, offsetY: 2 })
    .onClick(() => {
      let params = new ArticleRouteParams();
      params.id = article.id;
      router.pushUrl({ url: 'pages/ArticleDetail', params: params }).catch((err: Error) => {
        console.error('跳转失败', err.message);
      });
    })
  }

  // --- 评论卡片 ---
  @Builder
  commentCard(comment: Comment) {
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

      Text(comment.createTime ? comment.createTime.slice(0, 16) : '')
        .fontSize(12)
        .fontColor('#999999')
        .margin({ top: 12 })
    }
    .width('100%')
    .padding(16)
    .backgroundColor('#FFFFFF')
    .borderRadius(12)
    .alignItems(HorizontalAlign.Start)
    .shadow({ radius: 8, color: 'rgba(0, 0, 0, 0.03)', offsetX: 0, offsetY: 2 })
    .onClick(() => {
      let params = new ArticleRouteParams();
      params.id = comment.articleId;
      router.pushUrl({ url: 'pages/ArticleDetail', params: params }).catch((err: Error) => {
        console.error('跳转失败', err.message);
      });
    })
  }
}
