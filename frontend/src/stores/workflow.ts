import { defineStore } from 'pinia'
import { ref } from 'vue'
import type { Workflow, Node, Connection } from '@/models'
import { WorkflowService } from '@/services/WorkflowService'
import { nodeService } from '@/services/NodeService'
import { connectionService } from '@/services/ConnectionService'

export const useWorkflowStore = defineStore('workflow', () => {
  const workflows = ref<Workflow[]>([])
  const currentWorkflow = ref<Workflow | null>(null)
  const loading = ref(false)
  const workflowService = new WorkflowService()

  // Undo/Redo state
  const undoStack = ref<Workflow[]>([])
  const redoStack = ref<Workflow[]>([])

  const loadWorkflows = async () => {
    loading.value = true
    try {
      workflows.value = await workflowService.getWorkflows()
    } catch (error) {
      console.error('Failed to load workflows:', error)
    } finally {
      loading.value = false
    }
  }

  const loadWorkflow = async (id: string) => {
    loading.value = true
    try {
      currentWorkflow.value = await workflowService.getWorkflow(id)
    } catch (error) {
      console.error('Failed to load workflow:', error)
    } finally {
      loading.value = false
    }
  }

  const createWorkflow = async (data: Partial<Workflow>) => {
    try {
      const workflow = await workflowService.createWorkflow(data)
      workflows.value.push(workflow)
      return workflow
    } catch (error) {
      console.error('Failed to create workflow:', error)
      throw error
    }
  }

  const updateWorkflow = async (id: string, data: Partial<Workflow>) => {
    try {
      const workflow = await workflowService.updateWorkflow(id, data)
      const index = workflows.value.findIndex(w => w.id === id)
      if (index !== -1) {
        workflows.value[index] = workflow
      }
      if (currentWorkflow.value?.id === id) {
        currentWorkflow.value = workflow
      }
      return workflow
    } catch (error) {
      console.error('Failed to update workflow:', error)
      throw error
    }
  }

  const deleteWorkflow = async (id: string) => {
    try {
      await workflowService.deleteWorkflow(id)
      workflows.value = workflows.value.filter(w => w.id !== id)
      if (currentWorkflow.value?.id === id) {
        currentWorkflow.value = null
      }
    } catch (error) {
      console.error('Failed to delete workflow:', error)
      throw error
    }
  }

  const exportWorkflow = async (id: string) => {
    try {
      return await workflowService.exportWorkflow(id)
    } catch (error) {
      console.error('Failed to export workflow:', error)
      throw error
    }
  }

  const importWorkflow = async (data: any) => {
    try {
      const workflow = await workflowService.importWorkflow(data)
      workflows.value.push(workflow)
      return workflow
    } catch (error) {
      console.error('Failed to import workflow:', error)
      throw error
    }
  }

  const addNode = async (workflowId: string, nodeData: Partial<Node>) => {
    try {
      const node = await nodeService.createNode(workflowId, nodeData)
      if (currentWorkflow.value && currentWorkflow.value.id === workflowId) {
        currentWorkflow.value.nodes.push(node)
      }
      return node
    } catch (error) {
      console.error('Failed to add node:', error)
      throw error
    }
  }

  const updateNode = async (nodeId: string, nodeData: Partial<Node>) => {
    try {
      const node = await nodeService.updateNode(nodeId, nodeData)
      if (currentWorkflow.value) {
        const index = currentWorkflow.value.nodes.findIndex(n => n.id === nodeId)
        if (index !== -1) {
          currentWorkflow.value.nodes[index] = node
        }
      }
      return node
    } catch (error) {
      console.error('Failed to update node:', error)
      throw error
    }
  }

  const deleteNode = async (nodeId: string) => {
    try {
      await nodeService.deleteNode(nodeId)
      if (currentWorkflow.value) {
        currentWorkflow.value.nodes = currentWorkflow.value.nodes.filter(n => n.id !== nodeId)
      }
    } catch (error) {
      console.error('Failed to delete node:', error)
      throw error
    }
  }

  const addConnection = async (workflowId: string, connectionData: Partial<Connection>) => {
    try {
      const connection = await connectionService.createConnection(workflowId, connectionData)
      if (currentWorkflow.value && currentWorkflow.value.id === workflowId) {
        currentWorkflow.value.connections.push(connection)
      }
      return connection
    } catch (error) {
      console.error('Failed to add connection:', error)
      throw error
    }
  }

  const deleteConnection = async (connectionId: string) => {
    try {
      await connectionService.deleteConnection(connectionId)
      if (currentWorkflow.value) {
        currentWorkflow.value.connections = currentWorkflow.value.connections.filter(c => c.id !== connectionId)
      }
    } catch (error) {
      console.error('Failed to delete connection:', error)
      throw error
    }
  }

  // Save current state to undo stack
  const saveState = () => {
    if (currentWorkflow.value) {
      // Deep clone current workflow
      const snapshot = JSON.parse(JSON.stringify(currentWorkflow.value))
      undoStack.value.push(snapshot)

      // Limit undo stack to 50 items
      if (undoStack.value.length > 50) {
        undoStack.value.shift()
      }

      // Clear redo stack when new action is performed
      redoStack.value = []
    }
  }

  const undo = async () => {
    if (undoStack.value.length === 0) return

    if (currentWorkflow.value) {
      // Save current state to redo stack
      const currentSnapshot = JSON.parse(JSON.stringify(currentWorkflow.value))
      redoStack.value.push(currentSnapshot)
    }

    // Restore previous state (local only, backend not affected)
    const previousState = undoStack.value.pop()
    if (previousState) {
      currentWorkflow.value = JSON.parse(JSON.stringify(previousState))
      console.log('Undo performed (local only - press Ctrl+S to save)')
    }
  }

  const redo = async () => {
    if (redoStack.value.length === 0) return

    if (currentWorkflow.value) {
      // Save current state to undo stack
      const currentSnapshot = JSON.parse(JSON.stringify(currentWorkflow.value))
      undoStack.value.push(currentSnapshot)
    }

    // Restore next state (local only, backend not affected)
    const nextState = redoStack.value.pop()
    if (nextState) {
      currentWorkflow.value = JSON.parse(JSON.stringify(nextState))
      console.log('Redo performed (local only - press Ctrl+S to save)')
    }
  }

  const canUndo = () => undoStack.value.length > 0
  const canRedo = () => redoStack.value.length > 0

  // Save current workflow to backend
  const saveWorkflow = async () => {
    if (!currentWorkflow.value) return

    try {
      const workflowId = currentWorkflow.value.id

      // Get current backend state
      const backendWorkflow = await workflowService.getWorkflow(workflowId)
      const backendNodeIds = new Set(backendWorkflow.nodes.map(n => n.id))

      // Update only existing nodes
      for (const node of currentWorkflow.value.nodes) {
        if (backendNodeIds.has(node.id)) {
          try {
            await nodeService.updateNode(node.id, {
              name: node.name,
              description: node.description,
              position: node.position,
              status: node.status,
              progressPercentage: node.progressPercentage,
              notes: node.notes
            })
          } catch (err) {
            console.warn(`Skipped updating node ${node.id}:`, err)
          }
        }
      }

      // Save workflow metadata
      await updateWorkflow(workflowId, {
        name: currentWorkflow.value.name,
        description: currentWorkflow.value.description,
        metadata: currentWorkflow.value.metadata
      })

      // Reload to ensure sync
      await loadWorkflow(workflowId)

      console.log('Workflow saved and synced successfully')
      return true
    } catch (error) {
      console.error('Failed to save workflow:', error)
      throw error
    }
  }

  return {
    workflows,
    currentWorkflow,
    loading,
    loadWorkflows,
    loadWorkflow,
    createWorkflow,
    updateWorkflow,
    deleteWorkflow,
    exportWorkflow,
    importWorkflow,
    addNode,
    updateNode,
    deleteNode,
    addConnection,
    deleteConnection,
    saveState,
    undo,
    redo,
    canUndo,
    canRedo,
    saveWorkflow
  }
})