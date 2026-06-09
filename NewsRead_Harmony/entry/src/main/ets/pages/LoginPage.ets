import router from '@ohos.router';
import { login, register, User } from '../api/userApi';
import promptAction from '@ohos.promptAction';

class LoginParams {
  username: string = '';
  password: string = '';
}

class RegisterParams {
  username: string = '';
  password: string = '';
  nickname: string = '';
}

@Entry
@Component
struct LoginPage {
  @State isLogin: boolean = true;
  @State username: string = '';
  @State password: string = '';
  @State nickname: string = '';
  @State errorMsg: string = '';
  @State isLoading: boolean = false;

  async doLogin() {
    if (!this.username || !this.password) {
      this.errorMsg = '请输入用户名和密码';
      return;
    }
    this.isLoading = true;
    this.errorMsg = '';
    try {
      const result = await login(this.username, this.password);
      await promptAction.showToast({ message: '登录成功，欢迎 ' + result.user.nickname });
      router.back();
    } catch (e) {
      let errMsg: string = '';
      if (e instanceof Error) {
        errMsg = e.message;
      } else {
        errMsg = JSON.stringify(e);
      }
      this.errorMsg = errMsg;
      promptAction.showToast({ message: errMsg });
    } finally {
      this.isLoading = false;
    }
  }

  async doRegister() {
    if (!this.username || !this.password || !this.nickname) {
      this.errorMsg = '请填写完整信息';
      return;
    }
    if (this.password.length < 6) {
      this.errorMsg = '密码至少6位';
      return;
    }
    this.isLoading = true;
    this.errorMsg = '';
    try {
      await register(this.username, this.password, this.nickname);
      this.errorMsg = '注册成功，请登录';
      this.isLogin = true;
      this.password = '';
    } catch (e) {
      this.errorMsg = '注册失败: ' + JSON.stringify(e);
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

      Text(this.isLogin ? '登录' : '注册')
        .fontSize(28)
        .fontWeight(FontWeight.Bold)
        .fontColor('#1A1A1A')
        .margin({ top: 40, bottom: 40 })

      Column({ space: 16 }) {
        if (!this.isLogin) {
          TextInput({ placeholder: '请输入昵称', text: this.nickname })
            .placeholderColor('#999999')
            .backgroundColor('#FFFFFF')
            .padding(16)
            .borderRadius(8)
            .onChange((value: string) => {
              this.nickname = value;
            })
        }

        TextInput({ placeholder: '请输入用户名', text: this.username })
          .placeholderColor('#999999')
          .backgroundColor('#FFFFFF')
          .padding(16)
          .borderRadius(8)
          .onChange((value: string) => {
            this.username = value;
          })

        TextInput({ placeholder: '请输入密码', text: this.password })
          .placeholderColor('#999999')
          .backgroundColor('#FFFFFF')
          .padding(16)
          .borderRadius(8)
          .type(InputType.Password)
          .onChange((value: string) => {
            this.password = value;
          })

        if (this.errorMsg) {
          Text(this.errorMsg)
            .fontSize(14)
            .fontColor('#FF4D4F')
            .margin({ top: 8 })
        }

        Button(this.isLogin ? '登录' : '注册', { type: ButtonType.Normal })
          .width('100%')
          .height(48)
          .backgroundColor('#409EFF')
          .fontColor('#FFFFFF')
          .fontSize(16)
          .margin({ top: 24 })
          .borderRadius(8)
          .enabled(!this.isLoading)
          .onClick(() => {
            if (this.isLogin) {
              this.doLogin();
            } else {
              this.doRegister();
            }
          })

        Row() {
          Text(this.isLogin ? '没有账号？' : '已有账号？')
            .fontSize(14)
            .fontColor('#666666')
          Text(this.isLogin ? '立即注册' : '立即登录')
            .fontSize(14)
            .fontColor('#409EFF')
            .margin({ left: 4 })
        }
        .margin({ top: 16 })
        .onClick(() => {
          this.isLogin = !this.isLogin;
          this.errorMsg = '';
        })
      }
      .width('85%')
      .padding(24)
      .backgroundColor('#FFFFFF')
      .borderRadius(12)
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F8F8F8')
  }
}
