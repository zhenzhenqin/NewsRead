import request from '@/utils/request'

export interface ArticleListParams {
  pageNum: number
  pageSize: number
  categoryId?: number
  isPublished?: number
}

export interface Article {
  id: number
  title: string
  content: string
  summary: string
  coverImage: string
  categoryId: number
  authorId: number
  viewCount: number
  likeCount: number
  commentCount: number
  isFeatured: number
  isPublished: number
  status: number
  createTime: string
  updateTime: string
}

export interface ArticleListResponse {
  records: Article[]
  total: number
  pageNum: number
  pageSize: number
}

export function getArticleList(params: ArticleListParams) {
  return request<ArticleListResponse>({
    url: '/article/list',
    method: 'get',
    params
  })
}

export function getArticleDetail(id: number) {
  return request<Article>({
    url: `/article/detail/${id}`,
    method: 'get'
  })
}

export function createArticle(data: Partial<Article>) {
  return request({
    url: '/article/create',
    method: 'post',
    data
  })
}

export function updateArticle(data: Partial<Article>) {
  return request({
    url: '/article/update',
    method: 'put',
    data
  })
}

export function deleteArticle(id: number) {
  return request({
    url: `/article/delete/${id}`,
    method: 'delete'
  })
}