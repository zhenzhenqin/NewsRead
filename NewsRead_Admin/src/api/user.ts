import request from '@/utils/request'

export interface LoginParams {
  username: string
  password: string
}

export interface LoginResponse {
  token: string
  user: {
    id: number
    username: string
    nickname: string
    avatar: string
    role: number
  }
}

export function login(username: string, password: string) {
  return request<LoginResponse>({
    url: '/user/login',
    method: 'post',
    data: { username, password }
  })
}

export function logout() {
  return request({
    url: '/user/logout',
    method: 'post'
  })
}

export function getUserInfo() {
  return request({
    url: '/user/info',
    method: 'get'
  })
}