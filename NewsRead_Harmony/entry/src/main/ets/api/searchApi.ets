import { get } from '../utils/HttpUtil';

class HotKeyword {
  keyword: string = '';
  totalCount: number = 0;
}

export { HotKeyword };

/**
 * 全文搜索文章
 */
export async function searchArticles(keyword: string, page: number = 1, size: number = 10): Promise<PageResult<Article>> {
  let params: Record<string, string | number> = {};
  params['keyword'] = keyword;
  params['page'] = page;
  params['size'] = size;
  return get<PageResult<Article>>('/article/search', params);
}

// 复用 articleApi 的类型
class Article {
  id: number = 0;
  title: string = '';
  content: string = '';
  summary: string = '';
  coverImage: string = '';
  categoryId: number = 0;
  authorId: number = 0;
  viewCount: number = 0;
  likeCount: number = 0;
  commentCount: number = 0;
  isFeatured: number = 0;
  isPublished: number = 0;
  publishTime: string = '';
  createTime: string = '';
}

class PageResult<T> {
  records: T[] = [];
  total: number = 0;
  pageNum: number = 0;
  pageSize: number = 0;
}

export { Article, PageResult };

/**
 * 获取搜索热词（最近7天 Top10）
 */
export async function getHotKeywords(): Promise<HotKeyword[]> {
  let params: Record<string, string | number> = {};
  return get<HotKeyword[]>('/article/hot-keywords', params);
}

/**
 * 获取当前用户的搜索历史（最多10条）
 */
export async function getMySearchHistory(): Promise<string[]> {
  let params: Record<string, string | number> = {};
  return get<string[]>('/article/my-search-history', params);
}
