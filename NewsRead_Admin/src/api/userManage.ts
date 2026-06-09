import request from '@/utils/request'

export interface User {
  id: number
  username: string
  nickname: string
  avatar: string
  email: string
  phone: string
  status: number
  role: number
  createTime: string
}

export interface UserListParams {
  pageNum: number
  pageSize: number
  username?: string
  status?: number
  role?: number
}

export function getUserList(params: UserListParams) {
  return request({
    url: '/user/manage/list',
    method: 'get',
    params
  })
}

export function getUserDetail(id: number) {
  return request<User>({
    url: `/user/manage/${id}`,
    method: 'get'
  })
}

export function updateUser(data: Partial<User>) {
  return request({
    url: '/user/manage/update',
    method: 'put',
    data
  })
}

export function banUser(id: number, status: number) {
  return request({
    url: `/user/manage/ban/${id}`,
    method: 'put',
    data: { status }
  })
}

export function deleteUser(id: number) {
  return request({
    url: `/user/manage/delete/${id}`,
    method: 'delete'
  })
}