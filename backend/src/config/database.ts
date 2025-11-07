import { DataSource } from 'typeorm';
import { User } from '../models/User';
import { Workflow } from '../models/Workflow';
import { Node } from '../models/Node';
import { Connection } from '../models/Connection';
import { Task } from '../models/Task';
import { File } from '../models/File';
import { WorkflowInvitation } from '../models/WorkflowInvitation';
import { WorkflowMember } from '../models/WorkflowMember';

export const AppDataSource = new DataSource({
  type: process.env.DB_TYPE as any || 'postgres',
  host: process.env.DB_HOST || 'localhost',
  port: parseInt(process.env.DB_PORT || '5432'),
  username: process.env.DB_USERNAME || 'workflow_user',
  password: process.env.DB_PASSWORD || 'workflow_pass',
  database: process.env.DB_DATABASE || 'workflow_manager',
  synchronize: process.env.NODE_ENV === 'development',
  logging: process.env.NODE_ENV === 'development',
  entities: [User, Workflow, Node, Connection, Task, File, WorkflowInvitation, WorkflowMember],
  migrations: ['src/migrations/**/*.ts'],
  subscribers: ['src/subscribers/**/*.ts'],
});