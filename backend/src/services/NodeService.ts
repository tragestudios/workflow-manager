import { AppDataSource } from '../config/database';
import { Node } from '../models/Node';
import { Workflow } from '../models/Workflow';

export class NodeService {
  private nodeRepository = AppDataSource.getRepository(Node);
  private workflowRepository = AppDataSource.getRepository(Workflow);

  async createNode(workflowId: string, data: Partial<Node>): Promise<Node> {
    // Verify workflow exists
    const workflow = await this.workflowRepository.findOne({ where: { id: workflowId } });
    if (!workflow) {
      throw new Error('Workflow not found');
    }

    const node = this.nodeRepository.create({
      ...data,
      workflowId
    });

    return await this.nodeRepository.save(node);
  }

  async updateNode(id: string, data: Partial<Node>): Promise<Node> {
    const node = await this.nodeRepository.findOne({ where: { id } });
    if (!node) {
      throw new Error('Node not found');
    }

    await this.nodeRepository.update(id, data);
    return await this.nodeRepository.findOne({ where: { id } }) as Node;
  }

  async deleteNode(id: string): Promise<void> {
    const node = await this.nodeRepository.findOne({ where: { id } });
    if (!node) {
      throw new Error('Node not found');
    }

    await this.nodeRepository.remove(node);
  }

  async getNodesByWorkflow(workflowId: string): Promise<Node[]> {
    return await this.nodeRepository.find({
      where: { workflowId },
      relations: ['tasks', 'files']
    });
  }

  async getNodeById(id: string): Promise<Node> {
    const node = await this.nodeRepository.findOne({
      where: { id },
      relations: ['tasks', 'files', 'workflow']
    });

    if (!node) {
      throw new Error('Node not found');
    }

    return node;
  }
}