import { defineStore } from 'pinia'
import { ref, computed } from 'vue'
import type { User } from '@/models'
import { AuthService } from '@/services/AuthService'

export const useAuthStore = defineStore('auth', () => {
  const user = ref<User | null>(null)
  const token = ref<string | null>(localStorage.getItem('token'))
  const authService = new AuthService()

  const isAuthenticated = computed(() => {
    const hasToken = !!token.value || !!localStorage.getItem('token')
    const hasUser = !!user.value
    return hasToken && hasUser
  })

  const login = async (email: string, password: string) => {
    try {
      const response = await authService.login(email, password)
      user.value = response.user
      token.value = response.token
      localStorage.setItem('token', response.token)
      return response
    } catch (error) {
      throw error
    }
  }

  const register = async (email: string, name: string, password: string) => {
    try {
      const response = await authService.register(email, name, password)
      return response
    } catch (error) {
      throw error
    }
  }

  const logout = () => {
    user.value = null
    token.value = null
    localStorage.removeItem('token')
  }

  const loadUserFromToken = async () => {
    const storedToken = localStorage.getItem('token')
    if (storedToken) {
      token.value = storedToken
      try {
        const userData = await authService.getProfile()
        user.value = userData
      } catch (error) {
        console.error('Failed to load user from token:', error)
        logout()
        throw error
      }
    }
  }

  return {
    user,
    token,
    isAuthenticated,
    login,
    register,
    logout,
    loadUserFromToken
  }
})