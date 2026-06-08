import { createRouter, createWebHistory } from 'vue-router'
import { useUserStore } from '../stores/user'

const routes = [
  {
    path: '/login',
    name: 'Login',
    component: () => import('../views/Login.vue'),
    meta: { public: true }
  },
  {
    path: '/register',
    name: 'Register',
    component: () => import('../views/Register.vue'),
    meta: { public: true }
  },
  {
    path: '/',
    component: () => import('../views/Layout.vue'),
    redirect: '/dashboard',
    children: [
      {
        path: 'dashboard',
        name: 'Dashboard',
        component: () => import('../views/Dashboard.vue'),
        meta: { title: '首页' }
      },
      {
        path: 'contact/my',
        name: 'MyContact',
        component: () => import('../views/MyContact.vue'),
        meta: { title: '我的通讯录' }
      },
      {
        path: 'contact/list',
        name: 'ContactList',
        component: () => import('../views/ContactList.vue'),
        meta: { title: '通讯录查询' }
      },
      {
        path: 'admin/users',
        name: 'UserManage',
        component: () => import('../views/UserManage.vue'),
        meta: { title: '用户管理', roles: ['ADMIN'] }
      },
      {
        path: 'admin/majors',
        name: 'MajorManage',
        component: () => import('../views/MajorManage.vue'),
        meta: { title: '专业管理', roles: ['ADMIN'] }
      }
    ]
  }
]

const router = createRouter({
  history: createWebHistory(),
  routes
})

// 路由守卫
router.beforeEach((to, from, next) => {
  const token = localStorage.getItem('token')
  if (to.meta.public) {
    next()
    return
  }
  if (!token) {
    next('/login')
    return
  }
  // 检查角色权限
  if (to.meta.roles) {
    const userInfo = JSON.parse(localStorage.getItem('userInfo') || '{}')
    if (!to.meta.roles.includes(userInfo.role)) {
      next('/dashboard')
      return
    }
  }
  next()
})

export default router
