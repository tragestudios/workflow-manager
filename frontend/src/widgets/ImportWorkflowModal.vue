<template>
  <div class="modal-overlay" @click="$emit('close')">
    <div class="modal-content" @click.stop>
      <div class="modal-header">
        <h3>Import Workflow</h3>
        <button @click="$emit('close')" class="close-btn">&times;</button>
      </div>

      <div class="modal-form">
        <div class="form-group">
          <label for="file">Select JSON File</label>
          <input
            id="file"
            type="file"
            accept=".json"
            @change="handleFileSelect"
          />
        </div>

        <div v-if="fileContent" class="preview-section">
          <h4>Preview</h4>
          <div class="preview-content">
            <p><strong>Name:</strong> {{ fileContent.workflow?.name || 'N/A' }}</p>
            <p><strong>Description:</strong> {{ fileContent.workflow?.description || 'N/A' }}</p>
            <p><strong>Nodes:</strong> {{ fileContent.nodes?.length || 0 }}</p>
            <p><strong>Connections:</strong> {{ fileContent.connections?.length || 0 }}</p>
          </div>
        </div>

        <div v-if="error" class="error-message">
          {{ error }}
        </div>

        <div class="modal-actions">
          <button type="button" @click="$emit('close')" class="btn-secondary">
            Cancel
          </button>
          <button
            type="button"
            @click="handleImport"
            class="btn-primary"
            :disabled="!fileContent"
          >
            Import Workflow
          </button>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref } from 'vue'

const emit = defineEmits<{
  close: []
  import: [data: any]
}>()

const fileContent = ref<any>(null)
const error = ref('')

const handleFileSelect = (event: Event) => {
  const file = (event.target as HTMLInputElement).files?.[0]
  if (!file) return

  const reader = new FileReader()
  reader.onload = (e) => {
    try {
      const content = JSON.parse(e.target?.result as string)
      fileContent.value = content
      error.value = ''
    } catch (err) {
      error.value = 'Invalid JSON file'
      fileContent.value = null
    }
  }
  reader.readAsText(file)
}

const handleImport = () => {
  if (fileContent.value) {
    emit('import', fileContent.value)
  }
}
</script>

<style scoped>
.modal-overlay {
  position: fixed;
  top: 0;
  left: 0;
  right: 0;
  bottom: 0;
  background: rgba(0, 0, 0, 0.5);
  display: flex;
  align-items: center;
  justify-content: center;
  z-index: 1000;
}

.modal-content {
  background: var(--card-background);
  border-radius: 8px;
  width: 90%;
  max-width: 500px;
  max-height: 90vh;
  overflow-y: auto;
}

.modal-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 20px 24px;
  border-bottom: 1px solid var(--border-color);
}

.modal-header h3 {
  margin: 0;
  font-size: 18px;
  font-weight: 600;
  color: var(--text-primary);
}

.close-btn {
  background: none;
  border: none;
  font-size: 24px;
  cursor: pointer;
  color: var(--text-secondary);
  padding: 0;
  width: 24px;
  height: 24px;
  display: flex;
  align-items: center;
  justify-content: center;
}

.modal-form {
  padding: 24px;
}

.form-group {
  margin-bottom: 20px;
}

.form-group label {
  display: block;
  margin-bottom: 8px;
  font-weight: 500;
  color: var(--text-primary);
}

.form-group input {
  width: 100%;
}

.preview-section {
  margin: 20px 0;
}

.preview-section h4 {
  margin-bottom: 12px;
  color: var(--text-primary);
}

.preview-content {
  background: var(--surface-color);
  padding: 16px;
  border-radius: 6px;
  border: 1px solid var(--border-color);
}

.preview-content p {
  margin: 4px 0;
  font-size: 14px;
  color: var(--text-primary);
}

.error-message {
  color: var(--error-color);
  font-size: 14px;
  margin: 12px 0;
}

.modal-actions {
  display: flex;
  justify-content: flex-end;
  gap: 12px;
  margin-top: 24px;
}
</style>