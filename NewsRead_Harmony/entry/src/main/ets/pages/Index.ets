import router from '@ohos.router';
import { getRecommendArticles, getArticleList, Article } from '../api/articleApi';
import { AuthUtil } from '../utils/AuthUtil';
import promptAction from '@ohos.promptAction';

// 显式声明 Banner 数据类
class BannerItem {
  id: number = 0;
  imageUrl: string = '';
  title: string = '';
  linkUrl: string = '';
}

// 显式声明路由参数类 (解决 params 匿名对象报错)
class ArticleRouteParams {
  id: number = 0;
}

@Entry
@Component
struct Index {
  @State articles: Article[] = [];
  @State banners: BannerItem[] = [];
  @State isRefreshing: boolean = false;
  @State isLoadingMore: boolean = false;
  @State pageNum: number = 1;
  @State hasMore: boolean = true;
  @State isLoading: boolean = true;
  @State isLoggedIn: boolean = false;
  @State avatarUrl: string = 'https://picsum.photos/id/1005/40/40';

  private scroller: Scroller = new Scroller();
  private swiperController: SwiperController = new SwiperController();

  aboutToAppear() {
    this.initAndLoad();
  }

  async initAndLoad() {
    await AuthUtil.restoreLogin();
    this.refreshLoginState();
    this.loadData();
  }

  refreshLoginState() {
    this.isLoggedIn = AuthUtil.isLoggedIn();
    if (this.isLoggedIn) {
      let user = AuthUtil.getUser();
      if (user && user.avatar) {
        this.avatarUrl = user.avatar;
      }
    }
  }

  onPageShow() {
    this.refreshLoginState();
  }

  async loadData() {
    this.isLoading = true;
    try {
      const bannerData = await getRecommendArticles(3);
      const bannerList: BannerItem[] = [];
      for (let i = 0; i < bannerData.length; i++) {
        const item = bannerData[i];
        // 显式创建 BannerItem 实例
        let banner = new BannerItem();
        banner.id = item.id;
        banner.imageUrl = item.coverImage || `https://picsum.photos/750/${400 + i}`;
        banner.title = item.title;
        banner.linkUrl = '';
        bannerList.push(banner);
      }
      this.banners = bannerList;

      const result = await getArticleList(undefined, 1, 10);
      this.articles = result.records || [];
      this.pageNum = 1;
      this.hasMore = (result.records?.length || 0) >= (result.pageSize || 10);
    } catch (e) {
      console.error('加载数据失败:', JSON.stringify(e));
    } finally {
      this.isLoading = false;
    }
  }

  async loadMore() {
    if (!this.hasMore || this.isLoadingMore) return;
    this.isLoadingMore = true;
    try {
      const result = await getArticleList(undefined, this.pageNum + 1, 10);
      const newArticles = this.articles.concat(result.records || []);
      this.articles = newArticles;
      this.pageNum++;
      this.hasMore = (result.records?.length || 0) >= (result.pageSize || 10);
    } catch (e) {
      console.error('加载更多失败:', JSON.stringify(e));
    } finally {
      this.isLoadingMore = false;
    }
  }

  onRefresh() {
    this.pageNum = 1;
    this.hasMore = true;
    this.loadData().then(() => {
      this.isRefreshing = false;
    });
  }

  build() {
    Column() {
      Row() {
        Text('NewsRead')
          .fontSize(24)
          .fontWeight(FontWeight.Bold)
          .fontColor('#1A1A1A')

        Blank()

        if (this.isLoggedIn) {
          Image(this.avatarUrl)
            .width(36)
            .height(36)
            .borderRadius(18)
            .border({ width: 1, color: '#E0E0E0' })
            .onClick(() => {
              router.pushUrl({ url: 'pages/ProfilePage' }).catch((err: Error) => {
                console.error(`跳转个人中心失败: ${err.message}`);
              });
            })
        } else {
          Text('登录')
            .fontSize(14)
            .fontColor('#409EFF')
            .onClick(() => {
              router.pushUrl({ url: 'pages/LoginPage' }).catch((err: Error) => {
                console.error(`跳转登录页失败: ${err.message}`);
              });
            })
        }
      }
      .width('100%')
      .justifyContent(FlexAlign.Center)
      .padding({ left: 20, right: 20, top: 12, bottom: 12 })

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
      } else {
        Refresh({ refreshing: this.isRefreshing, builder: () => this.refreshBuilder() }) {
          Scroll(this.scroller) {
            Column() {
              if (this.banners.length > 0) {
                Swiper(this.swiperController) {
                  ForEach(this.banners, (item: BannerItem) => {
                    Stack({ alignContent: Alignment.Bottom }) {
                      Image(item.imageUrl)
                        .width('100%')
                        .height(200)
                        .objectFit(ImageFit.Cover)
                      Column()
                        .width('100%')
                        .height(90)
                        .linearGradient({
                          direction: GradientDirection.Bottom,
                          colors: [['rgba(0,0,0,0)', 0], ['rgba(0,0,0,0.7)', 1]]
                        })
                      Text(item.title)
                        .fontSize(18)
                        .fontWeight(FontWeight.Medium)
                        .fontColor('#FFFFFF')
                        .position({ bottom: 20, left: 20 })
                        .maxLines(2)
                        .textOverflow({ overflow: TextOverflow.Ellipsis })
                    }
                    .onClick(() => {
                      if (item.id > 0) {
                        let routeParams = new ArticleRouteParams();
                        routeParams.id = item.id;
                        let options: router.RouterOptions = {
                          url: 'pages/ArticleDetail',
                          params: routeParams
                        };
                        router.pushUrl(options).catch((err: Error) => {
                          console.error(`跳转文章详情失败: ${err.message}`);
                        });
                      }
                    })
                  })
                }
                .autoPlay(true)
                .interval(4000)
                .loop(true)
                .margin({ bottom: 24 })
              }

              Row({ space: 12 }) {
                Text('推荐阅读')
                  .fontSize(20)
                  .fontWeight(600)
                  .fontColor('#1A1A1A')
                Blank()
                Text('更多 ›')
                  .fontSize(14)
                  .fontColor('#999999')
              }
              .width('100%')
              .padding({ left: 20, right: 20, bottom: 16 })
              .onClick(() => {
                router.pushUrl({ url: 'pages/CategoryPage' }).catch((err: Error) => {
                  console.error(`跳转分类页失败: ${err.message}`);
                });
              })

              Column() {
                ForEach(this.articles, (item: Article) => {
                  this.articleItemBuilder(item)
                })
              }
              .padding({ left: 20, right: 20 })

              if (this.hasMore) {
                Row() {
                  if (this.isLoadingMore) {
                    LoadingProgress()
                      .width(24)
                      .height(24)
                    Text('加载中...')
                      .fontSize(14)
                      .fontColor('#999999')
                      .margin({ left: 8 })
                  } else {
                    Text('上拉加载更多')
                      .fontSize(14)
                      .fontColor('#999999')
                  }
                }
                .padding({ top: 20, bottom: 20 })
                .justifyContent(FlexAlign.Center)
                .onClick(() => {
                  this.loadMore();
                })
              } else if (this.articles.length > 0) {
                Text('— 已加载全部 —')
                  .fontSize(14)
                  .fontColor('#CCCCCC')
                  .padding({ top: 30, bottom: 30 })
              }
            }
          }
          .scrollBar(BarState.Off)
          .onReachEnd(() => {
            this.loadMore();
          })
        }
        .onRefreshing(() => {
          this.onRefresh();
        })
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F8F8F8')
  }

  @Builder
  articleItemBuilder(item: Article) {
    Column() {
      Row({ space: 12 }) {
        Column() {
          Text(item.title)
            .fontSize(16)
            .fontWeight(FontWeight.Medium)
            .fontColor('#1A1A1A')
            .maxLines(2)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
            .margin({ bottom: 8 })

          Row({ space: 16 }) {
            Text(item.categoryId ? item.categoryId.toString() : '')
              .fontSize(12)
              .fontColor('#999999')

            Row({ space: 4 }) {
              Text(item.viewCount ? item.viewCount.toString() : '0')
                .fontSize(12)
                .fontColor('#999999')
            }

            Row({ space: 4 }) {
              Text(item.likeCount ? item.likeCount.toString() : '0')
                .fontSize(12)
                .fontColor('#999999')
            }
          }
        }
        .alignItems(HorizontalAlign.Start)
        .layoutWeight(1)

        if (item.coverImage) {
          Image(item.coverImage)
            .width(100)
            .height(70)
            .borderRadius(8)
            .objectFit(ImageFit.Cover)
        }
      }
      .width('100%')
      .padding({ top: 16, bottom: 16 })
    }
    .width('100%')
    .border({
      width: { bottom: 1 },
      color: '#F5F5F5'
    })
    .onClick(() => {
      let routeParams = new ArticleRouteParams();
      routeParams.id = item.id;

      let options: router.RouterOptions = {
        url: 'pages/ArticleDetail',
        params: routeParams
      };

      router.pushUrl(options).catch((err: Error) => {
        console.error(`跳转失败: ${err.message}`);
      });
    })
  }

  @Builder
  refreshBuilder() {
    Row() {
      LoadingProgress()
        .width(24)
        .height(24)
      Text('正在刷新...')
        .fontSize(14)
        .fontColor('#666666')
        .margin({ left: 8 })
    }
  }
}