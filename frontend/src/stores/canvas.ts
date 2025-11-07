import { defineStore } from 'pinia'
import { ref } from 'vue'
import type { CanvasState, Node, Connection } from '@/models'

export const useCanvasStore = defineStore('canvas', () => {
  const canvasState = ref<CanvasState>({
    position: { x: 0, y: 0, zoom: 1 },
    selectedNodes: [],
    selectedConnections: [],
    mode: 'edit'
  })

  const selectedNodeForDetails = ref<string | null>(null)
  const globalDragEnabled = ref(true)

  const setPosition = (x: number, y: number) => {
    canvasState.value.position.x = x
    canvasState.value.position.y = y
  }

  const setZoom = (zoom: number) => {
    canvasState.value.position.zoom = Math.max(0.1, Math.min(3, zoom))
  }

  const setMode = (mode: 'view' | 'edit' | 'connect') => {
    canvasState.value.mode = mode
  }

  const selectNode = (nodeId: string, multiSelect = false) => {
    if (multiSelect) {
      if (!canvasState.value.selectedNodes.includes(nodeId)) {
        canvasState.value.selectedNodes.push(nodeId)
      }
    } else {
      canvasState.value.selectedNodes = [nodeId]
    }
  }

  const deselectNode = (nodeId: string) => {
    canvasState.value.selectedNodes = canvasState.value.selectedNodes.filter(id => id !== nodeId)
  }

  const selectConnection = (connectionId: string, multiSelect = false) => {
    if (multiSelect) {
      if (!canvasState.value.selectedConnections.includes(connectionId)) {
        canvasState.value.selectedConnections.push(connectionId)
      }
    } else {
      canvasState.value.selectedConnections = [connectionId]
    }
  }

  const deselectConnection = (connectionId: string) => {
    canvasState.value.selectedConnections = canvasState.value.selectedConnections.filter(id => id !== connectionId)
  }

  const clearSelection = () => {
    canvasState.value.selectedNodes = []
    canvasState.value.selectedConnections = []
  }

  const panCanvas = (deltaX: number, deltaY: number) => {
    canvasState.value.position.x += deltaX
    canvasState.value.position.y += deltaY
  }

  const zoomCanvas = (delta: number, centerX: number, centerY: number) => {
    const oldZoom = canvasState.value.position.zoom
    const newZoom = Math.max(0.1, Math.min(3, oldZoom + delta))
    const zoomRatio = newZoom / oldZoom

    canvasState.value.position.x = centerX - (centerX - canvasState.value.position.x) * zoomRatio
    canvasState.value.position.y = centerY - (centerY - canvasState.value.position.y) * zoomRatio
    canvasState.value.position.zoom = newZoom
  }

  const resetCanvas = () => {
    canvasState.value.position = { x: 0, y: 0, zoom: 1 }
    clearSelection()
  }

  const setSelectedNodeForDetails = (nodeId: string | null) => {
    selectedNodeForDetails.value = nodeId
  }

  const toggleGlobalDrag = () => {
    globalDragEnabled.value = !globalDragEnabled.value
  }

  return {
    canvasState,
    selectedNodeForDetails,
    globalDragEnabled,
    setPosition,
    setZoom,
    setMode,
    selectNode,
    deselectNode,
    selectConnection,
    deselectConnection,
    clearSelection,
    panCanvas,
    zoomCanvas,
    resetCanvas,
    setSelectedNodeForDetails,
    toggleGlobalDrag
  }
})