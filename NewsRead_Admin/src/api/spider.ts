import request from '@/utils/request'

export interface SpiderArticle {
  id: number
  title: string
  summary: string
  coverImage: string
  sourceUrl: string
  categoryId: number | null
  fetchTime: string
}

export interface SpiderPublishDTO {
  title: string
  summary: string
  coverImage: string
  sourceUrl: string
  categoryId: number | null
}

/** 从百度热搜抓取并持久化 */
export function fetchHotNews() {
  return request.get<any, SpiderArticle[]>('/admin/spider/fetch')
}

/** 从数据库读取已保存的爬虫文章 */
export function getSpiderList() {
  return request.get<any, SpiderArticle[]>('/admin/spider/list')
}

/** 删除单条 */
export function deleteSpiderArticle(id: number) {
  return request.delete<any, void>(`/admin/spider/${id}`)
}

/** 发布到正式文章表 */
export function publishArticle(data: SpiderPublishDTO) {
  return request.post<any, void>('/admin/spider/publish', data)
}
