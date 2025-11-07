import { createRouter, createWebHistory } from 'vue-router'
import { useAuthStore } from '@/stores/auth'
import LoginScreen from '@/screens/LoginScreen.vue'
import WorkflowListScreen from '@/screens/WorkflowListScreen.vue'
import CanvasScreen from '@/screens/CanvasScreen.vue'

const routes = [
  {
    path: '/login',
    name: 'Login',
    component: LoginScreen,
    meta: { requiresGuest: true }
  },
  {
    path: '/',
    name: 'WorkflowList',
    component: WorkflowListScreen,
    meta: { requiresAuth: true }
  },
  {
    path: '/workflow/:id',
    name: 'Canvas',
    component: CanvasScreen,
    meta: { requiresAuth: true }
  }
]

const router = createRouter({
  history: createWebHistory(),
  routes
})

router.beforeEach(async (to, from, next) => {
  const authStore = useAuthStore()

  // If we have a token but no user, try to load user from token
  if (authStore.token && !authStore.user) {
    try {
      await authStore.loadUserFromToken()
    } catch (error) {
      console.error('Failed to load user from token:', error)
      // Token is invalid, clear it
      authStore.logout()
    }
  }

  if (to.meta.requiresAuth && !authStore.isAuthenticated) {
    next('/login')
  } else if (to.meta.requiresGuest && authStore.isAuthenticated) {
    next('/')
  } else {
    next()
  }
})

export default router