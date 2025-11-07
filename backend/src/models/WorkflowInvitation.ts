import { Entity, PrimaryGeneratedColumn, Column, CreateDateColumn, UpdateDateColumn, ManyToOne, JoinColumn } from 'typeorm';
import { User } from './User';
import { Workflow } from './Workflow';

export enum InvitationStatus {
  PENDING = 'pending',
  APPROVED = 'approved',
  REJECTED = 'rejected',
  REVOKED = 'revoked'
}

@Entity('workflow_invitations')
export class WorkflowInvitation {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  @Column({ unique: true, name: 'invite_code' })
  inviteCode: string;

  @ManyToOne(() => Workflow, { onDelete: 'CASCADE' })
  @JoinColumn({ name: 'workflow_id' })
  workflow: Workflow;

  @Column({ name: 'workflow_id' })
  workflowId: string;

  @ManyToOne(() => User, { onDelete: 'CASCADE' })
  @JoinColumn({ name: 'invited_by_id' })
  invitedBy: User;

  @Column({ name: 'invited_by_id' })
  invitedById: string;

  @ManyToOne(() => User, { nullable: true })
  @JoinColumn({ name: 'invited_user_id' })
  invitedUser: User;

  @Column({ nullable: true, name: 'invited_user_id' })
  invitedUserId: string;

  @Column({
    type: 'enum',
    enum: InvitationStatus,
    default: InvitationStatus.PENDING
  })
  status: InvitationStatus;

  @Column({ nullable: true })
  message: string;

  @Column({ nullable: true, name: 'responded_at' })
  respondedAt: Date;

  @Column({ default: false, name: 'is_used' })
  isUsed: boolean;

  @CreateDateColumn({ name: 'created_at' })
  createdAt: Date;

  @UpdateDateColumn({ name: 'updated_at' })
  updatedAt: Date;
}