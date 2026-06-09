import { User } from '../api/userApi';
import { StorageUtil } from '../utils/StorageUtil';
import { setToken } from '../utils/HttpUtil';

async function restoreLoginState(): Promise<boolean> {
  try {
    let token = await StorageUtil.getToken();
    console.info('[AUTH] step1 getToken: ' + (token ? 'YES len=' + token.length : 'EMPTY'));
    if (!token) {
      console.info('[AUTH] no token, return false');
      return false;
    }

    let userId = await StorageUtil.getUserId();
    console.info('[AUTH] step2 getUserId: ' + userId + ' (type=' + typeof userId + ')');
    if (!userId || userId === 0) {
      console.info('[AUTH] no userId, return false');
      return false;
    }

    let username = await StorageUtil.getUsername();
    let nickname = await StorageUtil.getNickname();
    let avatar = await StorageUtil.getAvatar();
    let email = await StorageUtil.getEmail();
    let phone = await StorageUtil.getPhone();
    console.info('[AUTH] step3 user info: username=' + username + ', nickname=' + nickname);

    let user = new User();
    user.id = userId;
    user.username = username;
    user.nickname = nickname;
    user.avatar = avatar;
    user.email = email;
    user.phone = phone;

    AuthUtil.setUser(user, token);
    setToken(token);
    console.info('[AUTH] step4 RESTORE OK, userId=' + userId);
    return true;
  } catch (e) {
    console.error('[AUTH] EXCEPTION: ' + JSON.stringify(e));
    return false;
  }
}

class AuthUtil {
  private static currentUser: User | null = null;
  private static token: string = '';
  private static isInit: boolean = false;

  static getUser(): User | null {
    return AuthUtil.currentUser;
  }

  static setUser(user: User, token: string): void {
    AuthUtil.currentUser = user;
    AuthUtil.token = token;
  }

  static getToken(): string {
    return AuthUtil.token;
  }

  static isLoggedIn(): boolean {
    return AuthUtil.currentUser !== null && AuthUtil.token !== '';
  }

  static clear(): void {
    AuthUtil.currentUser = null;
    AuthUtil.token = '';
    AuthUtil.isInit = false;
  }

  static async restoreLogin(): Promise<boolean> {
    if (AuthUtil.isInit) {
      console.info('[AUTH] restoreLogin: cached, isLoggedIn=' + AuthUtil.isLoggedIn());
      return AuthUtil.isLoggedIn();
    }
    try {
      console.info('[AUTH] restoreLogin: starting fresh restore...');
      const result = await restoreLoginState();
      AuthUtil.isInit = true;
      console.info('[AUTH] restoreLogin: done, result=' + result + ', isLoggedIn=' + AuthUtil.isLoggedIn());
      return result;
    } catch (e) {
      console.error('[AUTH] restoreLogin EXCEPTION: ' + JSON.stringify(e));
      return false;
    }
  }
}

export { AuthUtil };
