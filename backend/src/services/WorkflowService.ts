import { AppDataSource } from '../config/database';
import { Workflow } from '../models/Workflow';
import { Node } from '../models/Node';
import { Connection } from '../models/Connection';
import { User } from '../models/User';
import { WorkflowMember, MemberRole } from '../models/WorkflowMember';
import * as crypto from 'crypto';

export class WorkflowService {
  private workflowRepository = AppDataSource.getRepository(Workflow);
  private nodeRepository = AppDataSource.getRepository(Node);
  private connectionRepository = AppDataSource.getRepository(Connection);
  private userRepository = AppDataSource.getRepository(User);
  private memberRepository = AppDataSource.getRepository(WorkflowMember);

  async getWorkflows(userId: string): Promise<Workflow[]> {
    // Get workflows where user is either owner or member
    const memberWorkflows = await this.memberRepository
      .createQueryBuilder('member')
      .leftJoinAndSelect('member.workflow', 'workflow')
      .leftJoinAndSelect('workflow.nodes', 'nodes')
      .leftJoinAndSelect('nodes.tasks', 'tasks')
      .leftJoinAndSelect('workflow.connections', 'connections')
      .leftJoinAndSelect('workflow.createdBy', 'createdBy')
      .where('member.userId = :userId', { userId })
      .orderBy('workflow.updatedAt', 'DESC')
      .getMany();

    return memberWorkflows.map(member => member.workflow);
  }

  async getWorkflowById(id: string): Promise<Workflow> {
    const workflow = await this.workflowRepository.findOne({
      where: { id },
      relations: ['nodes', 'connections', 'nodes.tasks', 'nodes.files']
    });

    if (!workflow) {
      throw new Error('Workflow not found');
    }

    return workflow;
  }

  async createWorkflow(data: Partial<Workflow>, userId: string): Promise<Workflow> {
    // Get user to generate invite code
    const user = await this.userRepository.findOne({ where: { id: userId } });
    if (!user) {
      throw new Error('User not found');
    }

    const workflow = this.workflowRepository.create({
      ...data,
      createdById: userId,
      createdBy: user
    });

    const savedWorkflow = await this.workflowRepository.save(workflow);

    // Generate invite code after saving to get the ID
    const emailPrefix = user.email.split('@')[0];
    const emailHash = crypto.createHash('md5').update(emailPrefix).digest('hex').substring(0, 8);
    const workflowIdHash = savedWorkflow.id.replace(/-/g, '').substring(0, 8);
    savedWorkflow.inviteCode = `${emailHash}-${workflowIdHash}`.toUpperCase();

    const finalWorkflow = await this.workflowRepository.save(savedWorkflow);

    // Add creator as owner member
    const ownerMember = this.memberRepository.create({
      workflowId: finalWorkflow.id,
      userId: userId,
      role: MemberRole.OWNER
    });

    await this.memberRepository.save(ownerMember);

    return finalWorkflow;
  }

  async updateWorkflow(id: string, data: Partial<Workflow>): Promise<Workflow> {
    await this.workflowRepository.update(id, data);
    return await this.getWorkflowById(id);
  }

  async deleteWorkflow(id: string): Promise<void> {
    const workflow = await this.workflowRepository.findOne({ where: { id } });
    if (!workflow) {
      throw new Error('Workflow not found');
    }

    await this.workflowRepository.remove(workflow);
  }

  async exportWorkflow(id: string): Promise<any> {
    const workflow = await this.getWorkflowById(id);

    return {
      workflow: {
        name: workflow.name,
        description: workflow.description,
        metadata: workflow.metadata
      },
      nodes: workflow.nodes.map(node => ({
        id: node.id,
        name: node.name,
        description: node.description,
        type: node.type,
        position: node.position,
        style: node.style,
        notes: node.notes
      })),
      connections: workflow.connections.map(conn => ({
        id: conn.id,
        sourceNodeId: conn.sourceNodeId,
        targetNodeId: conn.targetNodeId,
        label: conn.label,
        style: conn.style
      }))
    };
  }

  async importWorkflow(data: any, userId: string): Promise<Workflow> {
    const workflow = await this.createWorkflow(data.workflow, userId);

    if (data.nodes) {
      for (const nodeData of data.nodes) {
        await this.nodeRepository.save({
          ...nodeData,
          workflowId: workflow.id
        });
      }
    }

    if (data.connections) {
      for (const connData of data.connections) {
        await this.connectionRepository.save({
          ...connData,
          workflowId: workflow.id
        });
      }
    }

    return await this.getWorkflowById(workflow.id);
  }

  async getWorkflowMembers(workflowId: string): Promise<WorkflowMember[]> {
    const members = await this.memberRepository.find({
      where: { workflowId },
      relations: ['user'],
      order: { role: 'ASC', createdAt: 'ASC' }
    });

    return members;
  }
}