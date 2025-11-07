<template>
  <div class="canvas-info-widget">
    <div class="info-item">
      <span class="info-label">Zoom:</span>
      <span class="info-value">{{ Math.round(canvasStore.canvasState.position.zoom * 100) }}%</span>
    </div>
    <div class="info-item">
      <span class="info-label">Position:</span>
      <span class="info-value">
        {{ Math.round(canvasStore.canvasState.position.x) }},
        {{ Math.round(canvasStore.canvasState.position.y) }}
      </span>
    </div>
    <div class="info-item">
      <span class="info-label">Nodes:</span>
      <span class="info-value">{{ nodeCount }}</span>
    </div>
    <div class="info-item">
      <span class="info-label">Connections:</span>
      <span class="info-value">{{ connectionCount }}</span>
    </div>
  </div>
</template>

<script setup lang="ts">
import { computed } from 'vue'
import { useCanvasStore } from '@/stores/canvas'
import { useWorkflowStore } from '@/stores/workflow'

const canvasStore = useCanvasStore()
const workflowStore = useWorkflowStore()

const nodeCount = computed(() => workflowStore.currentWorkflow?.nodes?.length || 0)
const connectionCount = computed(() => workflowStore.currentWorkflow?.connections?.length || 0)
</script>

<style scoped>
.canvas-info-widget {
  position: absolute;
  top: 16px;
  left: 16px;
  background: var(--card-background);
  backdrop-filter: blur(4px);
  border: 1px solid var(--border-color);
  border-radius: 8px;
  padding: 12px;
  font-size: 12px;
  z-index: 100;
  min-width: 200px;
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.1);
}

.info-item {
  display: flex;
  justify-content: space-between;
  margin-bottom: 4px;
}

.info-item:last-child {
  margin-bottom: 0;
}

.info-label {
  color: var(--text-secondary);
  font-weight: 500;
}

.info-value {
  color: var(--text-primary);
  font-weight: 600;
}
</style>