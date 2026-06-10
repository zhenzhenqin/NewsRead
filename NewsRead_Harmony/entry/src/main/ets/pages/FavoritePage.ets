import router from '@ohos.router';
import { getFavoriteList, removeFavorite, FavoriteItem } from '../api/favoriteApi';
import { getArticleDetail, Article } from '../api/articleApi';
import { AuthUtil } from '../utils/AuthUtil';
import promptAction from '@ohos.promptAction';

class ArticleRouteParams {
  id: number = 0;
}

// --- 收藏列表项（独立组件，支持原生 swipeAction） ---
@Observed
@Component
struct FavoriteListItem {
  @ObjectLink article: Article;
  onDelete: (id: number) => void = () => {};

  @Builder
  endBuilder() {
    Row() {
      Text('取消收藏')
        .fontSize(14)
        .fontColor('#FFFFFF')
    }
    .width(100)
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
          Row() {
            Text('★')
              .fontSize(14)
              .fontColor('#FFA500')
              .margin({ right: 6 })
            Text(this.article.title)
              .fontSize(16)
              .fontWeight(FontWeight.Medium)
              .fontColor('#1A1A1A')
              .maxLines(2)
              .textOverflow({ overflow: TextOverflow.Ellipsis })
              .layoutWeight(1)
          }
          .width('100%')
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
        router.pushUrl({ url: 'pages/ArticleDetail', params: params });
      })
    }
    .swipeAction({ end: this.endBuilder })
  }
}

@Entry
@Component
struct FavoritePage {
  @State articles: Article[] = [];
  @State isLoading: boolean = true;
  @State isLoggedIn: boolean = false;

  async aboutToAppear() {
    const loggedIn = await AuthUtil.restoreLogin();
    this.isLoggedIn = loggedIn;
    if (!this.isLoggedIn) {
      promptAction.showToast({ message: '请先登录' });
      router.back();
      return;
    }
    this.loadFavorites();
  }

  // 页面重新显示时刷新（从 ArticleDetail 返回时同步星星状态）
  onPageShow() {
    if (this.isLoggedIn) {
      this.loadFavorites();
    }
  }

  async loadFavorites() {
    this.isLoading = true;
    try {
      const favorites = await getFavoriteList();
      if (favorites.length === 0) {
        this.articles = [];
        return;
      }
      const promises = favorites.map((fav: FavoriteItem) =>
        getArticleDetail(fav.articleId).catch(() => null)
      );
      const results = await Promise.all(promises);
      this.articles = results.filter((a: Article | null) => a !== null) as Article[];
    } catch (e) {
      console.error('加载收藏失败:', JSON.stringify(e));
    } finally {
      this.isLoading = false;
    }
  }

  doRemoveFavorite(articleId: number) {
    removeFavorite(articleId).then(() => {
      this.articles = this.articles.filter((a: Article) => a.id !== articleId);
      promptAction.showToast({ message: '已取消收藏' });
    }).catch(() => {
      promptAction.showToast({ message: '操作失败' });
    });
  }

  build() {
    Column() {
      // 顶部导航栏
      Row() {
        Text('< 返回')
          .fontSize(15)
          .fontColor('#409EFF')
          .onClick(() => {
            router.back();
          })

        Text('我的收藏')
          .fontSize(18)
          .fontWeight(FontWeight.Bold)
          .fontColor('#1A1A1A')

        Text('  ')
          .fontSize(14)
      }
      .width('100%')
      .height(56)
      .padding({ left: 16, right: 16 })
      .backgroundColor('#FFFFFF')
      .justifyContent(FlexAlign.SpaceBetween)
      .alignItems(VerticalAlign.Center)

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
      } else if (this.articles.length === 0) {
        Column() {
          Text('暂无收藏')
            .fontSize(14)
            .fontColor('#999999')
        }
        .width('100%')
        .layoutWeight(1)
        .justifyContent(FlexAlign.Center)
      } else {
        Text('共 ' + this.articles.length + ' 篇（左滑可取消收藏）')
          .fontSize(13)
          .fontColor('#999999')
          .width('100%')
          .padding({ left: 16, top: 16, bottom: 8 })

        List({ space: 12 }) {
          ForEach(this.articles, (article: Article) => {
            FavoriteListItem({
              article: article,
              onDelete: (id: number) => {
                this.doRemoveFavorite(id);
              }
            })
          }, (article: Article) => article.id.toString())
        }
        .width('100%')
        .layoutWeight(1)
        .padding({ left: 16, right: 16 })
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F8F8F8')
  }
}
