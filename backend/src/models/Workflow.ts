import { Entity, PrimaryGeneratedColumn, Column, CreateDateColumn, UpdateDateColumn, ManyToOne, OneToMany, JoinColumn } from 'typeorm';
import { User } from './User';
import { Node } from './Node';
import { Connection } from './Connection';
import { WorkflowInvitation } from './WorkflowInvitation';

@Entity('workflows')
export class Workflow {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  @Column()
  name: string;

  @Column({ nullable: true })
  description: string;

  @Column('json', { nullable: true })
  metadata: any;

  @Column({ default: false, name: 'is_public' })
  isPublic: boolean;

  @Column({ default: true, name: 'is_active' })
  isActive: boolean;

  @ManyToOne(() => User, user => user.workflows)
  @JoinColumn({ name: 'created_by_id' })
  createdBy: User;

  @Column({ name: 'created_by_id' })
  createdById: string;

  @OneToMany(() => Node, node => node.workflow, { cascade: true })
  nodes: Node[];

  @OneToMany(() => Connection, connection => connection.workflow, { cascade: true })
  connections: Connection[];

  @OneToMany(() => WorkflowInvitation, invitation => invitation.workflow, { cascade: true })
  invitations: WorkflowInvitation[];

  @Column({ nullable: true, unique: true, name: 'invite_code' })
  inviteCode: string;

  @CreateDateColumn({ name: 'created_at' })
  createdAt: Date;

  @UpdateDateColumn({ name: 'updated_at' })
  updatedAt: Date;

  // Note: Invite code generation moved to service layer for better control
}