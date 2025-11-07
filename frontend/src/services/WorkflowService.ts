import { apiClient } from './ApiClient'
import type { Workflow } from '@/models'

export class WorkflowService {
  async getWorkflows(): Promise<Workflow[]> {
    return await apiClient.get('/workflows')
  }

  async getWorkflow(id: string): Promise<Workflow> {
    return await apiClient.get(`/workflows/${id}`)
  }

  async createWorkflow(data: Partial<Workflow>): Promise<Workflow> {
    return await apiClient.post('/workflows', data)
  }

  async updateWorkflow(id: string, data: Partial<Workflow>): Promise<Workflow> {
    return await apiClient.put(`/workflows/${id}`, data)
  }

  async deleteWorkflow(id: string): Promise<void> {
    return await apiClient.delete(`/workflows/${id}`)
  }

  async exportWorkflow(id: string): Promise<any> {
    return await apiClient.post(`/workflows/${id}/export`)
  }

  async importWorkflow(data: any): Promise<Workflow> {
    return await apiClient.post('/workflows/import', data)
  }
}