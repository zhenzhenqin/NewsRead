import { get } from '../utils/HttpUtil';

class Category {
  id: number = 0;
  name: string = '';
  icon: string = '';
  sort: number = 0;
  status: number = 1;
}

export { Category };

export async function getAllCategories(): Promise<Category[]> {
  return get<Category[]>('/category/all', {});
}