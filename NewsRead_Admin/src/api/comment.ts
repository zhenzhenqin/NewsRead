import request from '@/utils/request'

export function getCommentList(params: { pageNum: number; pageSize: number; articleId?: number }) {
  return request({
    url: '/comment/list',
    method: 'get',
    params
  })
}

export function deleteComment(id: number) {
  return request({
    url: `/comment/delete/${id}`,
    method: 'delete'
  })
}

export function getAllComments(params: { pageNum: number; pageSize: number; keyword?: string }) {
  return request({
    url: '/comment/all',
    method: 'get',
    params
  })
}

export function hideComment(id: number) {
  return request({
    url: `/comment/hide/${id}`,
    method: 'post'
  })
}

export function showComment(id: number) {
  return request({
    url: `/comment/show/${id}`,
    method: 'post'
  })
}
