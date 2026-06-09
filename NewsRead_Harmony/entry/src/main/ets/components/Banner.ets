@Component
export struct Banner {
  @Prop bannerList: BannerItem[] = [];
  @State currentIndex: number = 0;
  private swiperController: SwiperController = new SwiperController();

  build() {
    Swiper(this.swiperController) {
      ForEach(this.bannerList, (item: BannerItem) => {
        Stack({ alignContent: Alignment.Bottom }) {
          Image(item.imageUrl)
            .width('100%')
            .height('100%')
            .objectFit(ImageFit.Cover)
          Column()
            .width('100%')
            .height(80)
            .linearGradient({
              direction: GradientDirection.Bottom,
              colors: [['rgba(0,0,0,0)', 0], ['rgba(0,0,0,0.6)', 1]]
            })
          Text(item.title)
            .fontSize(18)
            .fontWeight(FontWeight.Medium)
            .fontColor('#FFFFFF')
            .position({ bottom: 20, left: 16 })
            .maxLines(2)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
        }
        .width('100%')
        .height(200)
      })
    }
    .autoPlay(true)
    .interval(4000)
    .indicator(this.currentIndex)
    .loop(true)
    .onChange((index: number) => {
      this.currentIndex = index;
    })
    .margin({ bottom: 24 })
  }
}

interface BannerItem {
  id: number;
  imageUrl: string;
  title: string;
  linkUrl: string;
}