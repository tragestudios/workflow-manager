import { Entity, PrimaryGeneratedColumn, Column, CreateDateColumn, ManyToOne, JoinColumn } from 'typeorm';
import { Workflow } from './Workflow';

@Entity('connections')
export class Connection {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  @Column({ name: 'source_node_id' })
  sourceNodeId: string;

  @Column({ name: 'target_node_id' })
  targetNodeId: string;

  @Column({ name: 'source_connector', nullable: true })
  sourceConnector: string;

  @Column({ nullable: true })
  label: string;

  @Column('json', { nullable: true })
  style: any;

  @ManyToOne(() => Workflow, workflow => workflow.connections, { onDelete: 'CASCADE' })
  @JoinColumn({ name: 'workflow_id' })
  workflow: Workflow;

  @Column({ name: 'workflow_id' })
  workflowId: string;

  @CreateDateColumn({ name: 'created_at' })
  createdAt: Date;
}