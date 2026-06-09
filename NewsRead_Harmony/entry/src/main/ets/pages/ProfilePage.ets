import router from '@ohos.router';
import { AuthUtil } from '../utils/AuthUtil';
import { logout } from '../api/userApi';
import promptAction from '@ohos.promptAction';

@Entry
@Component
struct ProfilePage {
  @State nickname: string = '';
  @State avatarUrl: string = '';
  @State username: string = '';
  @State email: string = '';
  @State phone: string = '';
  @State isLoading: boolean = false;

  async aboutToAppear() {
    console.info('[AUTH] ProfilePage.aboutToAppear: start');
    await AuthUtil.restoreLogin();
    console.info('[AUTH] ProfilePage.aboutToAppear: isLoggedIn=' + AuthUtil.isLoggedIn());
    this.loadUserInfo();
  }

  loadUserInfo() {
    let user = AuthUtil.getUser();
    if (user) {
      this.nickname = user.nickname || '用户';
      this.avatarUrl = user.avatar || 'https://picsum.photos/id/1005/200/200';
      this.username = user.username || '';
      this.email = user.email || '未设置';
      this.phone = user.phone || '未设置';
    }
  }

  async doLogout() {
    this.isLoading = true;
    try {
      await logout();
      promptAction.showToast({ message: '已退出登录' });
      router.back();
    } catch (e) {
      promptAction.showToast({ message: '退出失败' });
    } finally {
      this.isLoading = false;
    }
  }

  build() {
    Column() {
      Row() {
        Text('< 返回')
          .fontSize(16)
          .fontColor('#409EFF')
          .onClick(() => {
            router.back();
          })
      }
      .width('100%')
      .padding(20)
      .justifyContent(FlexAlign.Start)

      Column({ space: 16 }) {
        Image(this.avatarUrl)
          .width(80)
          .height(80)
          .borderRadius(40)
          .border({ width: 2, color: '#409EFF' })
          .margin({ top: 20 })

        Text(this.nickname)
          .fontSize(22)
          .fontWeight(FontWeight.Bold)
          .fontColor('#1A1A1A')
          .margin({ top: 12 })

        Text('@' + this.username)
          .fontSize(14)
          .fontColor('#999999')
      }
      .width('100%')
      .padding({ bottom: 30 })

      Column({ space: 0 }) {
        Row() {
          Text('个人主页')
            .fontSize(16)
            .fontColor('#1A1A1A')
          Blank()
          Text('›')
            .fontSize(18)
            .fontColor('#CCCCCC')
        }
        .width('100%')
        .padding(20)
        .backgroundColor('#FFFFFF')
        .onClick(() => {
          router.pushUrl({ url: 'pages/ProfileDetailPage' });
        })

        Divider()
          .margin({ left: 20 })

        Row() {
          Text('修改密码')
            .fontSize(16)
            .fontColor('#1A1A1A')
          Blank()
          Text('›')
            .fontSize(18)
            .fontColor('#CCCCCC')
        }
        .width('100%')
        .padding(20)
        .backgroundColor('#FFFFFF')
        .onClick(() => {
          router.pushUrl({ url: 'pages/ChangePasswordPage' });
        })

        Divider()
          .margin({ left: 20 })

        Row() {
          Text('退出登录')
            .fontSize(16)
            .fontColor('#FF4D4F')
        }
        .width('100%')
        .padding(20)
        .backgroundColor('#FFFFFF')
        .onClick(() => {
          this.doLogout();
        })
      }
      .width('90%')
      .backgroundColor('#FFFFFF')
      .borderRadius(12)

      Text('NewsRead v1.0.0')
        .fontSize(12)
        .fontColor('#CCCCCC')
        .margin({ top: 40 })
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F8F8F8')
  }
}