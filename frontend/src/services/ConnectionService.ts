import { apiClient } from './ApiClient'
import type { Connection } from '@/models'

export class ConnectionService {
  async getConnectionsByWorkflow(workflowId: string): Promise<Connection[]> {
    return await apiClient.get(`/connections/workflow/${workflowId}`)
  }

  async getConnection(id: string): Promise<Connection> {
    return await apiClient.get(`/connections/${id}`)
  }

  async createConnection(workflowId: string, data: Partial<Connection>): Promise<Connection> {
    return await apiClient.post(`/connections/workflow/${workflowId}`, data)
  }

  async updateConnection(id: string, data: Partial<Connection>): Promise<Connection> {
    return await apiClient.put(`/connections/${id}`, data)
  }

  async deleteConnection(id: string): Promise<void> {
    return await apiClient.delete(`/connections/${id}`)
  }
}

export const connectionService = new ConnectionService()