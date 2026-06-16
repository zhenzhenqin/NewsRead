import router from '@ohos.router';
import { getRecommendArticles, getArticleList, getFollowingFeed, Article } from '../api/articleApi';
import { AuthUtil } from '../utils/AuthUtil';
import promptAction from '@ohos.promptAction';

class BannerItem {
  id: number = 0;
  imageUrl: string = '';
  title: string = '';
  linkUrl: string = '';
}

class ArticleRouteParams {
  id: number = 0;
}

@Entry
@Component
struct Index {
  @State currentTabIndex: number = 0;
  // 推荐 Tab 数据
  @State articles: Article[] = [];
  @State banners: BannerItem[] = [];
  @State pageNum: number = 1;
  @State hasMore: boolean = true;
  // 关注 Tab 数据
  @State followingArticles: Article[] = [];
  @State followingPageNum: number = 1;
  @State followingHasMore: boolean = true;
  // 通用状态
  @State isRefreshing: boolean = false;
  @State isLoadingMore: boolean = false;
  @State isLoading: boolean = true;
  private isDataLoading: boolean = false;
  @State isLoggedIn: boolean = false;
  @State avatarUrl: string = 'https://picsum.photos/id/1005/40/40';

  private scroller: Scroller = new Scroller();
  private lastLoadMoreTime: number = 0;
  private swiperController: SwiperController = new SwiperController();

  aboutToAppear() {
    AuthUtil.restoreLogin().then(() => {
      this.refreshLoginState();
    });
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

  async onPageShow() {
    console.info('[Index] onPageShow 触发, currentTab=' + this.currentTabIndex);
    await AuthUtil.restoreLogin();
    this.refreshLoginState();
    if (this.currentTabIndex === 0) {
      await this.loadRecommendData();
    } else {
      await this.loadFollowingData();
    }
  }

  // ========== 推荐 Tab 数据加载 ==========
  async loadRecommendData() {
    if (this.isDataLoading) return;
    this.isDataLoading = true;
    this.isLoading = true;
    try {
      const bannerData = await getRecommendArticles(3);
      const bannerList: BannerItem[] = [];
      for (let i = 0; i < bannerData.length; i++) {
        const item = bannerData[i];
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
      this.hasMore = (result.records?.length || 0) >= 10;
    } catch (e) {
      console.error('[Index] 加载推荐数据失败:', JSON.stringify(e));
    } finally {
      this.isLoading = false;
      this.isDataLoading = false;
    }
  }

  async loadRecommendMore() {
    const now = Date.now();
    if (!this.hasMore || this.isLoadingMore || now - this.lastLoadMoreTime < 1500) return;
    this.isLoadingMore = true;
    this.lastLoadMoreTime = now;
    try {
      const result = await getArticleList(undefined, this.pageNum + 1, 10);
      this.articles = this.articles.concat(result.records || []);
      this.pageNum++;
      this.hasMore = (result.records?.length || 0) >= 10;
    } catch (e) {
      console.error('加载更多失败:', JSON.stringify(e));
    } finally {
      this.isLoadingMore = false;
    }
  }

  // ========== 关注 Tab 数据加载 ==========
  async loadFollowingData() {
    if (!this.isLoggedIn) {
      return;
    }
    this.isLoading = true;
    try {
      const result = await getFollowingFeed(1, 10);
      this.followingArticles = result.records || [];
      this.followingPageNum = 1;
      this.followingHasMore = (result.records?.length || 0) >= 10;
    } catch (e) {
      console.error('加载关注数据失败:', JSON.stringify(e));
    } finally {
      this.isLoading = false;
    }
  }

  async loadFollowingMore() {
    const now = Date.now();
    if (!this.followingHasMore || this.isLoadingMore || !this.isLoggedIn || now - this.lastLoadMoreTime < 1500) return;
    this.isLoadingMore = true;
    this.lastLoadMoreTime = now;
    try {
      const result = await getFollowingFeed(this.followingPageNum + 1, 10);
      this.followingArticles = this.followingArticles.concat(result.records || []);
      this.followingPageNum++;
      this.followingHasMore = (result.records?.length || 0) >= 10;
    } catch (e) {
      console.error('加载更多失败:', JSON.stringify(e));
    } finally {
      this.isLoadingMore = false;
    }
  }

  // ========== Tab 切换 ==========
  onTabChange(index: number) {
    this.currentTabIndex = index;
    if (index === 0 && this.articles.length === 0) {
      this.loadRecommendData();
    } else if (index === 1 && this.followingArticles.length === 0) {
      this.loadFollowingData();
    }
  }

  onRefresh() {
    if (this.currentTabIndex === 0) {
      this.pageNum = 1;
      this.hasMore = true;
      this.loadRecommendData().then(() => {
        this.isRefreshing = false;
      });
    } else {
      this.followingPageNum = 1;
      this.followingHasMore = true;
      this.loadFollowingData().then(() => {
        this.isRefreshing = false;
      });
    }
  }

  build() {
    Column() {
      // 顶部导航栏
      Row() {
        Text('NewsRead')
          .fontSize(24)
          .fontWeight(FontWeight.Bold)
          .fontColor('#1A1A1A')

        Blank()

        Text('\u{1F50D}')
          .fontSize(20)
          .margin({ right: 12 })
          .onClick(() => {
            router.pushUrl({ url: 'pages/SearchPage' }).catch((err: Error) => {
              console.error(`跳转搜索页失败: ${err.message}`);
            });
          })

        Text('\u{1F916}')
          .fontSize(20)
          .margin({ right: 12 })
          .onClick(() => {
            router.pushUrl({ url: 'pages/AiChatPage' }).catch((err: Error) => {
              console.error(`跳转AI助手失败: ${err.message}`);
            });
          })

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

      // Tab 切换栏
      Row({ space: 0 }) {
        ForEach(['推荐', '关注'], (title: string, index: number) => {
          Column() {
            Text(title)
              .fontSize(16)
              .fontColor(this.currentTabIndex === index ? '#1A1A1A' : '#999999')
              .fontWeight(this.currentTabIndex === index ? FontWeight.Bold : FontWeight.Normal)
            Divider()
              .width(24)
              .height(3)
              .backgroundColor(this.currentTabIndex === index ? '#409EFF' : 'transparent')
              .borderRadius(2)
              .margin({ top: 6 })
          }
          .layoutWeight(1)
          .justifyContent(FlexAlign.Center)
          .height(48)
          .onClick(() => this.onTabChange(index))
        })
      }
      .width('100%')
      .backgroundColor('#FFFFFF')
      .border({ width: { bottom: 1 }, color: '#F0F0F0' })

      // Tab 内容区
      if (this.currentTabIndex === 0) {
        this.recommendTabBuilder()
      } else {
        this.followingTabBuilder()
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F8F8F8')
  }

  // ========== 推荐 Tab 内容 ==========
  @Builder
  recommendTabBuilder() {
    Refresh({ refreshing: this.isRefreshing, builder: () => this.refreshBuilder() }) {
      Scroll(this.scroller) {
        Column() {
          if (this.isLoading && this.articles.length === 0) {
            Column() {
              LoadingProgress().width(32).height(32)
              Text('正在加载精彩内容...')
                .fontSize(14)
                .fontColor('#999999')
                .margin({ top: 12 })
            }
            .width('100%')
            .justifyContent(FlexAlign.Center)
            .padding({ top: 80, bottom: 80 })
          }

          if (!this.isLoading && this.articles.length === 0) {
            Column() {
              Text('\u{1F4F0}')
                .fontSize(48)
              Text('暂无文章')
                .fontSize(16)
                .fontColor('#999999')
                .margin({ top: 12 })
              Text('下拉刷新试试')
                .fontSize(13)
                .fontColor('#CCCCCC')
                .margin({ top: 6 })
            }
            .width('100%')
            .justifyContent(FlexAlign.Center)
            .padding({ top: 60, bottom: 60 })
          }

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
                    .height(100)
                    .linearGradient({
                      direction: GradientDirection.Bottom,
                      colors: [['rgba(0,0,0,0)', 0], ['rgba(0,0,0,0.7)', 1]]
                    })
                  Text(item.title)
                    .fontSize(18)
                    .fontWeight(FontWeight.Bold)
                    .fontColor('#FFFFFF')
                    .position({ bottom: 16, left: 16, right: 16 })
                    .maxLines(2)
                    .textOverflow({ overflow: TextOverflow.Ellipsis })
                }
                .borderRadius(12)
                .clip(true)
                .onClick(() => {
                  if (item.id > 0) {
                    let routeParams = new ArticleRouteParams();
                    routeParams.id = item.id;
                    router.pushUrl({ url: 'pages/ArticleDetail', params: routeParams });
                  }
                })
              })
            }
            .autoPlay(true)
            .interval(4000)
            .loop(true)
            .indicator(Indicator.dot()
              .color('#FFFFFF80')
              .selectedColor('#FFFFFF'))
            .margin({ left: 20, right: 20, bottom: 20 })
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
            router.pushUrl({ url: 'pages/CategoryPage' });
          })

          Column() {
            ForEach(this.articles, (item: Article) => {
              this.articleItemBuilder(item)
            })
          }
          .padding({ left: 20, right: 20 })

          this.loadMoreBuilder(this.hasMore, this.articles.length > 0)
        }
      }
      .scrollBar(BarState.Off)
      .onReachEnd(() => {
        this.loadRecommendMore();
      })
    }
    .onRefreshing(() => {
      this.onRefresh();
    })
  }

  // ========== 关注 Tab 内容 ==========
  @Builder
  followingTabBuilder() {
    if (!this.isLoggedIn) {
      Column() {
        Text('登录后查看关注动态')
          .fontSize(14)
          .fontColor('#999999')
        Text('去登录')
          .fontSize(14)
          .fontColor('#409EFF')
          .margin({ top: 12 })
          .onClick(() => {
            router.pushUrl({ url: 'pages/LoginPage' });
          })
      }
      .width('100%')
      .layoutWeight(1)
      .justifyContent(FlexAlign.Center)
    } else if (this.followingArticles.length === 0) {
      Column() {
        Text('暂无关注动态')
          .fontSize(14)
          .fontColor('#999999')
        Text('去关注感兴趣的人吧')
          .fontSize(13)
          .fontColor('#CCCCCC')
          .margin({ top: 8 })
      }
      .width('100%')
      .layoutWeight(1)
      .justifyContent(FlexAlign.Center)
    } else {
      Refresh({ refreshing: this.isRefreshing, builder: () => this.refreshBuilder() }) {
        Scroll() {
          Column() {
            Column() {
              ForEach(this.followingArticles, (item: Article) => {
                this.articleItemBuilder(item)
              })
            }
            .padding({ left: 20, right: 20 })

            this.loadMoreBuilder(this.followingHasMore, this.followingArticles.length > 0)
          }
        }
        .scrollBar(BarState.Off)
        .onReachEnd(() => {
          this.loadFollowingMore();
        })
      }
      .onRefreshing(() => {
        this.onRefresh();
      })
    }
  }

  // ========== 文章卡片 ==========
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
            .margin({ bottom: 10 })

          Row({ space: 16 }) {
            if (item.categoryId) {
              Text(item.categoryId.toString())
                .fontSize(11)
                .fontColor('#409EFF')
                .backgroundColor('#EBF5FF')
                .borderRadius(4)
                .padding({ left: 6, right: 6, top: 2, bottom: 2 })
            }

            Row({ space: 4 }) {
              Text('\u{1F441}')
                .fontSize(11)
              Text(item.viewCount ? item.viewCount.toString() : '0')
                .fontSize(11)
                .fontColor('#999999')
            }

            Row({ space: 4 }) {
              Text('\u2764')
                .fontSize(11)
                .fontColor('#FF6B6B')
              Text(item.likeCount ? item.likeCount.toString() : '0')
                .fontSize(11)
                .fontColor('#999999')
            }
          }
        }
        .alignItems(HorizontalAlign.Start)
        .layoutWeight(1)

        if (item.coverImage) {
          Image(item.coverImage)
            .width(110)
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
    .shadow({
      radius: 8,
      color: 'rgba(0,0,0,0.06)',
      offsetX: 0,
      offsetY: 2
    })
    .onClick(() => {
      let routeParams = new ArticleRouteParams();
      routeParams.id = item.id;
      router.pushUrl({ url: 'pages/ArticleDetail', params: routeParams });
    })
  }

  // ========== 加载更多 ==========
  @Builder
  loadMoreBuilder(hasMore: boolean, hasData: boolean) {
    if (hasMore) {
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
        if (this.currentTabIndex === 0) {
          this.loadRecommendMore();
        } else {
          this.loadFollowingMore();
        }
      })
    } else if (hasData) {
      Text('— 已加载全部 —')
        .fontSize(14)
        .fontColor('#CCCCCC')
        .padding({ top: 30, bottom: 30 })
    }
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
