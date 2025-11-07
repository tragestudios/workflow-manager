import { apiClient } from './ApiClient'
import type { Node } from '@/models'

export class NodeService {
  async getNodesByWorkflow(workflowId: string): Promise<Node[]> {
    return await apiClient.get(`/nodes/workflow/${workflowId}`)
  }

  async getNode(id: string): Promise<Node> {
    return await apiClient.get(`/nodes/${id}`)
  }

  async createNode(workflowId: string, data: Partial<Node>): Promise<Node> {
    return await apiClient.post(`/nodes/workflow/${workflowId}`, data)
  }

  async updateNode(id: string, data: Partial<Node>): Promise<Node> {
    return await apiClient.put(`/nodes/${id}`, data)
  }

  async deleteNode(id: string): Promise<void> {
    return await apiClient.delete(`/nodes/${id}`)
  }
}

export const nodeService = new NodeService()