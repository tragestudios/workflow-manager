<template>
  <div class="canvas-toolbar">
    <div class="toolbar-section">
      <h2>{{ workflowStore.currentWorkflow?.name || 'Workflow' }}</h2>
    </div>


    <div class="toolbar-section">
      <button @click="exportWorkflow" class="toolbar-btn">Export</button>
      <button @click="saveWorkflow" class="toolbar-btn">Save</button>
      <button
        @click.stop="toggleInvitationManager"
        class="toolbar-btn invitation-btn"
        :class="{ active: showInvitationManager }"
      >
        <span class="btn-text">📨 Invitations</span>
        <span v-if="pendingCount > 0" class="notification-badge">{{ pendingCount }}</span>
      </button>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, onMounted, onUnmounted } from 'vue'
import { useCanvasStore } from '@/stores/canvas'
import { useWorkflowStore } from '@/stores/workflow'
import { apiClient } from '@/services/ApiClient'

interface Props {
  showInvitationManager: boolean
}

interface Emits {
  toggleInvitations: []
}

const props = defineProps<Props>()
const emit = defineEmits<Emits>()

const canvasStore = useCanvasStore()
const workflowStore = useWorkflowStore()
const pendingCount = ref(0)

let pollInterval: NodeJS.Timeout | null = null


const exportWorkflow = async () => {
  if (workflowStore.currentWorkflow) {
    try {
      const data = await workflowStore.exportWorkflow(workflowStore.currentWorkflow.id)
      const blob = new Blob([JSON.stringify(data, null, 2)], { type: 'application/json' })
      const url = URL.createObjectURL(blob)
      const a = document.createElement('a')
      a.href = url
      a.download = `${workflowStore.currentWorkflow.name}.json`
      a.click()
      URL.revokeObjectURL(url)
    } catch (error) {
      console.error('Export failed:', error)
    }
  }
}

const saveWorkflow = () => {
  console.log('Saving workflow')
}

const toggleInvitationManager = () => {
  emit('toggleInvitations')
}

const loadPendingCount = async () => {
  if (!workflowStore.currentWorkflow) return

  try {
    const invitations = await apiClient.get(`/invitations/pending/${workflowStore.currentWorkflow.id}`)
    pendingCount.value = Array.isArray(invitations) ? invitations.length : 0
  } catch (error) {
    console.error('Failed to load pending invitations count:', error)
    pendingCount.value = 0
  }
}

onMounted(() => {
  loadPendingCount()
  // Poll for updates every 30 seconds
  pollInterval = setInterval(loadPendingCount, 30000)
})

onUnmounted(() => {
  if (pollInterval) {
    clearInterval(pollInterval)
  }
})

// Expose methods for parent component
defineExpose({
  loadPendingCount
})
</script>

<style scoped>
.canvas-toolbar {
  background: var(--card-background);
  border-bottom: 1px solid var(--border-color);
  padding: 12px 24px;
  display: flex;
  align-items: center;
  gap: 24px;
  box-shadow: 0 1px 3px rgba(0, 0, 0, 0.1);
}

.toolbar-section {
  display: flex;
  align-items: center;
  gap: 12px;
}

.toolbar-section h2 {
  margin: 0;
  font-size: 18px;
  font-weight: 600;
  color: var(--text-primary);
}


.toolbar-btn {
  padding: 8px 16px;
  font-size: 14px;
  font-weight: 500;
  border: 1px solid var(--border-color);
  background: var(--card-background);
  color: var(--text-primary);
  border-radius: 6px;
  transition: all 0.2s ease;
}

.toolbar-btn:hover {
  background: var(--surface-color);
}

.toolbar-btn.active {
  background: var(--primary-color);
  color: white;
  border-color: var(--primary-color);
}

.invitation-btn {
  position: relative;
}

.btn-text {
  display: flex;
  align-items: center;
  gap: 4px;
}

.notification-badge {
  position: absolute;
  top: -8px;
  right: -8px;
  background: var(--error-color);
  color: white;
  border-radius: 50%;
  width: 20px;
  height: 20px;
  font-size: 11px;
  font-weight: 600;
  display: flex;
  align-items: center;
  justify-content: center;
  border: 2px solid var(--card-background);
  box-shadow: 0 2px 4px rgba(0, 0, 0, 0.1);
}

</style>