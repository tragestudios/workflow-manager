<template>
  <div v-if="selectedNode" class="node-details-widget">
    <div class="widget-header">
      <h3>Node Details</h3>
      <button @click="closeWidget" class="close-btn">
        <span>&times;</span>
      </button>
    </div>

    <div class="widget-content">
      <form @submit.prevent="saveChanges">
        <div class="form-group">
          <label for="node-name">Name</label>
          <input
            id="node-name"
            v-model="nodeData.name"
            type="text"
            class="form-input"
            placeholder="Enter node name"
            required
          />
        </div>

        <div class="form-group">
          <label for="node-description">Description</label>
          <textarea
            id="node-description"
            v-model="nodeData.description"
            class="form-textarea"
            placeholder="Enter node description"
            rows="2"
          ></textarea>
        </div>

        <div class="form-group">
          <label>Position</label>
          <div class="position-inputs">
            <div class="position-input">
              <label for="pos-x">X:</label>
              <input
                id="pos-x"
                v-model.number="nodeData.position.x"
                type="number"
                class="form-input small"
              />
            </div>
            <div class="position-input">
              <label for="pos-y">Y:</label>
              <input
                id="pos-y"
                v-model.number="nodeData.position.y"
                type="number"
                class="form-input small"
              />
            </div>
          </div>
        </div>

        <div class="widget-actions">
          <button type="submit" class="btn-primary" :disabled="loading">
            {{ loading ? 'Saving...' : 'Save Changes' }}
          </button>
          <button type="button" @click="resetChanges" class="btn-secondary">
            Reset
          </button>
        </div>
      </form>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, watch, computed } from 'vue'
import { useWorkflowStore } from '@/stores/workflow'
import type { Node } from '@/models'

interface Props {
  selectedNodeId: string | null
}

interface Emits {
  close: []
}

const props = defineProps<Props>()
const emit = defineEmits<Emits>()

const workflowStore = useWorkflowStore()
const loading = ref(false)

const selectedNode = computed(() => {
  if (!props.selectedNodeId || !workflowStore.currentWorkflow) return null
  return workflowStore.currentWorkflow.nodes.find(n => n.id === props.selectedNodeId) || null
})

const nodeData = ref({
  name: '',
  description: '',
  type: 'process' as Node['type'],
  status: 'not_started' as Node['status'],
  progressPercentage: 0,
  notes: '',
  position: { x: 0, y: 0 }
})

// Watch for node changes and update form data
watch(selectedNode, (newNode) => {
  if (newNode) {
    nodeData.value = {
      name: newNode.name || '',
      description: newNode.description || '',
      type: newNode.type,
      status: newNode.status,
      progressPercentage: newNode.progressPercentage || 0,
      notes: newNode.notes || '',
      position: {
        x: newNode.position?.x || 0,
        y: newNode.position?.y || 0
      }
    }
  }
}, { immediate: true })

const saveChanges = async () => {
  if (!selectedNode.value) return

  loading.value = true
  try {
    await workflowStore.updateNode(selectedNode.value.id, {
      name: nodeData.value.name,
      description: nodeData.value.description || undefined,
      type: nodeData.value.type,
      status: nodeData.value.status,
      progressPercentage: nodeData.value.progressPercentage,
      notes: nodeData.value.notes || undefined,
      position: nodeData.value.position
    })
    console.log('Node updated successfully')
  } catch (error) {
    console.error('Failed to update node:', error)
  } finally {
    loading.value = false
  }
}

const resetChanges = () => {
  if (selectedNode.value) {
    nodeData.value = {
      name: selectedNode.value.name || '',
      description: selectedNode.value.description || '',
      type: selectedNode.value.type,
      status: selectedNode.value.status,
      progressPercentage: selectedNode.value.progressPercentage || 0,
      notes: selectedNode.value.notes || '',
      position: {
        x: selectedNode.value.position?.x || 0,
        y: selectedNode.value.position?.y || 0
      }
    }
  }
}

const closeWidget = () => {
  emit('close')
}
</script>

<style scoped>
.node-details-widget {
  position: absolute;
  top: 400px; 
  left: 16px;
  width: 200px;
  background: var(--card-background);
  border: 1px solid var(--border-color);
  border-radius: 8px;
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.1);
  z-index: 100;
  overflow: hidden;
}

.widget-header {
  display: flex;
  align-items: center;
  justify-content: space-between;
  padding: 12px;
  background: var(--surface-color);
  border-bottom: 1px solid var(--border-color);
}

.widget-header h3 {
  margin: 0;
  font-size: 12px;
  font-weight: 600;
  color: var(--text-primary);
}

.close-btn {
  background: none;
  border: none;
  font-size: 16px;
  color: var(--text-secondary);
  cursor: pointer;
  padding: 2px;
  border-radius: 4px;
  transition: all 0.2s ease;
  line-height: 1;
}

.close-btn:hover {
  background: var(--border-color);
  color: var(--text-primary);
}

.widget-content {
  padding: 12px;
  overflow-y: auto;
}

.form-group {
  margin-bottom: 12px;
}

.form-group:last-child {
  margin-bottom: 0;
}

.form-group label {
  display: block;
  margin-bottom: 4px;
  font-size: 11px;
  font-weight: 500;
  color: var(--text-primary);
}

.form-input,
.form-textarea,
.form-select {
  width: 100%;
  padding: 6px 8px;
  border: 1px solid var(--border-color);
  border-radius: 6px;
  font-size: 11px;
  transition: border-color 0.2s ease;
  box-sizing: border-box;
  background-color: var(--input-background);
  color: var(--text-primary);
}

.form-input:focus,
.form-textarea:focus,
.form-select:focus {
  outline: none;
  border-color: var(--primary-color);
  box-shadow: 0 0 0 3px rgba(99, 102, 241, 0.1);
}

.form-textarea {
  resize: vertical;
  font-family: inherit;
}

.progress-input-group {
  display: flex;
  align-items: center;
  gap: 8px;
  margin-bottom: 8px;
}

.progress-input {
  flex: 1;
}

.progress-unit {
  font-size: 14px;
  color: var(--text-secondary);
  font-weight: 500;
}

.progress-bar {
  height: 6px;
  background: var(--border-color);
  border-radius: 3px;
  overflow: hidden;
}

.progress-fill {
  height: 100%;
  background: var(--primary-color);
  transition: width 0.3s ease;
}

.position-inputs {
  display: flex;
  gap: 12px;
}

.position-input {
  flex: 1;
  display: flex;
  align-items: center;
  gap: 6px;
}

.position-input label {
  margin-bottom: 0;
  font-size: 10px;
  min-width: 16px;
}

.form-input.small {
  width: 100%;
}

.widget-actions {
  display: flex;
  gap: 8px;
  margin-top: 12px;
  padding-top: 12px;
  border-top: 1px solid var(--border-color);
}

.btn-primary,
.btn-secondary {
  flex: 1;
  padding: 6px 8px;
  border: none;
  border-radius: 6px;
  font-size: 11px;
  font-weight: 500;
  cursor: pointer;
  transition: all 0.2s ease;
}

.btn-primary {
  background: var(--primary-color);
  color: white;
}

.btn-primary:hover:not(:disabled) {
  background: #5b59c4;
}

.btn-primary:disabled {
  opacity: 0.6;
  cursor: not-allowed;
}

.btn-secondary {
  background: var(--surface-color);
  color: var(--text-secondary);
  border: 1px solid var(--border-color);
}

.btn-secondary:hover {
  background: var(--border-color);
  color: var(--text-primary);
}
</style>