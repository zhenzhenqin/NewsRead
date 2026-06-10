import { get, post } from '../utils/HttpUtil';
import { AuthUtil } from '../utils/AuthUtil';
import { Article } from './articleApi';

class FavoriteItem {
  id: number = 0;
  userId: number = 0;
  articleId: number = 0;
  folderName: string = '';
  createTime: string = '';
}

class CheckResult {
  favorited: boolean = false;
}

export { FavoriteItem };

/** 检查是否已收藏 */
export async function checkFavorited(articleId: number): Promise<boolean> {
  const user = AuthUtil.getUser();
  if (!user) return false;
  let params: Record<string, number> = {};
  params['userId'] = user.id;
  params['articleId'] = articleId;
  const result = await get<boolean>('/favorite/check', params);
  return result === true;
}

/** 添加收藏 */
export async function addFavorite(articleId: number): Promise<void> {
  const user = AuthUtil.getUser();
  if (!user) throw new Error('未登录');
  let data: Record<string, Object> = {};
  data['userId'] = user.id;
  data['articleId'] = articleId;
  data['folderName'] = '默认收藏夹';
  await post<void>('/favorite/add', data);
}

/** 取消收藏 */
export async function removeFavorite(articleId: number): Promise<void> {
  const user = AuthUtil.getUser();
  if (!user) throw new Error('未登录');
  let data: Record<string, Object> = {};
  data['userId'] = user.id;
  data['articleId'] = articleId;
  await post<void>('/favorite/remove', data);
}

/** 获取收藏列表（返回 Article 数组，需要从 FavoriteItem 中提取 articleId 再查详情） */
export async function getFavoriteList(): Promise<FavoriteItem[]> {
  const user = AuthUtil.getUser();
  if (!user) return [];
  let params: Record<string, number> = {};
  params['userId'] = user.id;
  return get<FavoriteItem[]>('/favorite/list', params);
}
