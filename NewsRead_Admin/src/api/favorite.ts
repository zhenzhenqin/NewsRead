import request from '@/utils/request'

/** 收藏数量 Top N 文章 */
export function getTopFavorited(limit: number = 10) {
  return request.get<any, any[]>('/favorite/top', { params: { limit } })
}

/** 获取用户收藏夹列表 */
export function getUserFolders(userId: number) {
  return request.get<any, any[]>('/favorite/folders', { params: { userId } })
}
