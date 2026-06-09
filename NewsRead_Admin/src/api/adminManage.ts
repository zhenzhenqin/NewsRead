import request from '@/utils/request'

export interface Admin {
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

export interface AdminListParams {
  pageNum: number
  pageSize: number
  username?: string
  status?: number
}

export function getAdminList(params: AdminListParams) {
  return request({
    url: '/user/manage/admin/list',
    method: 'get',
    params
  })
}

export function createAdmin(data: { username: string; password: string; nickname: string; email?: string; phone?: string }) {
  return request({
    url: '/user/manage/admin/create',
    method: 'post',
    data
  })
}

export function resetAdminPassword(id: number, password: string) {
  return request({
    url: `/user/manage/admin/resetPwd/${id}`,
    method: 'put',
    data: { password }
  })
}

export function deleteAdmin(id: number) {
  return request({
    url: `/user/manage/delete/${id}`,
    method: 'delete'
  })
}