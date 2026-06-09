import preferences from '@ohos.data.preferences';
import { Context } from '@kit.AbilityKit';

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
  private static context: Context | null = null;

  static setContext(ctx: Context): void {
    StorageUtil.context = ctx;
  }

  static async init(): Promise<void> {
    let ctx = StorageUtil.context;
    if (!ctx) {
      ctx = getContext();
    }
    StorageUtil.preferences = await preferences.getPreferences(ctx, PREFERENCES_NAME);
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
    let val = await StorageUtil.preferences!.get(KEY_TOKEN, '');
    // preferences 返回的可能是 object，强制转 string
    let token = (val !== null && val !== undefined) ? String(val) : '';
    return token;
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

  static async saveUserId(userId: number): Promise<void> {
    if (!StorageUtil.preferences) {
      await StorageUtil.init();
    }
    await StorageUtil.preferences!.put(KEY_USER_ID, userId);
    await StorageUtil.preferences!.flush();
  }

  static async saveUsername(username: string): Promise<void> {
    if (!StorageUtil.preferences) {
      await StorageUtil.init();
    }
    await StorageUtil.preferences!.put(KEY_USERNAME, username);
    await StorageUtil.preferences!.flush();
  }

  static async saveNickname(nickname: string): Promise<void> {
    if (!StorageUtil.preferences) {
      await StorageUtil.init();
    }
    await StorageUtil.preferences!.put(KEY_NICKNAME, nickname);
    await StorageUtil.preferences!.flush();
  }

  static async saveAvatar(avatar: string): Promise<void> {
    if (!StorageUtil.preferences) {
      await StorageUtil.init();
    }
    await StorageUtil.preferences!.put(KEY_AVATAR, avatar);
    await StorageUtil.preferences!.flush();
  }

  static async saveEmail(email: string): Promise<void> {
    if (!StorageUtil.preferences) {
      await StorageUtil.init();
    }
    await StorageUtil.preferences!.put(KEY_EMAIL, email);
    await StorageUtil.preferences!.flush();
  }

  static async savePhone(phone: string): Promise<void> {
    if (!StorageUtil.preferences) {
      await StorageUtil.init();
    }
    await StorageUtil.preferences!.put(KEY_PHONE, phone);
    await StorageUtil.preferences!.flush();
  }

  static async getUserId(): Promise<number> {
    if (!StorageUtil.preferences) {
      await StorageUtil.init();
    }
    let val = await StorageUtil.preferences!.get(KEY_USER_ID, 0);
    // 强制转 number，处理 string/number/object 类型不一致
    let id = Number(val);
    return isNaN(id) ? 0 : id;
  }

  static async getUsername(): Promise<string> {
    if (!StorageUtil.preferences) {
      await StorageUtil.init();
    }
    let val = await StorageUtil.preferences!.get(KEY_USERNAME, '');
    return (val !== null && val !== undefined) ? String(val) : '';
  }

  static async getNickname(): Promise<string> {
    if (!StorageUtil.preferences) {
      await StorageUtil.init();
    }
    let val = await StorageUtil.preferences!.get(KEY_NICKNAME, '');
    return (val !== null && val !== undefined) ? String(val) : '';
  }

  static async getAvatar(): Promise<string> {
    if (!StorageUtil.preferences) {
      await StorageUtil.init();
    }
    let val = await StorageUtil.preferences!.get(KEY_AVATAR, '');
    return (val !== null && val !== undefined) ? String(val) : '';
  }

  static async getEmail(): Promise<string> {
    if (!StorageUtil.preferences) {
      await StorageUtil.init();
    }
    let val = await StorageUtil.preferences!.get(KEY_EMAIL, '');
    return (val !== null && val !== undefined) ? String(val) : '';
  }

  static async getPhone(): Promise<string> {
    if (!StorageUtil.preferences) {
      await StorageUtil.init();
    }
    let val = await StorageUtil.preferences!.get(KEY_PHONE, '');
    return (val !== null && val !== undefined) ? String(val) : '';
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
