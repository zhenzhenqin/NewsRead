import request from '@/utils/request'

export function getStatistics() {
  return request({
    url: '/admin/statistics',
    method: 'get'
  })
}

export function getCategoryStats() {
  return request({
    url: '/admin/categoryStats',
    method: 'get'
  })
}

export function getTopArticles(limit: number = 10) {
  return request({
    url: '/admin/topArticles',
    method: 'get',
    params: { limit }
  })
}
