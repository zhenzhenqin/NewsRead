import { User } from '../api/userApi';
import { StorageUtil } from '../utils/StorageUtil';
import { setToken } from '../utils/HttpUtil';

async function restoreLoginState(): Promise<boolean> {
  let token = await StorageUtil.getToken();
  console.log('restoreLoginState token:', token);
  if (!token) {
    return false;
  }

  let userId = await StorageUtil.getUserId();
  if (!userId) {
    console.log('restoreLoginState: no userId');
    return false;
  }

  let username = await StorageUtil.getUsername();
  let nickname = await StorageUtil.getNickname();
  let avatar = await StorageUtil.getAvatar();
  let email = await StorageUtil.getEmail();
  let phone = await StorageUtil.getPhone();

  let user = new User();
  user.id = userId;
  user.username = username;
  user.nickname = nickname;
  user.avatar = avatar;
  user.email = email;
  user.phone = phone;

  AuthUtil.setUser(user, token);
  setToken(token);
  console.log('restoreLoginState: success, token set to:', token);
  return true;
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
    console.log('AuthUtil.setUser: userId=' + user.id + ', token=' + token.substring(0, 20) + '...');
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
      console.log('restoreLogin: already initialized, isLoggedIn:', AuthUtil.isLoggedIn());
      return AuthUtil.isLoggedIn();
    }
    AuthUtil.isInit = true;
    const result = await restoreLoginState();
    console.log('restoreLogin: first time, result:', result);
    return result;
  }
}

export { AuthUtil };