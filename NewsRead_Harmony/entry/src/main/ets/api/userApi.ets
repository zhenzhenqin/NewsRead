import { get, post, put, del, setToken, getToken as getTokenUtil } from '../utils/HttpUtil';
import { AuthUtil } from '../utils/AuthUtil';
import { StorageUtil } from '../utils/StorageUtil';

// ✅ 核心修复：直接从它们原本的文件导入，绝不在这里重复手写！
import { Article } from './articleApi';
import { Comment } from './commentApi';

class User {
  id: number = 0;
  username: string = '';
  nickname: string = '';
  avatar: string = '';
  role: number = 0;
  email: string = '';
  phone: string = '';
}

class LoginData {
  username: string = '';
  password: string = '';
}

class RegisterData {
  username: string = '';
  password: string = '';
  nickname: string = '';
}

class LoginResult {
  token: string = '';
  user: User = new User();
}

// ✅ 修复：只导出本文件特有的 User 和 LoginResult
export { User, LoginResult };

export async function login(username: string, password: string): Promise<LoginResult> {
  let data = new LoginData();
  data.username = username;
  data.password = password;
  const result = await post<LoginResult>('/user/login', data);

  // 保存登录状态，即使出错也不影响登录
  try {
    AuthUtil.setUser(result.user, result.token);
    setToken(result.token);
  } catch (e) {
    console.error('保存登录信息失败:', JSON.stringify(e));
  }

  // 尝试保存到本地存储
  try {
    await StorageUtil.saveToken(result.token);
    await StorageUtil.saveUser(
      result.user.id,
      result.user.username,
      result.user.nickname,
      result.user.avatar,
      result.user.email,
      result.user.phone
    );
  } catch (e) {
    console.error('保存本地存储失败:', JSON.stringify(e));
  }

  return result;
}

export async function register(username: string, password: string, nickname: string): Promise<User> {
  let data = new RegisterData();
  data.username = username;
  data.password = password;
  data.nickname = nickname;
  return post<User>('/user/register', data);
}

export async function getUserInfo(): Promise<User> {
  let params: Record<string, number> = {};
  return get<User>('/user/info', params);
}

export async function logout(): Promise<void> {
  try {
    let data: Record<string, Object> = {};
    await post<void>('/user/logout', data);
  } catch (e) {
    // 退出登录接口可能失败，但本地状态仍需清理
    console.warn('退出登录请求失败，继续清理本地状态');
  }
  AuthUtil.clear();
  setToken('');
  await StorageUtil.clear();
}

class PasswordData {
  oldPassword: string = '';
  newPassword: string = '';
}

class ProfileData {
  nickname: string = '';
  email: string = '';
  phone: string = '';
  avatar: string = '';
}

export async function updatePassword(oldPassword: string, newPassword: string): Promise<void> {
  let data = new PasswordData();
  data.oldPassword = oldPassword;
  data.newPassword = newPassword;
  await put<void>('/user/password', data);
}

export async function updateProfile(nickname: string, email: string, phone: string, avatar: string): Promise<void> {
  let data = new ProfileData();
  data.nickname = nickname;
  data.email = email;
  data.phone = phone;
  data.avatar = avatar;
  await put<void>('/user/profile', data);
}

// ✅ 修复：通用分页结果类，如果 articleApi 里面已经有 PageResult，其实也应该 import 过来，但这里作为泛型类暂时保留不影响大局
class PageResult<T> {
  records: T[] = [];
  total: number = 0;
}

export async function getLikedArticles(pageNum: number = 1, pageSize: number = 10): Promise<PageResult<Article>> {
  let params: Record<string, number> = {};
  params['pageNum'] = pageNum;
  params['pageSize'] = pageSize;
  return get<PageResult<Article>>('/user/likes', params);
}

export async function getUserComments(pageNum: number = 1, pageSize: number = 10): Promise<PageResult<Comment>> {
  let params: Record<string, number> = {};
  params['pageNum'] = pageNum;
  params['pageSize'] = pageSize;
  return get<PageResult<Comment>>('/user/comments', params);
}

export async function getBrowseHistory(pageNum: number = 1, pageSize: number = 10): Promise<PageResult<Article>> {
  let params: Record<string, number> = {};
  params['pageNum'] = pageNum;
  params['pageSize'] = pageSize;
  return get<PageResult<Article>>('/user/history', params);
}

class BrowseHistoryData {
  articleId: number = 0;
}

export async function addBrowseHistory(articleId: number): Promise<void> {
  let data = new BrowseHistoryData();
  data.articleId = articleId;
  await post<void>('/user/history/add', data);
}

export async function deleteBrowseHistory(articleId: number): Promise<void> {
  await del<void>('/user/history/' + articleId);
}

export async function clearBrowseHistory(): Promise<void> {
  await del<void>('/user/history/clear');
}