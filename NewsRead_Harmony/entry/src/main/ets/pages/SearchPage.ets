import router from '@ohos.router';
import { searchArticles, getHotKeywords, getMySearchHistory, HotKeyword, Article, PageResult } from '../api/searchApi';
import promptAction from '@ohos.promptAction';

class ArticleRouteParams {
  id: number = 0;
}

@Entry
@Component
struct SearchPage {
  @State searchKeyword: string = '';
  @State hotKeywords: HotKeyword[] = [];
  @State searchHistory: string[] = [];
  @State searchResults: Article[] = [];
  @State isSearching: boolean = false;
  @State isLoading: boolean = false;
  @State pageNum: number = 1;
  @State hasMore: boolean = true;
  @State total: number = 0;
  @State showResult: boolean = false;

  aboutToAppear() {
    this.loadInitData();
  }

  async loadInitData() {
    try {
      const hot = await getHotKeywords();
      const history = await getMySearchHistory();
      this.hotKeywords = hot || [];
      this.searchHistory = history || [];
    } catch (e) {
      console.error('加载搜索数据失败:', JSON.stringify(e));
    }
  }

  async doSearch(keyword: string) {
    const kw = keyword.trim();
    if (!kw) {
      return;
    }
    this.searchKeyword = kw;
    this.showResult = true;
    this.isLoading = true;
    this.pageNum = 1;
    this.hasMore = true;
    try {
      const result = await searchArticles(kw, 1, 10);
      this.searchResults = result.records || [];
      this.total = result.total || 0;
      this.hasMore = (result.records?.length || 0) >= 10;
    } catch (e) {
      console.error('搜索失败:', JSON.stringify(e));
      promptAction.showToast({ message: '搜索失败' });
    } finally {
      this.isLoading = false;
    }
    // 刷新搜索历史
    this.refreshHistory();
  }

  async refreshHistory() {
    try {
      this.searchHistory = await getMySearchHistory() || [];
    } catch (e) {
      // ignore
    }
  }

  async loadMore() {
    if (!this.hasMore || this.isLoading) {
      return;
    }
    this.isLoading = true;
    try {
      const result = await searchArticles(this.searchKeyword, this.pageNum + 1, 10);
      this.searchResults = this.searchResults.concat(result.records || []);
      this.pageNum++;
      this.hasMore = (result.records?.length || 0) >= 10;
    } catch (e) {
      console.error('加载更多失败:', JSON.stringify(e));
    } finally {
      this.isLoading = false;
    }
  }

  goBack() {
    if (this.showResult) {
      this.showResult = false;
      this.searchResults = [];
      this.searchKeyword = '';
      this.loadInitData();
    } else {
      router.back();
    }
  }

  build() {
    Column() {
      // 顶部搜索栏
      Row() {
        Text('\u2190')
          .fontSize(22)
          .fontColor('#333333')
          .onClick(() => {
            this.goBack();
          })

        TextInput({ placeholder: '搜索文章...', text: this.searchKeyword })
          .layoutWeight(1)
          .height(36)
          .backgroundColor('#F5F5F5')
          .borderRadius(18)
          .padding({ left: 16, right: 16 })
          .fontSize(14)
          .margin({ left: 12, right: 8 })
          .onChange((value: string) => {
            this.searchKeyword = value;
          })
          .onSubmit(() => {
            this.doSearch(this.searchKeyword);
          })

        Text('搜索')
          .fontSize(14)
          .fontColor('#409EFF')
          .onClick(() => {
            this.doSearch(this.searchKeyword);
          })
      }
      .width('100%')
      .padding({ left: 16, right: 16, top: 12, bottom: 12 })
      .backgroundColor('#FFFFFF')

      if (this.showResult) {
        // 搜索结果视图
        this.searchResultView()
      } else {
        // 热词 + 历史视图
        this.searchHomeView()
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F8F8F8')
  }

  @Builder
  searchHomeView() {
    Column() {
      // 搜索热词
      if (this.hotKeywords.length > 0) {
        Column() {
          Row() {
            Text('搜索热词')
              .fontSize(16)
              .fontWeight(FontWeight.Medium)
              .fontColor('#1A1A1A')
          }
          .width('100%')
          .margin({ bottom: 12 })

          Flex({ wrap: FlexWrap.Wrap }) {
            ForEach(this.hotKeywords, (item: HotKeyword) => {
              Text(item.keyword)
                .fontSize(13)
                .fontColor('#666666')
                .backgroundColor('#F0F0F0')
                .borderRadius(16)
                .padding({ left: 14, right: 14, top: 6, bottom: 6 })
                .margin({ right: 8, bottom: 8 })
                .onClick(() => {
                  this.doSearch(item.keyword);
                })
            })
          }
          .width('100%')
        }
        .width('100%')
        .padding(16)
        .backgroundColor('#FFFFFF')
        .borderRadius(12)
        .margin({ left: 16, right: 16, top: 16 })
      }

      // 搜索历史
      if (this.searchHistory.length > 0) {
        Column() {
          Row() {
            Text('搜索历史')
              .fontSize(16)
              .fontWeight(FontWeight.Medium)
              .fontColor('#1A1A1A')
            Blank()
            Text('清除')
              .fontSize(13)
              .fontColor('#999999')
              .onClick(() => {
                this.searchHistory = [];
              })
          }
          .width('100%')
          .margin({ bottom: 12 })

          Flex({ wrap: FlexWrap.Wrap }) {
            ForEach(this.searchHistory, (item: string) => {
              Text(item)
                .fontSize(13)
                .fontColor('#666666')
                .backgroundColor('#F0F0F0')
                .borderRadius(16)
                .padding({ left: 14, right: 14, top: 6, bottom: 6 })
                .margin({ right: 8, bottom: 8 })
                .onClick(() => {
                  this.doSearch(item);
                })
            })
          }
          .width('100%')
        }
        .width('100%')
        .padding(16)
        .backgroundColor('#FFFFFF')
        .borderRadius(12)
        .margin({ left: 16, right: 16, top: 12 })
      }

      // 无数据提示
      if (this.hotKeywords.length === 0 && this.searchHistory.length === 0) {
        Column() {
          Text('暂无搜索数据')
            .fontSize(14)
            .fontColor('#999999')
        }
        .width('100%')
        .justifyContent(FlexAlign.Center)
        .margin({ top: 100 })
      }

      Blank()
    }
    .width('100%')
    .height('100%')
    .alignItems(HorizontalAlign.Start)
    .backgroundColor('#F8F8F8')
  }

  @Builder
  searchResultView() {
    Column() {
      // 结果统计
      Row() {
        Text('找到 ' + this.total.toString() + ' 条相关文章')
          .fontSize(13)
          .fontColor('#999999')
      }
      .width('100%')
      .padding({ left: 16, right: 16, top: 12, bottom: 8 })

      if (this.isLoading && this.searchResults.length === 0) {
        Column() {
          LoadingProgress()
            .width(32)
            .height(32)
          Text('搜索中...')
            .fontSize(14)
            .fontColor('#999999')
            .margin({ top: 8 })
        }
        .width('100%')
        .justifyContent(FlexAlign.Center)
        .layoutWeight(1)
      } else if (this.searchResults.length === 0) {
        Column() {
          Text('未找到相关文章')
            .fontSize(14)
            .fontColor('#999999')
          Text('换个关键词试试')
            .fontSize(13)
            .fontColor('#CCCCCC')
            .margin({ top: 8 })
        }
        .width('100%')
        .justifyContent(FlexAlign.Center)
        .layoutWeight(1)
      } else {
        List() {
          ForEach(this.searchResults, (item: Article) => {
            ListItem() {
              this.articleItemBuilder(item)
            }
          })

          if (this.hasMore) {
            ListItem() {
              Row() {
                if (this.isLoading) {
                  LoadingProgress()
                    .width(20)
                    .height(20)
                  Text('加载中...')
                    .fontSize(13)
                    .fontColor('#999999')
                    .margin({ left: 8 })
                } else {
                  Text('加载更多')
                    .fontSize(13)
                    .fontColor('#999999')
                }
              }
              .width('100%')
              .justifyContent(FlexAlign.Center)
              .padding({ top: 16, bottom: 16 })
              .onClick(() => {
                this.loadMore();
              })
            }
          } else if (this.searchResults.length > 0) {
            ListItem() {
              Text('— 已加载全部 —')
                .fontSize(13)
                .fontColor('#CCCCCC')
                .width('100%')
                .textAlign(TextAlign.Center)
                .padding({ top: 20, bottom: 20 })
            }
          }
        }
        .layoutWeight(1)
        .scrollBar(BarState.Off)
        .edgeEffect(EdgeEffect.Spring)
        .onReachEnd(() => {
          this.loadMore();
        })
      }
    }
  }

  @Builder
  articleItemBuilder(item: Article) {
    Column() {
      Row({ space: 12 }) {
        Column() {
          Text(item.title)
            .fontSize(15)
            .fontWeight(FontWeight.Medium)
            .fontColor('#1A1A1A')
            .maxLines(2)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
            .margin({ bottom: 6 })

          if (item.summary) {
            Text(item.summary)
              .fontSize(13)
              .fontColor('#999999')
              .maxLines(2)
              .textOverflow({ overflow: TextOverflow.Ellipsis })
              .margin({ bottom: 6 })
          }

          Row({ space: 12 }) {
            Text(item.viewCount ? item.viewCount.toString() + '阅读' : '0阅读')
              .fontSize(12)
              .fontColor('#BBBBBB')
            Text(item.likeCount ? item.likeCount.toString() + '赞' : '0赞')
              .fontSize(12)
              .fontColor('#BBBBBB')
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
      .padding({ top: 14, bottom: 14 })
    }
    .width('100%')
    .padding({ left: 16, right: 16 })
    .backgroundColor('#FFFFFF')
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
        console.error(`跳转文章详情失败: ${err.message}`);
      });
    })
  }
}
