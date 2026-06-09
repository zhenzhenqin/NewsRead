export interface Article {
  id: number;
  title: string;
  content: string;
  summary: string;
  coverImage: string;
  categoryId: number;
  authorId: number;
  viewCount: number;
  likeCount: number;
  commentCount: number;
  isFeatured: number;
  isPublished: number;
  publishTime: string;
  createTime: string;
  updateTime: string;
}

export interface BannerItem {
  id: number;
  imageUrl: string;
  title: string;
  linkUrl: string;
}

export interface Category {
  id: number;
  name: string;
  icon: string;
}