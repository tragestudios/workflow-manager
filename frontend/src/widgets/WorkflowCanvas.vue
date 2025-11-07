<template>
  <div class="workflow-canvas" ref="canvasContainer" :style="canvasStyle">
    <div
      class="canvas-viewport"
      ref="canvasElement"
      :style="viewportStyle"
      @mousedown="handleMouseDown"
      @mousemove="handleMouseMove"
      @mouseup="handleMouseUp"
      @mouseleave="handleMouseUp"
    >

      <div class="canvas-content">
        <WorkflowNode
          v-for="node in nodes"
          :key="node.id"
          :node="node"
          :selected="canvasStore.canvasState.selectedNodes.includes(node.id)"
          @select="selectNode"
          @move="moveNode"
          @dragend="saveNodePosition"
          @connect="handleNodeConnect"
          @delete="deleteNode"
          @dblclick="handleNodeDoubleClick"
        />

        <WorkflowConnection
          v-for="connection in connections"
          :key="connection.id"
          :connection="connection"
          :nodes="nodeMap"
          :selected="canvasStore.canvasState.selectedConnections.includes(connection.id)"
          @select="selectConnection"
          @delete="deleteConnection"
        />
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, computed, onMounted, onUnmounted } from 'vue'
import { useCanvasStore } from '@/stores/canvas'
import { useWorkflowStore } from '@/stores/workflow'
import WorkflowNode from '@/widgets/WorkflowNode.vue'
import WorkflowConnection from '@/widgets/WorkflowConnection.vue'
import type { Node } from '@/models'

const emit = defineEmits<{
  nodeDoubleClick: [nodeId: string]
}>()

const canvasStore = useCanvasStore()
const workflowStore = useWorkflowStore()
const canvasContainer = ref<HTMLElement>()

const nodes = computed(() => workflowStore.currentWorkflow?.nodes || [])
const connections = computed(() => workflowStore.currentWorkflow?.connections || [])

const nodeMap = computed(() => {
  const map = new Map()
  nodes.value.forEach(node => map.set(node.id, node))
  return map
})

const viewportStyle = computed(() => {
  const { x, y, zoom } = canvasStore.canvasState.position
  const centerX = canvasContainer.value?.clientWidth ? canvasContainer.value.clientWidth / 2 : 0
  const centerY = canvasContainer.value?.clientHeight ? canvasContainer.value.clientHeight / 2 : 0
  return {
    transform: `translate(${centerX + x}px, ${centerY + y}px) scale(${zoom})`,
    transformOrigin: '0 0'
  }
})

const canvasStyle = computed(() => {
  const { x, y } = canvasStore.canvasState.position
  const gridSize = 20
  const centerX = canvasContainer.value?.clientWidth ? canvasContainer.value.clientWidth / 2 : 0
  const centerY = canvasContainer.value?.clientHeight ? canvasContainer.value.clientHeight / 2 : 0
  return {
    backgroundPosition: `${(centerX + x) % gridSize}px ${(centerY + y) % gridSize}px`
  }
})

let isDragging = false
let dragStart = { x: 0, y: 0 }
let initialPosition = { x: 0, y: 0 }
const canvasElement = ref<HTMLElement>()

const handleMouseDown = (event: MouseEvent) => {
  // Left click on empty space - clear selections (only if target is canvas viewport)
  if (event.button === 0 && event.target === canvasElement.value) {
    canvasStore.clearSelection()
    canvasStore.setSelectedNodeForDetails(null)
  }
}



const startCanvasDrag = (event: MouseEvent) => {
  isDragging = true
  dragStart = { x: event.clientX, y: event.clientY }
  initialPosition = {
    x: canvasStore.canvasState.position.x,
    y: canvasStore.canvasState.position.y
  }

  // Add grabbing cursor globally
  document.body.style.cursor = 'grabbing'
  document.body.style.userSelect = 'none'

  if (canvasElement.value) {
    canvasElement.value.classList.add('dragging')
  }

  event.preventDefault()
  console.log('Canvas drag started with middle mouse button')
}

const handleMouseMove = (event: MouseEvent) => {
  if (isDragging) {
    const deltaX = event.clientX - dragStart.x
    const deltaY = event.clientY - dragStart.y
    canvasStore.setPosition(
      initialPosition.x + deltaX,
      initialPosition.y + deltaY
    )
  }
}

const handleMouseUp = (event?: MouseEvent) => {
  if (isDragging) {
    isDragging = false

    // Reset cursor globally
    document.body.style.cursor = ''
    document.body.style.userSelect = ''

    if (canvasElement.value) {
      canvasElement.value.classList.remove('dragging')
    }

    console.log('Canvas drag ended')
  }
}

const handleWheel = (event: WheelEvent) => {
  event.preventDefault()

  // Mouse wheel always zooms at mouse position
  const rect = canvasContainer.value?.getBoundingClientRect()
  if (!rect) return

  // Get mouse position relative to canvas container
  const mouseX = event.clientX - rect.left
  const mouseY = event.clientY - rect.top

  // Calculate canvas center offset
  const canvasCenterX = rect.width / 2
  const canvasCenterY = rect.height / 2

  // Mouse position in canvas coordinate system (relative to center)
  const canvasMouseX = mouseX - canvasCenterX
  const canvasMouseY = mouseY - canvasCenterY

  const delta = event.deltaY > 0 ? -0.1 : 0.1
  const oldZoom = canvasStore.canvasState.position.zoom
  const newZoom = Math.max(0.1, Math.min(3, oldZoom + delta))

  if (oldZoom !== newZoom) {
    const zoomRatio = newZoom / oldZoom

    // Adjust position to zoom towards mouse position
    const currentX = canvasStore.canvasState.position.x
    const currentY = canvasStore.canvasState.position.y

    const newX = canvasMouseX - (canvasMouseX - currentX) * zoomRatio
    const newY = canvasMouseY - (canvasMouseY - currentY) * zoomRatio

    canvasStore.canvasState.position.x = newX
    canvasStore.canvasState.position.y = newY
    canvasStore.canvasState.position.zoom = newZoom
  }
}

const selectNode = (nodeId: string, multiSelect = false) => {
  canvasStore.selectNode(nodeId, multiSelect)

  // If not multi-select, open details widget for the node
  if (!multiSelect) {
    canvasStore.setSelectedNodeForDetails(nodeId)
  }
}

const selectConnection = (connectionId: string) => {
  canvasStore.selectConnection(connectionId)
}

let nodePositionBeforeDrag: { x: number; y: number } | null = null

const moveNode = (nodeId: string, position: { x: number; y: number }) => {
  // Save initial position before drag starts
  if (!nodePositionBeforeDrag && workflowStore.currentWorkflow) {
    const node = workflowStore.currentWorkflow.nodes.find(n => n.id === nodeId)
    if (node) {
      nodePositionBeforeDrag = { ...node.position }
    }
  }

  // Update local position immediately for smooth dragging
  if (workflowStore.currentWorkflow) {
    const node = workflowStore.currentWorkflow.nodes.find(n => n.id === nodeId)
    if (node) {
      node.position = position
    }
  }
}

const saveNodePosition = async (nodeId: string, position: { x: number; y: number }) => {
  try {
    // Save state before position change
    if (nodePositionBeforeDrag) {
      workflowStore.saveState()
      nodePositionBeforeDrag = null
    }
    await workflowStore.updateNode(nodeId, { position })
  } catch (error) {
    console.error('Failed to save node position:', error)
  }
}

const deleteNode = async (nodeId: string) => {
  try {
    await workflowStore.deleteNode(nodeId)
    canvasStore.clearSelection()
    console.log('Node deleted:', nodeId)
  } catch (error) {
    console.error('Failed to delete node:', error)
  }
}

const deleteConnection = async (connectionId: string) => {
  try {
    await workflowStore.deleteConnection(connectionId)
    canvasStore.clearSelection()
    console.log('Connection deleted:', connectionId)
  } catch (error) {
    console.error('Failed to delete connection:', error)
  }
}

const handleNodeDoubleClick = (nodeId: string) => {
  emit('nodeDoubleClick', nodeId)
}

// Connection handling
let connectionStart: { nodeId: string; type: 'input' | 'output' | 'output-yes' | 'output-no' } | null = null

const handleNodeConnect = async (nodeId: string, connectorType: 'input' | 'output' | 'output-yes' | 'output-no') => {

  if (!connectionStart) {
    // Start new connection
    connectionStart = { nodeId, type: connectorType }
    console.log('Starting connection from:', nodeId, connectorType)
  } else {
    // Complete connection
    try {
      let sourceNodeId: string
      let targetNodeId: string

      const isOutputType = (type: string) => type === 'output' || type === 'output-yes' || type === 'output-no'

      if (isOutputType(connectionStart.type) && connectorType === 'input') {
        sourceNodeId = connectionStart.nodeId
        targetNodeId = nodeId
      } else if (connectionStart.type === 'input' && isOutputType(connectorType)) {
        sourceNodeId = nodeId
        targetNodeId = connectionStart.nodeId
      } else {
        console.error('Invalid connection: cannot connect', connectionStart.type, 'to', connectorType)
        connectionStart = null
        return
      }

      if (sourceNodeId === targetNodeId) {
        console.error('Cannot connect node to itself')
        connectionStart = null
        return
      }

      if (workflowStore.currentWorkflow) {
        // Save state before adding connection
        workflowStore.saveState()

        const connectionData: any = {
          sourceNodeId,
          targetNodeId
        }

        // Store which connector was used for decision nodes
        if (isOutputType(connectionStart.type)) {
          connectionData.sourceConnector = connectionStart.type
        }

        await workflowStore.addConnection(workflowStore.currentWorkflow.id, connectionData)
        console.log('Connection created successfully with connector:', connectionStart.type)
      }
    } catch (error) {
      console.error('Failed to create connection:', error)
    } finally {
      connectionStart = null
    }
  }
}

// Global middle click handler
const globalMiddleClickHandler = (e: MouseEvent) => {
  if (e.button === 1) {
    startCanvasDrag(e)
    e.preventDefault() // Prevent default middle click behavior
  }
}

// Clipboard storage
let clipboardData: any = null

// Global keyboard handler for M key, Delete key, Ctrl+Z/Ctrl+Y, Ctrl+S, Ctrl+A, Ctrl+C, Ctrl+V
const globalKeyboardHandler = async (e: KeyboardEvent) => {
  // Ctrl+A - Select all nodes and connections
  if ((e.ctrlKey || e.metaKey) && e.key === 'a') {
    e.preventDefault()
    if (workflowStore.currentWorkflow) {
      // Select all nodes
      canvasStore.canvasState.selectedNodes = workflowStore.currentWorkflow.nodes.map(n => n.id)
      // Select all connections
      canvasStore.canvasState.selectedConnections = workflowStore.currentWorkflow.connections.map(c => c.id)
      console.log('Selected all nodes:', canvasStore.canvasState.selectedNodes.length, 'and connections:', canvasStore.canvasState.selectedConnections.length)
    }
    return
  }

  // Ctrl+C - Copy selected nodes and connections
  if ((e.ctrlKey || e.metaKey) && e.key === 'c') {
    e.preventDefault()
    const selectedNodes = canvasStore.canvasState.selectedNodes
    const selectedConnections = canvasStore.canvasState.selectedConnections
    if (selectedNodes.length > 0 && workflowStore.currentWorkflow) {
      // Get selected nodes data
      const nodesToCopy = workflowStore.currentWorkflow.nodes.filter(n =>
        selectedNodes.includes(n.id)
      )

      // Get selected connections data
      const connectionsToCopy = workflowStore.currentWorkflow.connections.filter(c =>
        selectedConnections.includes(c.id)
      )

      // Create node ID mapping for clipboard
      const nodeIdMap = new Map(nodesToCopy.map((node, index) => [node.id, index]))

      // Store in clipboard
      clipboardData = {
        nodes: nodesToCopy.map(node => ({
          name: node.name,
          description: node.description,
          type: node.type,
          status: node.status,
          progressPercentage: node.progressPercentage,
          position: { ...node.position },
          notes: node.notes
        })),
        connections: connectionsToCopy.map(conn => ({
          sourceNodeIndex: nodeIdMap.get(conn.sourceNodeId),
          targetNodeIndex: nodeIdMap.get(conn.targetNodeId),
          sourceConnector: conn.sourceConnector,
          label: conn.label
        })).filter(conn => conn.sourceNodeIndex !== undefined && conn.targetNodeIndex !== undefined)
      }

      console.log('Copied to clipboard:', clipboardData.nodes.length, 'nodes and', clipboardData.connections.length, 'connections')
    }
    return
  }

  // Ctrl+V - Paste nodes and connections
  if ((e.ctrlKey || e.metaKey) && e.key === 'v') {
    e.preventDefault()
    if (clipboardData && clipboardData.nodes && workflowStore.currentWorkflow) {
      workflowStore.saveState()

      const offset = 50 // Offset for pasted nodes
      const newNodeIds: string[] = []

      // First, paste all nodes
      for (const nodeData of clipboardData.nodes) {
        try {
          const newNode = await workflowStore.addNode(workflowStore.currentWorkflow.id, {
            ...nodeData,
            position: {
              x: nodeData.position.x + offset,
              y: nodeData.position.y + offset
            }
          })
          newNodeIds.push(newNode.id)
        } catch (error) {
          console.error('Failed to paste node:', error)
        }
      }

      // Then, paste connections using new node IDs
      if (clipboardData.connections && clipboardData.connections.length > 0) {
        for (const connData of clipboardData.connections) {
          const sourceNodeId = newNodeIds[connData.sourceNodeIndex]
          const targetNodeId = newNodeIds[connData.targetNodeIndex]

          if (sourceNodeId && targetNodeId) {
            try {
              await workflowStore.addConnection(workflowStore.currentWorkflow.id, {
                sourceNodeId,
                targetNodeId,
                sourceConnector: connData.sourceConnector,
                label: connData.label
              })
            } catch (error) {
              console.error('Failed to paste connection:', error)
            }
          }
        }
      }

      console.log('Pasted:', newNodeIds.length, 'nodes and', clipboardData.connections?.length || 0, 'connections')
    }
    return
  }

  // Ctrl+S - Save
  if ((e.ctrlKey || e.metaKey) && e.key === 's') {
    e.preventDefault()
    try {
      await workflowStore.saveWorkflow()
      console.log('Workflow saved with Ctrl+S')
    } catch (error) {
      console.error('Failed to save workflow:', error)
    }
    return
  }

  // Ctrl+Z - Undo
  if ((e.ctrlKey || e.metaKey) && e.key === 'z' && !e.shiftKey) {
    e.preventDefault()
    if (workflowStore.canUndo()) {
      workflowStore.undo()
    }
    return
  }

  // Ctrl+Y or Ctrl+Shift+Z - Redo
  if ((e.ctrlKey || e.metaKey) && (e.key === 'y' || (e.key === 'z' && e.shiftKey))) {
    e.preventDefault()
    if (workflowStore.canRedo()) {
      workflowStore.redo()
    }
    return
  }

  // F - Focus on selected node
  if (e.key === 'f' || e.key === 'F') {
    e.preventDefault()
    const selectedNodes = canvasStore.canvasState.selectedNodes
    if (selectedNodes.length > 0 && workflowStore.currentWorkflow) {
      // Get the first selected node
      const nodeId = selectedNodes[0]
      const node = workflowStore.currentWorkflow.nodes.find(n => n.id === nodeId)

      if (node) {
        // Center canvas on node position
        canvasStore.canvasState.position.x = -node.position.x
        canvasStore.canvasState.position.y = -node.position.y
        console.log('Focused on node:', node.name)
      }
    }
    return
  }

  if (e.key === 'm' || e.key === 'M') {
    canvasStore.toggleGlobalDrag()
    console.log('Global drag mode', canvasStore.globalDragEnabled ? 'enabled' : 'disabled', 'for all nodes')
  } else if (e.key === 'Delete') {
    // Delete selected nodes
    const selectedNodes = canvasStore.canvasState.selectedNodes
    if (selectedNodes.length > 0) {
      workflowStore.saveState()
      selectedNodes.forEach(nodeId => deleteNode(nodeId))
    }

    // Delete selected connections
    const selectedConnections = canvasStore.canvasState.selectedConnections
    if (selectedConnections.length > 0) {
      workflowStore.saveState()
      selectedConnections.forEach(connectionId => deleteConnection(connectionId))
    }
  }
}

// Global wheel handler
const globalWheelHandler = (e: WheelEvent) => {
  handleWheel(e)
}

onMounted(() => {
  document.addEventListener('mouseup', handleMouseUp)
  document.addEventListener('mousemove', handleMouseMove)
  // Add global middle click handler for canvas panning
  document.addEventListener('mousedown', globalMiddleClickHandler)
  // Add global keyboard handler for M key
  document.addEventListener('keydown', globalKeyboardHandler)
  // Add global wheel handler for zoom
  document.addEventListener('wheel', globalWheelHandler, { passive: false })
})

onUnmounted(() => {
  document.removeEventListener('mouseup', handleMouseUp)
  document.removeEventListener('mousemove', handleMouseMove)
  // Remove global middle click handler
  document.removeEventListener('mousedown', globalMiddleClickHandler)
  // Remove global keyboard handler
  document.removeEventListener('keydown', globalKeyboardHandler)
  // Remove global wheel handler
  document.removeEventListener('wheel', globalWheelHandler)
})
</script>

<style scoped>
.workflow-canvas {
  position: relative;
  width: 100%;
  height: 100%;
  overflow: hidden;
  background: radial-gradient(circle, var(--canvas-grid) 1px, transparent 1px);
  background-size: 20px 20px;
  background-position: var(--bg-x, 0) var(--bg-y, 0);
}

.canvas-viewport {
  width: 100%;
  height: 100%;
  cursor: grab;
  user-select: none;
}

.canvas-viewport:active {
  cursor: grabbing;
}

.canvas-viewport.dragging {
  cursor: grabbing !important;
}


.canvas-content {
  position: absolute;
  top: 0;
  left: 0;
  width: 100%;
  height: 100%;
  min-width: 100%;
  min-height: 100%;
  pointer-events: none;
}

.canvas-content > * {
  pointer-events: auto;
}
</style>