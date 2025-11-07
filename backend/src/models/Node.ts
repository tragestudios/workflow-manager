import { Entity, PrimaryGeneratedColumn, Column, CreateDateColumn, UpdateDateColumn, ManyToOne, OneToMany, JoinColumn } from 'typeorm';
import { Workflow } from './Workflow';
import { Task } from './Task';
import { File } from './File';

export enum NodeType {
  START = 'start',
  PROCESS = 'process',
  DECISION = 'decision',
  END = 'end'
}

export enum NodeStatus {
  NOT_STARTED = 'not_started',
  IN_PROGRESS = 'in_progress',
  COMPLETED = 'completed'
}

@Entity('nodes')
export class Node {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  @Column()
  name: string;

  @Column({ nullable: true })
  description: string;

  @Column({
    type: 'enum',
    enum: NodeType,
    default: NodeType.PROCESS
  })
  type: NodeType;

  @Column({
    type: 'enum',
    enum: NodeStatus,
    default: NodeStatus.NOT_STARTED
  })
  status: NodeStatus;

  @Column('decimal', { precision: 5, scale: 2, default: 0, name: 'progress_percentage' })
  progressPercentage: number;

  @Column('json', { nullable: true })
  position: { x: number; y: number };

  @Column('json', { nullable: true })
  style: any;

  @Column('text', { nullable: true })
  notes: string;

  @ManyToOne(() => Workflow, workflow => workflow.nodes, { onDelete: 'CASCADE' })
  @JoinColumn({ name: 'workflow_id' })
  workflow: Workflow;

  @Column({ name: 'workflow_id' })
  workflowId: string;

  @OneToMany(() => Task, task => task.node, { cascade: true })
  tasks: Task[];

  @OneToMany(() => File, file => file.node, { cascade: true })
  files: File[];

  @CreateDateColumn({ name: 'created_at' })
  createdAt: Date;

  @UpdateDateColumn({ name: 'updated_at' })
  updatedAt: Date;
}