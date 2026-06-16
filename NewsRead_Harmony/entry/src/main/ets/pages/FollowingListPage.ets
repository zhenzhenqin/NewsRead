import router from '@ohos.router';
import { getFollowingList, toggleFollow, FollowUser, FollowPageResult } from '../api/followApi';
import { AuthUtil } from '../utils/AuthUtil';
import promptAction from '@ohos.promptAction';

@Entry
@Component
struct FollowingListPage {
  @State followList: FollowUser[] = [];
  @State isLoading: boolean = false;
  @State pageNum: number = 1;
  @State hasMore: boolean = true;
  @State total: number = 0;

  async aboutToAppear() {
    await AuthUtil.restoreLogin();
    if (!AuthUtil.isLoggedIn()) {
      promptAction.showToast({ message: '请先登录' });
      router.back();
      return;
    }
    this.loadData();
  }

  async loadData() {
    this.isLoading = true;
    this.pageNum = 1;
    try {
      const result = await getFollowingList(1, 20);
      this.followList = result.records || [];
      this.total = result.total || 0;
      this.hasMore = (result.records?.length || 0) >= 20;
    } catch (e) {
      console.error('加载关注列表失败:', JSON.stringify(e));
    } finally {
      this.isLoading = false;
    }
  }

  async loadMore() {
    if (!this.hasMore || this.isLoading) {
      return;
    }
    this.isLoading = true;
    try {
      const result = await getFollowingList(this.pageNum + 1, 20);
      this.followList = this.followList.concat(result.records || []);
      this.pageNum++;
      this.hasMore = (result.records?.length || 0) >= 20;
    } catch (e) {
      console.error('加载更多失败:', JSON.stringify(e));
    } finally {
      this.isLoading = false;
    }
  }

  async doUnfollow(user: FollowUser) {
    try {
      const nowFollowing = await toggleFollow(user.id);
      if (!nowFollowing) {
        this.followList = this.followList.filter((u: FollowUser) => u.id !== user.id);
        this.total--;
        promptAction.showToast({ message: '已取消关注' });
      }
    } catch (e) {
      promptAction.showToast({ message: '操作失败' });
    }
  }

  showUnfollowDialog(user: FollowUser) {
    AlertDialog.show({
      title: '提示',
      message: '确认取消关注 ' + (user.nickname || user.username) + '？',
      primaryButton: {
        value: '确认',
        action: () => {
          this.doUnfollow(user);
        }
      },
      secondaryButton: {
        value: '取消',
        action: () => {
        }
      }
    });
  }

  build() {
    Column() {
      Row() {
        Text('< 返回')
          .fontSize(15)
          .fontColor('#409EFF')
          .onClick(() => {
            router.back();
          })
        Text('我的关注')
          .fontSize(18)
          .fontWeight(FontWeight.Bold)
          .fontColor('#1A1A1A')
        Text(this.total > 0 ? this.total + '人' : ' ')
          .fontSize(13)
          .fontColor('#999999')
      }
      .width('100%')
      .height(56)
      .padding({ left: 16, right: 16 })
      .backgroundColor('#FFFFFF')
      .justifyContent(FlexAlign.SpaceBetween)
      .alignItems(VerticalAlign.Center)

      if (this.isLoading && this.followList.length === 0) {
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
      } else if (this.followList.length === 0) {
        Column() {
          Text('暂无关注')
            .fontSize(14)
            .fontColor('#999999')
        }
        .width('100%')
        .layoutWeight(1)
        .justifyContent(FlexAlign.Center)
      } else {
        List({ space: 0 }) {
          ForEach(this.followList, (user: FollowUser) => {
            ListItem() {
              Row({ space: 12 }) {
                Image(user.avatar || 'https://picsum.photos/id/1005/40/40')
                  .width(48)
                  .height(48)
                  .borderRadius(24)

                Column() {
                  Text(user.nickname || user.username)
                    .fontSize(16)
                    .fontWeight(FontWeight.Medium)
                    .fontColor('#1A1A1A')
                    .maxLines(1)
                    .textOverflow({ overflow: TextOverflow.Ellipsis })
                  Text('@' + user.username)
                    .fontSize(13)
                    .fontColor('#999999')
                    .margin({ top: 4 })
                }
                .alignItems(HorizontalAlign.Start)
                .layoutWeight(1)

                Text('取消关注')
                  .fontSize(13)
                  .fontColor('#999999')
                  .backgroundColor('#F5F5F5')
                  .borderRadius(16)
                  .padding({ left: 14, right: 14, top: 6, bottom: 6 })
                  .onClick(() => {
                    this.showUnfollowDialog(user);
                  })
              }
              .width('100%')
              .padding({ left: 16, right: 16, top: 14, bottom: 14 })
              .backgroundColor('#FFFFFF')
              .border({ width: { bottom: 1 }, color: '#F5F5F5' })
              .onClick(() => {
                let params: Record<string, Object> = {};
                params['userId'] = user.id;
                params['nickname'] = user.nickname || user.username;
                router.pushUrl({ url: 'pages/ProfileDetailPage', params: params });
              })
            }
          })
        }
        .layoutWeight(1)
        .scrollBar(BarState.Off)
        .edgeEffect(EdgeEffect.Spring)
        .onReachEnd(() => {
          this.loadMore();
        })

        if (this.hasMore) {
          Row() {
            if (this.isLoading) {
              LoadingProgress().width(20).height(20)
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
          .backgroundColor('#FFFFFF')
          .onClick(() => {
            this.loadMore();
          })
        }
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F8F8F8')
  }
}
