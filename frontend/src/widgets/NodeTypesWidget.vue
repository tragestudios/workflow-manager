<template>
  <div class="node-types-widget">
    <div class="widget-title">Node Types</div>
    <div class="node-types">
      <button
        v-for="nodeType in nodeTypes"
        :key="nodeType.value"
        @click="addNode(nodeType.value)"
        class="node-btn"
        :class="nodeType.value"
        :title="`Add ${nodeType.label} Node`"
      >
        {{ nodeType.label }}
      </button>
    </div>
  </div>
</template>

<script setup lang="ts">
import { useWorkflowStore } from '@/stores/workflow'

const workflowStore = useWorkflowStore()

const nodeTypes = [
  { value: 'start', label: 'Start' },
  { value: 'process', label: 'Process' },
  { value: 'decision', label: 'Decision' },
  { value: 'end', label: 'End' }
]

const addNode = async (type: string) => {
  if (!workflowStore.currentWorkflow) {
    console.error('No current workflow')
    return
  }

  try {
    // Canvas'ın merkezinde node oluştur
    const centerX = Math.floor(Math.random() * 400) + 200
    const centerY = Math.floor(Math.random() * 300) + 150

    await workflowStore.addNode(workflowStore.currentWorkflow.id, {
      name: `${type.charAt(0).toUpperCase() + type.slice(1)} Node`,
      type: type as any,
      position: { x: centerX, y: centerY },
      status: 'not_started',
      progressPercentage: 0
    })

    console.log('Node added successfully:', type)
  } catch (error) {
    console.error('Failed to add node:', error)
  }
}
</script>

<style scoped>
.node-types-widget {
  position: absolute;
  top: 152px; /* CanvasInfoWidget'ın altında 8px boşlukla */
  left: 16px;
  background: var(--card-background);
  backdrop-filter: blur(4px);
  border: 1px solid var(--border-color);
  border-radius: 8px;
  padding: 12px;
  z-index: 100;
  min-width: 200px;
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.1);
}

.widget-title {
  font-size: 12px;
  font-weight: 600;
  color: var(--text-primary);
  margin-bottom: 8px;
  text-align: center;
}

.node-types {
  display: grid;
  grid-template-columns: 1fr 1fr;
  gap: 6px;
}

.node-btn {
  padding: 12px 8px;
  font-size: 11px;
  font-weight: 500;
  border: 1px solid var(--border-color);
  background: var(--input-background);
  color: var(--text-primary);
  border-radius: 6px;
  transition: all 0.2s ease;
  cursor: pointer;
  text-align: center;
  aspect-ratio: 1;
  display: flex;
  align-items: center;
  justify-content: center;
}

.node-btn:not(:disabled):hover {
  background: var(--surface-color);
  border-color: var(--primary-color);
  transform: translateY(-1px);
  box-shadow: 0 2px 4px rgba(0, 0, 0, 0.1);
}
</style>