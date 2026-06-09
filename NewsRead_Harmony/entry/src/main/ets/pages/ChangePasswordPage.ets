import router from '@ohos.router';
import { updatePassword } from '../api/userApi';
import promptAction from '@ohos.promptAction';

class PasswordData {
  oldPassword: string = '';
  newPassword: string = '';
  confirmPassword: string = '';
}

@Entry
@Component
struct ChangePasswordPage {
  @State oldPassword: string = '';
  @State newPassword: string = '';
  @State confirmPassword: string = '';
  @State errorMsg: string = '';
  @State isLoading: boolean = false;

  async doUpdatePassword() {
    if (!this.oldPassword) {
      this.errorMsg = '请输入原密码';
      return;
    }
    if (!this.newPassword || this.newPassword.length < 6) {
      this.errorMsg = '新密码至少6位';
      return;
    }
    if (this.newPassword !== this.confirmPassword) {
      this.errorMsg = '两次密码不一致';
      return;
    }
    if (this.oldPassword === this.newPassword) {
      this.errorMsg = '新密码不能与原密码相同';
      return;
    }

    this.isLoading = true;
    this.errorMsg = '';
    try {
      await updatePassword(this.oldPassword, this.newPassword);
      await promptAction.showToast({ message: '密码修改成功，请重新登录' });
      router.back();
    } catch (e) {
      this.errorMsg = '修改失败: ' + JSON.stringify(e);
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

      Text('修改密码')
        .fontSize(24)
        .fontWeight(FontWeight.Bold)
        .fontColor('#1A1A1A')
        .margin({ top: 20, bottom: 30 })

      Column({ space: 16 }) {
        TextInput({ placeholder: '请输入原密码', text: this.oldPassword })
          .placeholderColor('#999999')
          .backgroundColor('#FFFFFF')
          .padding(16)
          .borderRadius(8)
          .type(InputType.Password)
          .onChange((value: string) => {
            this.oldPassword = value;
          })

        TextInput({ placeholder: '请输入新密码（至少6位）', text: this.newPassword })
          .placeholderColor('#999999')
          .backgroundColor('#FFFFFF')
          .padding(16)
          .borderRadius(8)
          .type(InputType.Password)
          .onChange((value: string) => {
            this.newPassword = value;
          })

        TextInput({ placeholder: '请确认新密码', text: this.confirmPassword })
          .placeholderColor('#999999')
          .backgroundColor('#FFFFFF')
          .padding(16)
          .borderRadius(8)
          .type(InputType.Password)
          .onChange((value: string) => {
            this.confirmPassword = value;
          })

        if (this.errorMsg) {
          Text(this.errorMsg)
            .fontSize(14)
            .fontColor('#FF4D4F')
            .margin({ top: 8 })
        }

        Button('确认修改', { type: ButtonType.Normal })
          .width('100%')
          .height(48)
          .backgroundColor('#409EFF')
          .fontColor('#FFFFFF')
          .fontSize(16)
          .margin({ top: 24 })
          .borderRadius(8)
          .enabled(!this.isLoading)
          .onClick(() => {
            this.doUpdatePassword();
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