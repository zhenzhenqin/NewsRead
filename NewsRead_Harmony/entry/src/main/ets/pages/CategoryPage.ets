import router from '@ohos.router';
import { getAllCategories, Category } from '../api/categoryApi';
import { getArticleList, Article } from '../api/articleApi';

class BannerItem {
  id: number = 0;
  imageUrl: string = '';
  title: string = '';
}

class ArticleRouteParams {
  id: number = 0;
}

@Entry
@Component
struct CategoryPage {
  @State categories: Category[] = [];
  @State selectedCategoryId: number | null = null;
  @State articles: Article[] = [];
  @State isLoading: boolean = true;
  @State isLoadingArticles: boolean = false;
  private scroller: Scroller = new Scroller();
  private swiperController: SwiperController = new SwiperController();

  aboutToAppear() {
    this.loadCategories();
  }

  async loadCategories() {
    this.isLoading = true;
    try {
      const data = await getAllCategories();
      this.categories = data || [];
      if (this.categories.length > 0) {
        this.selectedCategoryId = this.categories[0].id;
        this.loadArticlesByCategory(this.selectedCategoryId);
      }
    } catch (e) {
      console.error('加载分类失败:', e);
    } finally {
      this.isLoading = false;
    }
  }

  async loadArticlesByCategory(categoryId: number) {
    this.isLoadingArticles = true;
    try {
      const result = await getArticleList(categoryId, 1, 20);
      this.articles = result.records || [];
    } catch (e) {
      console.error('加载文章失败:', e);
    } finally {
      this.isLoadingArticles = false;
    }
  }

  onCategoryClick(categoryId: number) {
    this.selectedCategoryId = categoryId;
    this.loadArticlesByCategory(categoryId);
  }

  build() {
    Column() {
      Row() {
        Text('新闻资讯')
          .fontSize(20)
          .fontWeight(FontWeight.Bold)
          .fontColor('#1A1A1A')
        Blank()
        Text('< 返回')
          .fontSize(14)
          .fontColor('#409EFF')
          .onClick(() => {
            router.back();
          })
      }
      .width('100%')
      .padding({ left: 20, right: 20, top: 12, bottom: 12 })
      .backgroundColor('#FFFFFF')

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
        .width('100%')
        .layoutWeight(1)
        .justifyContent(FlexAlign.Center)
      } else {
        Row({ space: 0 }) {
          Column() {
            Text('分类')
              .fontSize(16)
              .fontWeight(FontWeight.Medium)
              .fontColor('#1A1A1A')
              .margin({ bottom: 12 })
              .padding({ left: 12 })

            ForEach(this.categories, (category: Category) => {
              Text(category.name)
                .fontSize(15)
                .fontColor(this.selectedCategoryId === category.id ? '#409EFF' : '#666666')
                .fontWeight(this.selectedCategoryId === category.id ? FontWeight.Medium : FontWeight.Normal)
                .padding({ left: 16, right: 16, top: 14, bottom: 14 })
                .width('100%')
                .backgroundColor(this.selectedCategoryId === category.id ? 'rgba(64,158,255,0.1)' : '#FFFFFF')
                .onClick(() => {
                  this.onCategoryClick(category.id);
                })
            })
          }
          .width('28%')
          .height('100%')
          .backgroundColor('#FFFFFF')
          .alignItems(HorizontalAlign.Start)

          Column() {
            if (this.isLoadingArticles) {
              Row() {
                LoadingProgress()
                  .width(24)
                  .height(24)
                Text('加载中...')
                  .fontSize(14)
                  .fontColor('#999999')
                  .margin({ left: 8 })
              }
              .width('100%')
              .justifyContent(FlexAlign.Center)
              .padding({ top: 40 })
            } else if (this.articles.length === 0) {
              Text('暂无文章')
                .fontSize(14)
                .fontColor('#999999')
                .width('100%')
                .padding({ top: 40 })
                .textAlign(TextAlign.Center)
            } else {
              Scroll(this.scroller) {
                Column() {
                  ForEach(this.articles, (article: Article) => {
                    this.articleItemBuilder(article)
                  })
                }
                .padding({ left: 12, right: 12, top: 12 })
              }
              .scrollBar(BarState.Off)
            }
          }
          .width('72%')
          .height('100%')
          .backgroundColor('#F8F8F8')
        }
        .width('100%')
        .layoutWeight(1)
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F8F8F8')
  }

  @Builder
  articleItemBuilder(article: Article) {
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
          
          Row({ space: 16 }) {
            Text(article.publishTime ? article.publishTime.slice(0, 10) : '')
              .fontSize(12)
              .fontColor('#999999')
            
            Row({ space: 4 }) {
              Text((article.viewCount || 0).toString())
                .fontSize(12)
                .fontColor('#999999')
            }
            
            Row({ space: 4 }) {
              Text((article.likeCount || 0).toString())
                .fontSize(12)
                .fontColor('#999999')
            }
          }
        }
        .alignItems(HorizontalAlign.Start)
        .layoutWeight(1)

        if (article.coverImage) {
          Image(article.coverImage)
            .width(80)
            .height(60)
            .borderRadius(6)
            .objectFit(ImageFit.Cover)
        }
      }
      .width('100%')
      .padding({ top: 14, bottom: 14 })
    }
    .width('100%')
    .backgroundColor('#FFFFFF')
    .borderRadius(8)
    .margin({ bottom: 10 })
    .onClick(() => {
      let routeParams = new ArticleRouteParams();
      routeParams.id = article.id;
      let options: router.RouterOptions = {
        url: 'pages/ArticleDetail',
        params: routeParams
      };
      router.pushUrl(options);
    })
  }
}