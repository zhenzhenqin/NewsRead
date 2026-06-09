// 修复点：修改为正确的模块路径
import preferences from '@ohos.data.preferences';

const PREFERENCES_NAME = 'newsread_prefs';
const KEY_TOKEN = 'token';
const KEY_USER_ID = 'user_id';
const KEY_USERNAME = 'username';
const KEY_NICKNAME = 'nickname';
const KEY_AVATAR = 'avatar';
const KEY_EMAIL = 'email';
const KEY_PHONE = 'phone';

class StorageUtil {
  private static preferences: preferences.Preferences | null = null;

  static async init(): Promise<void> {
    let context = getContext();
    // 修复点：preferences 模块路径更新后，方法调用名通常保持一致，但需确保类型声明匹配
    StorageUtil.preferences = await preferences.getPreferences(context, PREFERENCES_NAME);
  }

  static async saveToken(token: string): Promise<void> {
    if (!StorageUtil.preferences) {
      await StorageUtil.init();
    }
    await StorageUtil.preferences!.put(KEY_TOKEN, token);
    await StorageUtil.preferences!.flush();
  }

  static async getToken(): Promise<string> {
    if (!StorageUtil.preferences) {
      await StorageUtil.init();
    }
    // 修复点：显式将返回结果转换为 string，杜绝 any 错误
    let token = await StorageUtil.preferences!.get(KEY_TOKEN, '');
    return token.toString();
  }

  static async saveUser(userId: number, username: string, nickname: string, avatar: string, email: string, phone: string): Promise<void> {
    if (!StorageUtil.preferences) {
      await StorageUtil.init();
    }
    await StorageUtil.preferences!.put(KEY_USER_ID, userId);
    await StorageUtil.preferences!.put(KEY_USERNAME, username);
    await StorageUtil.preferences!.put(KEY_NICKNAME, nickname);
    await StorageUtil.preferences!.put(KEY_AVATAR, avatar);
    await StorageUtil.preferences!.put(KEY_EMAIL, email);
    await StorageUtil.preferences!.put(KEY_PHONE, phone);
    await StorageUtil.preferences!.flush();
  }

  static async getUserId(): Promise<number> {
    if (!StorageUtil.preferences) {
      await StorageUtil.init();
    }
    // 修复点：强制类型转换为 number
    let id = await StorageUtil.preferences!.get(KEY_USER_ID, 0);
    return id as number;
  }

  static async getUsername(): Promise<string> {
    if (!StorageUtil.preferences) {
      await StorageUtil.init();
    }
    let name = await StorageUtil.preferences!.get(KEY_USERNAME, '');
    return name.toString();
  }

  static async getNickname(): Promise<string> {
    if (!StorageUtil.preferences) {
      await StorageUtil.init();
    }
    let name = await StorageUtil.preferences!.get(KEY_NICKNAME, '');
    return name.toString();
  }

  static async getAvatar(): Promise<string> {
    if (!StorageUtil.preferences) {
      await StorageUtil.init();
    }
    let avatar = await StorageUtil.preferences!.get(KEY_AVATAR, '');
    return avatar.toString();
  }

  static async getEmail(): Promise<string> {
    if (!StorageUtil.preferences) {
      await StorageUtil.init();
    }
    let email = await StorageUtil.preferences!.get(KEY_EMAIL, '');
    return email.toString();
  }

  static async getPhone(): Promise<string> {
    if (!StorageUtil.preferences) {
      await StorageUtil.init();
    }
    let phone = await StorageUtil.preferences!.get(KEY_PHONE, '');
    return phone.toString();
  }

  static async clear(): Promise<void> {
    if (!StorageUtil.preferences) {
      await StorageUtil.init();
    }
    await StorageUtil.preferences!.delete(KEY_TOKEN);
    await StorageUtil.preferences!.delete(KEY_USER_ID);
    await StorageUtil.preferences!.delete(KEY_USERNAME);
    await StorageUtil.preferences!.delete(KEY_NICKNAME);
    await StorageUtil.preferences!.delete(KEY_AVATAR);
    await StorageUtil.preferences!.delete(KEY_EMAIL);
    await StorageUtil.preferences!.delete(KEY_PHONE);
    await StorageUtil.preferences!.flush();
  }
}

export { StorageUtil };