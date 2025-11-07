<template>
  <div
    class="workflow-node"
    :class="[node.type, { selected, 'drag-enabled': canvasStore.globalDragEnabled }]"
    :style="nodeStyle"
    @mousedown="handleMouseDown"
    @click="handleClick"
    @dblclick="handleDoubleClick"
  >
    <div class="delete-btn-container">
      <button
        class="delete-btn"
        @click="handleDelete"
        title="Delete node (Del)"
      >
        🗑️
      </button>
    </div>

    <div class="node-header">
      <div class="status-indicator" :class="`status-${node.status}`"></div>
      <div class="node-title">{{ node.name }}</div>
    </div>

    <div v-if="node.description" class="node-description">
      {{ node.description }}
    </div>

    <div class="node-tasks">
      <div class="tasks-count">
        <span v-if="node.type !== 'decision'">
          {{ node.tasks?.length ? `${node.tasks.length} task${node.tasks.length > 1 ? 's' : ''} (${Math.round(node.progressPercentage)}%)` : `No tasks (${Math.round(node.progressPercentage)}%)` }}
        </span>
        <span v-else>
          {{ node.tasks?.length ? `${node.tasks.length} task${node.tasks.length > 1 ? 's' : ''}` : 'No tasks' }}
        </span>
      </div>
      <div class="progress-bar">
        <div
          class="progress-fill"
          :style="{
            width: node.progressPercentage + '%',
            backgroundColor: getProgressColor(node.progressPercentage)
          }"
        ></div>
      </div>
    </div>

    <div class="node-connectors">
      <div
        class="connector input"
        v-if="node.type !== 'start'"
        @click="handleConnectorClick($event, 'input')"
      ></div>

      <template v-if="node.type === 'decision'">
        <div
          class="connector output output-yes"
          @click="handleConnectorClick($event, 'output-yes')"
          title="Yes"
        >
          <span class="connector-label">Yes</span>
        </div>
        <div
          class="connector output output-no"
          @click="handleConnectorClick($event, 'output-no')"
          title="No"
        >
          <span class="connector-label">No</span>
        </div>
      </template>

      <div
        v-else
        class="connector output"
        v-if="node.type !== 'end'"
        @click="handleConnectorClick($event, 'output')"
      ></div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { computed, ref, inject } from 'vue'
import { useCanvasStore } from '@/stores/canvas'
import type { Node } from '@/models'

interface Props {
  node: Node
  selected: boolean
}

interface Emits {
  select: [nodeId: string, multiSelect?: boolean]
  move: [nodeId: string, position: { x: number; y: number }]
  dragend: [nodeId: string, position: { x: number; y: number }]
  connect: [nodeId: string, connectorType: 'input' | 'output' | 'output-yes' | 'output-no']
  delete: [nodeId: string]
  dblclick: [nodeId: string]
}

const props = defineProps<Props>()
const emit = defineEmits<Emits>()
const canvasStore = useCanvasStore()

const nodeStyle = computed(() => ({
  left: props.node.position?.x + 'px',
  top: props.node.position?.y + 'px',
  transform: 'translate(-50%, -50%)'
}))

let isDragging = false
let dragStart = { x: 0, y: 0 }
let nodeStart = { x: 0, y: 0 }

const handleMouseDown = (event: MouseEvent) => {
  event.stopPropagation()

  // Only allow dragging when global drag is enabled
  if (!canvasStore.globalDragEnabled) {
    return
  }

  isDragging = true
  dragStart = { x: event.clientX, y: event.clientY }
  nodeStart = {
    x: props.node.position?.x || 0,
    y: props.node.position?.y || 0
  }

  const handleMouseMove = (moveEvent: MouseEvent) => {
    if (isDragging && canvasStore.globalDragEnabled) {
      const deltaX = moveEvent.clientX - dragStart.x
      const deltaY = moveEvent.clientY - dragStart.y
      const newPosition = {
        x: nodeStart.x + deltaX,
        y: nodeStart.y + deltaY
      }
      emit('move', props.node.id, newPosition)
    }
  }

  const handleMouseUp = (upEvent: MouseEvent) => {
    if (isDragging && canvasStore.globalDragEnabled) {
      const deltaX = upEvent.clientX - dragStart.x
      const deltaY = upEvent.clientY - dragStart.y
      const finalPosition = {
        x: nodeStart.x + deltaX,
        y: nodeStart.y + deltaY
      }
      emit('dragend', props.node.id, finalPosition)
    }
    isDragging = false
    document.removeEventListener('mousemove', handleMouseMove)
    document.removeEventListener('mouseup', handleMouseUp)
  }

  document.addEventListener('mousemove', handleMouseMove)
  document.addEventListener('mouseup', handleMouseUp)
}

const handleClick = (event: MouseEvent) => {
  event.stopPropagation()

  // Single click - select node
  if (!isDragging) {
    emit('select', props.node.id, event.ctrlKey || event.metaKey)
  }
}

const handleConnectorClick = (event: MouseEvent, type: 'input' | 'output' | 'output-yes' | 'output-no') => {
  event.stopPropagation()
  emit('connect', props.node.id, type)
}

const handleDelete = (event: MouseEvent) => {
  event.stopPropagation()
  emit('delete', props.node.id)
}

const handleDoubleClick = (event: MouseEvent) => {
  event.stopPropagation()
  emit('dblclick', props.node.id)
}

const getProgressColor = (progress: number): string => {
  if (progress >= 80) return '#10b981' // Green
  if (progress >= 50) return '#f59e0b' // Orange
  return '#ef4444' // Red
}
</script>

<style scoped>
.workflow-node {
  position: absolute;
  width: 200px;
  min-height: 80px;
  background: var(--card-background);
  border: 2px solid;
  border-radius: 8px;
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.1);
  cursor: pointer;
  transition: all 0.2s ease;
  user-select: none;
  z-index: 1;
}

.workflow-node:hover {
  z-index: 10;
}

.workflow-node.selected {
  box-shadow: 0 4px 16px rgba(99, 102, 241, 0.3);
  border-color: var(--primary-color);
}

.workflow-node.drag-enabled {
  box-shadow: 0 4px 16px rgba(34, 197, 94, 0.3);
  border-color: #22c55e;
  cursor: move;
}

.workflow-node.drag-enabled::after {
  content: '✋';
  position: absolute;
  top: -8px;
  right: -8px;
  background: #22c55e;
  color: white;
  border-radius: 50%;
  width: 20px;
  height: 20px;
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 10px;
}

.workflow-node.start {
  border-color: var(--node-start);
}

.workflow-node.process {
  border-color: var(--node-process);
}

.workflow-node.decision {
  border-color: var(--node-decision);
}

.workflow-node.end {
  border-color: var(--node-end);
}

.node-header {
  display: flex;
  align-items: center;
  padding: 12px;
  gap: 8px;
}

.status-indicator {
  width: 12px;
  height: 12px;
  border-radius: 50%;
  flex-shrink: 0;
}

.node-title {
  flex: 1;
  font-weight: 500;
  font-size: 14px;
  color: var(--text-primary);
}

.progress-indicator {
  font-size: 12px;
  font-weight: 500;
  color: var(--text-secondary);
}

.node-description {
  padding: 0 12px 8px;
  font-size: 12px;
  color: var(--text-secondary);
  line-height: 1.3;
}

.node-tasks {
  padding: 8px 12px 12px;
  border-top: 1px solid var(--border-color);
}

.tasks-count {
  font-size: 11px;
  color: var(--text-secondary);
  margin-bottom: 4px;
  min-height: 15px;
}

.progress-bar {
  height: 4px;
  background: var(--border-color);
  border-radius: 2px;
  overflow: hidden;
}

.progress-fill {
  height: 100%;
  transition: width 0.3s ease, background-color 0.3s ease;
}

.node-connectors {
  position: absolute;
  top: 0;
  left: 0;
  right: 0;
  bottom: 0;
  pointer-events: none;
}

.connector {
  position: absolute;
  width: 12px;
  height: 12px;
  background: var(--card-background);
  border: 2px solid var(--border-color);
  border-radius: 50%;
  pointer-events: all;
  cursor: crosshair;
}

.connector.input {
  left: -6px;
  top: 50%;
  transform: translateY(-50%);
}

.connector.output {
  right: -6px;
  top: 50%;
  transform: translateY(-50%);
}

.connector.output-yes {
  right: -6px;
  top: 30%;
  transform: translateY(-50%);
}

.connector.output-no {
  right: -6px;
  top: 70%;
  transform: translateY(-50%);
}

.connector-label {
  position: absolute;
  right: 20px;
  top: 50%;
  transform: translateY(-50%);
  font-size: 10px;
  font-weight: 600;
  color: var(--text-primary);
  background: var(--card-background);
  padding: 2px 6px;
  border-radius: 4px;
  white-space: nowrap;
  box-shadow: 0 1px 3px rgba(0, 0, 0, 0.1);
  pointer-events: none;
}

.output-yes .connector-label {
  color: #22c55e;
  top: 30%;
}

.output-no .connector-label {
  color: #ef4444;
  top: 70%;
}

.connector:hover {
  border-color: var(--primary-color);
  background: var(--primary-color);
}

.delete-btn-container {
  position: absolute;
  top: -50px;
  left: 50%;
  transform: translateX(-50%);
  opacity: 0;
  pointer-events: none;
  transition: opacity 0.3s ease, top 0.3s cubic-bezier(0.34, 1.56, 0.64, 1);
  z-index: 100;
  padding: 10px;
  margin: -10px;
}

.workflow-node:hover .delete-btn-container,
.delete-btn-container:hover {
  opacity: 1;
  top: -40px;
  pointer-events: all;
  transition-delay: 0s;
}

.workflow-node .delete-btn-container {
  transition-delay: 0s, 0s;
}

.workflow-node:not(:hover) .delete-btn-container:not(:hover) {
  transition-delay: 0.3s, 0s;
}

.delete-btn {
  width: 32px;
  height: 32px;
  border: none;
  border-radius: 50%;
  background: rgba(255, 255, 255, 0.15);
  color: #ef4444;
  cursor: pointer;
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 16px;
  box-shadow: 0 4px 8px rgba(0, 0, 0, 0.2);
  transition: all 0.2s ease;
  backdrop-filter: blur(8px);
}

.delete-btn:hover {
  background: rgba(255, 255, 255, 0.25);
  transform: scale(1.15);
  box-shadow: 0 6px 12px rgba(0, 0, 0, 0.3);
}
</style>