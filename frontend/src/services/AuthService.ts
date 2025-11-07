import { apiClient } from './ApiClient'
import type { User } from '@/models'

export class AuthService {
  async login(email: string, password: string): Promise<{ user: User; token: string }> {
    return await apiClient.post('/auth/login', { email, password })
  }

  async register(email: string, name: string, password: string): Promise<{ user: User }> {
    return await apiClient.post('/auth/register', { email, name, password })
  }

  async getProfile(): Promise<User> {
    return await apiClient.get('/users/profile')
  }

  async updateProfile(data: Partial<User>): Promise<User> {
    return await apiClient.put('/users/profile', data)
  }

  async inviteUser(email: string, name: string): Promise<any> {
    return await apiClient.post('/auth/invite', { email, name })
  }

  async approveUser(userId: string): Promise<User> {
    return await apiClient.post(`/auth/approve/${userId}`)
  }
}