import { get, post, del } from '../utils/HttpUtil';

class Comment {
  id: number = 0;
  articleId: number = 0;
  userId: number = 0;
  parentId: number = 0;
  content: string = '';
  likeCount: number = 0;
  status: number = 1;
  createTime: string = '';
  nickname: string = '';
  avatar: string = '';
}

class CommentResult {
  records: Comment[] = [];
  total: number = 0;
}

class AddCommentData {
  articleId: number = 0;
  parentId: number = 0;
  content: string = '';
}

class LikeResult {
  liked: boolean = false;
}

export { Comment, CommentResult, LikeResult };

export async function getCommentsByArticle(articleId: number, pageNum: number = 1, pageSize: number = 10): Promise<CommentResult> {
  let params: Record<string, number> = {};
  params['articleId'] = articleId;
  params['pageNum'] = pageNum;
  params['pageSize'] = pageSize;
  return get<CommentResult>('/comment/list', params);
}

export async function addComment(articleId: number, content: string, parentId?: number): Promise<Comment> {
  let data = new AddCommentData();
  data.articleId = articleId;
  data.content = content;
  if (parentId !== undefined) {
    data.parentId = parentId;
  }
  return post<Comment>('/comment/add', data);
}

export async function deleteComment(id: number): Promise<void> {
  return del<void>('/comment/delete/' + id.toString());
}

export async function likeComment(id: number): Promise<void> {
  // 修复点：显式声明 Record 类型，消除 10605038 错误
  let data: Record<string, Object> = {};
  return post<void>('/comment/like/' + id.toString(), data);
}

export async function unlikeComment(id: number): Promise<void> {
  return del<void>('/comment/unlike/' + id.toString());
}

export async function hasLikedComment(id: number): Promise<LikeResult> {
  let params: Record<string, number> = {};
  return get<LikeResult>('/comment/hasLiked/' + id.toString(), params);
}