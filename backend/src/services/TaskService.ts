import { AppDataSource } from '../config/database';
import { Task, TaskStatus } from '../models/Task';
import { Node } from '../models/Node';
import { User } from '../models/User';

export class TaskService {
  private taskRepository = AppDataSource.getRepository(Task);
  private nodeRepository = AppDataSource.getRepository(Node);

  async getNodeTasks(nodeId: string): Promise<Task[]> {
    const tasks = await this.taskRepository.find({
      where: { nodeId },
      relations: ['assignedTo'],
      order: { createdAt: 'ASC' }
    });
    return tasks;
  }

  async getTaskById(taskId: string): Promise<Task> {
    const task = await this.taskRepository.findOne({
      where: { id: taskId },
      relations: ['assignedTo', 'node']
    });
    if (!task) {
      throw new Error('Task not found');
    }
    return task;
  }

  async createTask(nodeId: string, data: Partial<Task>): Promise<Task> {
    const node = await this.nodeRepository.findOne({ where: { id: nodeId } });
    if (!node) {
      throw new Error('Node not found');
    }

    const task = this.taskRepository.create({
      ...data,
      nodeId
    });

    const savedTask = await this.taskRepository.save(task);

    // Update node progress after creating task
    await this.updateNodeProgress(nodeId);

    return await this.getTaskById(savedTask.id);
  }

  async updateTask(taskId: string, data: Partial<Task>): Promise<Task> {
    const task = await this.getTaskById(taskId);

    // Update task
    await this.taskRepository.update(taskId, data);

    // Update node progress after updating task
    await this.updateNodeProgress(task.nodeId);

    return await this.getTaskById(taskId);
  }

  async deleteTask(taskId: string): Promise<void> {
    const task = await this.getTaskById(taskId);
    const nodeId = task.nodeId;

    await this.taskRepository.delete(taskId);

    // Update node progress after deleting task
    await this.updateNodeProgress(nodeId);
  }

  async assignTask(taskId: string, userId: string): Promise<Task> {
    await this.taskRepository.update(taskId, { assignedToId: userId });
    return await this.getTaskById(taskId);
  }

  async updateNodeProgress(nodeId: string): Promise<void> {
    const tasks = await this.taskRepository.find({ where: { nodeId } });

    if (tasks.length === 0) {
      await this.nodeRepository.update(nodeId, { progressPercentage: 0 });
      return;
    }

    // Calculate progress based on task completion
    const completedTasks = tasks.filter(task => task.status === TaskStatus.COMPLETED).length;
    const progressPercentage = Math.round((completedTasks / tasks.length) * 100);

    await this.nodeRepository.update(nodeId, { progressPercentage });
  }
}
