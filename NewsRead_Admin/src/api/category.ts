import request from '@/utils/request'

export interface Category {
  id: number
  name: string
  icon: string
  sort: number
  status: number
  createTime: string
}

export interface CategoryListParams {
  pageNum: number
  pageSize: number
  name?: string
}

export function getCategoryList(params: CategoryListParams) {
  return request({
    url: '/category/list',
    method: 'get',
    params
  })
}

export function getAllCategories() {
  return request<Category[]>({
    url: '/category/all',
    method: 'get'
  })
}

export function getCategoryDetail(id: number) {
  return request<Category>({
    url: `/category/${id}`,
    method: 'get'
  })
}

export function createCategory(data: Partial<Category>) {
  return request({
    url: '/category/create',
    method: 'post',
    data
  })
}

export function updateCategory(data: Partial<Category>) {
  return request({
    url: '/category/update',
    method: 'put',
    data
  })
}

export function deleteCategory(id: number) {
  return request({
    url: `/category/delete/${id}`,
    method: 'delete'
  })
}