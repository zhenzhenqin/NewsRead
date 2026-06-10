import { createRouter, createWebHistory } from 'vue-router'
import Layout from '../components/Layout.vue'
import Dashboard from '../views/Dashboard.vue'
import ArticleList from '../views/ArticleList.vue'
import ArticleEdit from '../views/ArticleEdit.vue'
import Login from '../views/Login.vue'
import UserList from '../views/UserList.vue'
import AdminList from '../views/AdminList.vue'
import CommentList from '../views/CommentList.vue'

const router = createRouter({
  history: createWebHistory(import.meta.env.BASE_URL),
  routes: [
    {
      path: '/login',
      name: 'login',
      component: Login
    },
    {
      path: '/',
      component: Layout,
      redirect: '/dashboard',
      meta: { requiresAuth: true },
      children: [
        { path: 'dashboard', name: 'dashboard', component: Dashboard },
        { path: 'article', name: 'article', component: ArticleList },
        { path: 'article/edit/:id?', name: 'article-edit', component: ArticleEdit },
        { path: 'category', name: 'category', component: () => import('../views/CategoryList.vue') },
        { path: 'user', name: 'user', component: UserList },
        { path: 'admin', name: 'admin', component: AdminList },
        { path: 'comment', name: 'comment', component: CommentList },
        { path: 'spider', name: 'spider', component: () => import('../views/SpiderList.vue'), meta: { title: '新闻爬虫' } }
      ]
    }
  ]
})

router.beforeEach((to, from, next) => {
  const token = localStorage.getItem('token')
  if (to.meta.requiresAuth && !token) {
    next('/login')
  } else if (to.path === '/login' && token) {
    next('/dashboard')
  } else {
    next()
  }
})

export default router