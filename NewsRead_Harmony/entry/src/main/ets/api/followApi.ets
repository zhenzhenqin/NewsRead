import { get, post } from '../utils/HttpUtil';

class FollowUser {
  id: number = 0;
  username: string = '';
  nickname: string = '';
  avatar: string = '';
}

class FollowPageResult {
  records: FollowUser[] = [];
  total: number = 0;
  pageNum: number = 0;
  pageSize: number = 0;
}

export { FollowUser, FollowPageResult };

/**
 * 关注/取消关注（已关注则取消，未关注则新增）
 * 返回 true=已关注, false=已取消
 */
export async function toggleFollow(followedId: number): Promise<boolean> {
  let data: Record<string, Object> = {};
  data['followedId'] = followedId;
  return post<boolean>('/follow/toggle', data);
}

/**
 * 查询是否已关注
 */
export async function checkFollowing(followedId: number): Promise<boolean> {
  let params: Record<string, string | number> = {};
  params['followedId'] = followedId;
  return get<boolean>('/follow/check', params);
}

/**
 * 我的关注列表（分页，返回用户详情）
 */
export async function getFollowingList(pageNum: number = 1, pageSize: number = 20): Promise<FollowPageResult> {
  let params: Record<string, string | number> = {};
  params['pageNum'] = pageNum;
  params['pageSize'] = pageSize;
  return get<FollowPageResult>('/follow/list', params);
}
