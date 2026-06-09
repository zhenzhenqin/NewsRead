import router from '@ohos.router';

@Component
export struct NewsListItem {
  @Prop article: ArticleItem = {
    id: 0,
    title: '',
    summary: '',
    coverImage: '',
    categoryId: 0,
    categoryName: '',
    viewCount: 0,
    likeCount: 0,
    publishTime: ''
  };

  build() {
    Row({ space: 12 }) {
      Column() {
        Text(this.article.title)
          .fontSize(16)
          .fontWeight(FontWeight.Medium)
          .fontColor('#1A1A1A')
          .maxLines(2)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
          .margin({ bottom: 8 })
        
        Row({ space: 16 }) {
          Text(this.article.categoryName)
            .fontSize(12)
            .fontColor('#999999')
          
          Row({ space: 4 }) {
            Text(this.article.viewCount.toString())
              .fontSize(12)
              .fontColor('#999999')
          }
          
          Row({ space: 4 }) {
            Text(this.article.likeCount.toString())
              .fontSize(12)
              .fontColor('#999999')
          }
        }
      }
      .alignItems(HorizontalAlign.Start)
      .layoutWeight(1)

      if (this.article.coverImage) {
        Image(this.article.coverImage)
          .width(100)
          .height(70)
          .borderRadius(8)
          .objectFit(ImageFit.Cover)
      }
    }
    .width('100%')
    .padding({ top: 16, bottom: 16 })
    .border({
      width: { bottom: 1 },
      color: '#F5F5F5'
    })
    .onClick(() => {
      router.pushUrl({ url: 'pages/ArticleDetail', params: { id: this.article.id } });
    })
  }
}

interface ArticleItem {
  id: number;
  title: string;
  summary: string;
  coverImage: string;
  categoryId: number;
  categoryName: string;
  viewCount: number;
  likeCount: number;
  publishTime: string;
}