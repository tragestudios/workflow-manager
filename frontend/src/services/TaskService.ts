import { apiClient } from './ApiClient'

export interface Task {
  id: string
  title: string
  description?: string
  status: 'pending' | 'in_progress' | 'completed'
  dueDate?: string
  progressPercentage: number
  nodeId: string
  assignedToId?: string
  assignedTo?: {
    id: string
    name: string
    email: string
    avatar?: string
  }
  createdAt: string
  updatedAt: string
}

export class TaskService {
  async getNodeTasks(nodeId: string): Promise<Task[]> {
    return await apiClient.get(`/tasks/node/${nodeId}`)
  }

  async getTask(taskId: string): Promise<Task> {
    return await apiClient.get(`/tasks/${taskId}`)
  }

  async createTask(nodeId: string, data: Partial<Task>): Promise<Task> {
    return await apiClient.post(`/tasks/node/${nodeId}`, data)
  }

  async updateTask(taskId: string, data: Partial<Task>): Promise<Task> {
    return await apiClient.put(`/tasks/${taskId}`, data)
  }

  async deleteTask(taskId: string): Promise<void> {
    return await apiClient.delete(`/tasks/${taskId}`)
  }

  async assignTask(taskId: string, userId: string): Promise<Task> {
    return await apiClient.post(`/tasks/${taskId}/assign`, { userId })
  }
}

export const taskService = new TaskService()
