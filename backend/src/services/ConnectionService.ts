import { AppDataSource } from '../config/database';
import { Connection } from '../models/Connection';
import { Workflow } from '../models/Workflow';
import { Node } from '../models/Node';

export class ConnectionService {
  private connectionRepository = AppDataSource.getRepository(Connection);
  private workflowRepository = AppDataSource.getRepository(Workflow);
  private nodeRepository = AppDataSource.getRepository(Node);

  async createConnection(workflowId: string, data: Partial<Connection>): Promise<Connection> {
    // Verify workflow exists
    const workflow = await this.workflowRepository.findOne({ where: { id: workflowId } });
    if (!workflow) {
      throw new Error('Workflow not found');
    }

    // Verify source and target nodes exist and belong to the workflow
    const sourceNode = await this.nodeRepository.findOne({
      where: { id: data.sourceNodeId, workflowId }
    });
    const targetNode = await this.nodeRepository.findOne({
      where: { id: data.targetNodeId, workflowId }
    });

    if (!sourceNode || !targetNode) {
      throw new Error('Source or target node not found in this workflow');
    }

    // Check if connection already exists
    const existingConnection = await this.connectionRepository.findOne({
      where: {
        sourceNodeId: data.sourceNodeId,
        targetNodeId: data.targetNodeId,
        workflowId
      }
    });

    if (existingConnection) {
      throw new Error('Connection already exists between these nodes');
    }

    const connection = this.connectionRepository.create({
      ...data,
      workflowId
    });

    return await this.connectionRepository.save(connection);
  }

  async updateConnection(id: string, data: Partial<Connection>): Promise<Connection> {
    const connection = await this.connectionRepository.findOne({ where: { id } });
    if (!connection) {
      throw new Error('Connection not found');
    }

    await this.connectionRepository.update(id, data);
    return await this.connectionRepository.findOne({ where: { id } }) as Connection;
  }

  async deleteConnection(id: string): Promise<void> {
    const connection = await this.connectionRepository.findOne({ where: { id } });
    if (!connection) {
      throw new Error('Connection not found');
    }

    await this.connectionRepository.remove(connection);
  }

  async getConnectionsByWorkflow(workflowId: string): Promise<Connection[]> {
    return await this.connectionRepository.find({
      where: { workflowId }
    });
  }

  async getConnectionById(id: string): Promise<Connection> {
    const connection = await this.connectionRepository.findOne({
      where: { id },
      relations: ['workflow']
    });

    if (!connection) {
      throw new Error('Connection not found');
    }

    return connection;
  }
}