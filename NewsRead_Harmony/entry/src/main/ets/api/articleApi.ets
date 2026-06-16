import { get, post, del } from '../utils/HttpUtil';

@Observed
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

class ArticleDetail extends Article {
  authorName: string = '';
  categoryName: string = '';
}

class PageResult<T> {
  records: T[] = [];
  total: number = 0;
  pageNum: number = 0;
  pageSize: number = 0;
}

class LikeResult {
  liked: boolean = false;
}

export { Article, ArticleDetail, PageResult, LikeResult };

export async function getArticleList(categoryId?: number, pageNum: number = 1, pageSize: number = 10): Promise<PageResult<Article>> {
  let params: Record<string, number> = {};
  params['pageNum'] = pageNum;
  params['pageSize'] = pageSize;
  params['isPublished'] = 1;

  if (categoryId !== undefined) {
    params['categoryId'] = categoryId;
  }
  return get<PageResult<Article>>('/article/list', params);
}

export async function getRecommendArticles(limit: number = 10): Promise<Article[]> {
  let params: Record<string, number> = {};
  params['limit'] = limit;
  return get<Article[]>('/article/recommend', params);
}

export async function getFeaturedArticles(limit: number = 5): Promise<Article[]> {
  let params: Record<string, number> = {};
  params['limit'] = limit;
  return get<Article[]>('/article/featured', params);
}

export async function getArticleDetail(id: number): Promise<ArticleDetail> {
  let params: Record<string, number> = {};
  return get<ArticleDetail>('/article/detail/' + id.toString(), params);
}

export async function likeArticle(id: number): Promise<void> {
  // 修复点：显式声明 Record 类型，禁止直接传递 {}
  let data: Record<string, Object> = {};
  return post<void>('/article/like/' + id.toString(), data);
}

export async function unlikeArticle(id: number): Promise<void> {
  return del<void>('/article/unlike/' + id.toString());
}

export async function hasLikedArticle(id: number): Promise<LikeResult> {
  let params: Record<string, number> = {};
  return get<LikeResult>('/article/hasLiked/' + id.toString(), params);
}

/**
 * 关注频道文章流（分页）
 */
export async function getFollowingFeed(pageNum: number = 1, pageSize: number = 10): Promise<PageResult<Article>> {
  let params: Record<string, number> = {};
  params['pageNum'] = pageNum;
  params['pageSize'] = pageSize;
  return get<PageResult<Article>>('/article/following-feed', params);
}