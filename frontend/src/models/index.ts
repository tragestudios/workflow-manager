export interface User {
  id: string
  email: string
  name: string
  role: 'admin' | 'user'
  status: 'pending' | 'active' | 'inactive'
  avatar?: string
  createdAt: string
  updatedAt: string
}

export interface Workflow {
  id: string
  name: string
  description?: string
  metadata?: any
  isPublic: boolean
  isActive: boolean
  createdById: string
  createdBy?: User
  nodes: Node[]
  connections: Connection[]
  inviteCode?: string
  invitations: WorkflowInvitation[]
  createdAt: string
  updatedAt: string
}

export interface Node {
  id: string
  name: string
  description?: string
  type: 'start' | 'process' | 'decision' | 'end'
  status: 'not_started' | 'in_progress' | 'completed'
  progressPercentage: number
  position: { x: number; y: number }
  style?: any
  notes?: string
  workflowId: string
  tasks: Task[]
  files: File[]
  createdAt: string
  updatedAt: string
}

export interface Connection {
  id: string
  sourceNodeId: string
  targetNodeId: string
  sourceConnector?: string
  label?: string
  style?: any
  workflowId: string
  createdAt: string
}

export interface Task {
  id: string
  title: string
  description?: string
  status: 'pending' | 'in_progress' | 'completed'
  dueDate?: string
  progressPercentage: number
  nodeId: string
  assignedToId?: string
  assignedTo?: User
  createdAt: string
  updatedAt: string
}

export interface File {
  id: string
  filename: string
  originalName: string
  mimeType: string
  size: number
  path: string
  type: 'image' | 'audio' | 'document' | 'other'
  nodeId: string
  createdAt: string
}

export interface CanvasPosition {
  x: number
  y: number
  zoom: number
}

export interface CanvasState {
  position: CanvasPosition
  selectedNodes: string[]
  selectedConnections: string[]
  mode: 'view' | 'edit' | 'connect'
}

export interface WorkflowInvitation {
  id: string
  inviteCode: string
  workflowId: string
  invitedById: string
  invitedUserId?: string
  status: 'pending' | 'approved' | 'rejected' | 'revoked'
  message?: string
  respondedAt?: string
  isUsed: boolean
  workflow?: Workflow
  invitedBy?: User
  invitedUser?: User
  createdAt: string
  updatedAt: string
}

export interface WorkflowMember {
  id: string
  workflowId: string
  userId: string
  role: 'owner' | 'editor' | 'viewer'
  user?: User
  createdAt: string
  updatedAt: string
}