<template>
  <div class="workflow-list-screen">
    <div class="screen-header">
      <h1>Workflows</h1>
      <div class="header-actions">
        <div class="invite-section">
          <input
            v-model="inviteCode"
            type="text"
            placeholder="Enter invite code..."
            class="invite-input"
            @keyup.enter="requestInvitation"
          />
          <button @click="requestInvitation" class="btn-secondary" :disabled="!inviteCode.trim()">
            Join Workflow
          </button>
        </div>
        <button @click="showCreateModal = true" class="btn-primary">
          Create Workflow
        </button>
        <button @click="showImportModal = true" class="btn-secondary">
          Import Workflow
        </button>
      </div>
    </div>

    <div class="workflows-grid">
      <div
        v-for="workflow in workflowStore.workflows"
        :key="workflow.id"
        class="workflow-card card"
        @click="openWorkflow(workflow.id)"
      >
        <div class="workflow-header">
          <h3>{{ workflow.name }}</h3>
          <div class="workflow-actions" @click.stop>
            <button @click="exportWorkflow(workflow.id)" class="btn-secondary">Export</button>
            <button @click="deleteWorkflow(workflow.id)" class="btn-secondary">Delete</button>
          </div>
        </div>
        <p v-if="workflow.description" class="workflow-description">
          {{ workflow.description }}
        </p>
        <div class="workflow-stats">
          <span>{{ workflow.nodes?.length || 0 }} nodes</span>
          <span>{{ workflow.connections?.length || 0 }} connections</span>
        </div>
        <div class="workflow-meta">
          <span class="created-date">
            Created {{ formatDate(workflow.createdAt) }}
          </span>
          <div v-if="workflow.inviteCode" class="invite-code">
            <span class="invite-label">Invite Code:</span>
            <code class="invite-code-text" @click="copyInviteCode(workflow.inviteCode)">
              {{ workflow.inviteCode }}
            </code>
          </div>
        </div>
      </div>
    </div>

    <CreateWorkflowModal
      v-if="showCreateModal"
      @close="showCreateModal = false"
      @create="handleCreateWorkflow"
    />

    <ImportWorkflowModal
      v-if="showImportModal"
      @close="showImportModal = false"
      @import="handleImportWorkflow"
    />
  </div>
</template>

<script setup lang="ts">
import { ref, onMounted } from 'vue'
import { useRouter } from 'vue-router'
import { useWorkflowStore } from '@/stores/workflow'
import { apiClient } from '@/services/ApiClient'
import CreateWorkflowModal from '@/widgets/CreateWorkflowModal.vue'
import ImportWorkflowModal from '@/widgets/ImportWorkflowModal.vue'

const router = useRouter()
const workflowStore = useWorkflowStore()

const showCreateModal = ref(false)
const showImportModal = ref(false)
const inviteCode = ref('')

onMounted(() => {
  workflowStore.loadWorkflows()
})

const openWorkflow = (id: string) => {
  router.push(`/workflow/${id}`)
}

const handleCreateWorkflow = async (data: any) => {
  try {
    const workflow = await workflowStore.createWorkflow(data)
    showCreateModal.value = false
    router.push(`/workflow/${workflow.id}`)
  } catch (error) {
    console.error('Failed to create workflow:', error)
  }
}

const handleImportWorkflow = async (data: any) => {
  try {
    const workflow = await workflowStore.importWorkflow(data)
    showImportModal.value = false
    router.push(`/workflow/${workflow.id}`)
  } catch (error) {
    console.error('Failed to import workflow:', error)
  }
}

const exportWorkflow = async (id: string) => {
  try {
    const data = await workflowStore.exportWorkflow(id)
    const blob = new Blob([JSON.stringify(data, null, 2)], { type: 'application/json' })
    const url = URL.createObjectURL(blob)
    const a = document.createElement('a')
    a.href = url
    a.download = `workflow-${id}.json`
    a.click()
    URL.revokeObjectURL(url)
  } catch (error) {
    console.error('Failed to export workflow:', error)
  }
}

const deleteWorkflow = async (id: string) => {
  if (confirm('Are you sure you want to delete this workflow?')) {
    try {
      await workflowStore.deleteWorkflow(id)
    } catch (error) {
      console.error('Failed to delete workflow:', error)
    }
  }
}

const requestInvitation = async () => {
  if (!inviteCode.value.trim()) return

  try {
    const result = await apiClient.post('/invitations/request', {
      inviteCode: inviteCode.value.trim()
    })
    alert('Invitation request sent successfully! Waiting for approval from workflow owner.')
    inviteCode.value = ''
  } catch (error: any) {
    console.error('Failed to request invitation:', error)
    const errorMessage = error.response?.data?.error || 'Failed to send invitation request'
    alert(errorMessage)
  }
}

const copyInviteCode = async (code: string) => {
  try {
    await navigator.clipboard.writeText(code)
    alert('Invite code copied to clipboard!')
  } catch (error) {
    console.error('Failed to copy invite code:', error)
    alert('Failed to copy invite code')
  }
}

const formatDate = (dateString: string) => {
  return new Date(dateString).toLocaleDateString()
}
</script>

<style scoped>
.workflow-list-screen {
  padding: 24px;
  height: 100%;
}

.screen-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 32px;
}

.screen-header h1 {
  font-size: 32px;
  font-weight: 600;
  color: var(--text-primary);
}

.header-actions {
  display: flex;
  gap: 12px;
  align-items: center;
}

.invite-section {
  display: flex;
  gap: 8px;
  align-items: center;
}

.invite-input {
  padding: 8px 12px;
  border: 1px solid var(--border-color);
  border-radius: 6px;
  font-size: 14px;
  width: 200px;
}

.invite-input:focus {
  outline: none;
  border-color: var(--primary-color);
  box-shadow: 0 0 0 2px rgba(99, 102, 241, 0.1);
}

.workflows-grid {
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(300px, 1fr));
  gap: 24px;
}

.workflow-card {
  padding: 24px;
  cursor: pointer;
  transition: all 0.2s ease;
}

.workflow-card:hover {
  transform: translateY(-2px);
  box-shadow: 0 4px 12px rgba(0, 0, 0, 0.15);
}

.workflow-header {
  display: flex;
  justify-content: space-between;
  align-items: flex-start;
  margin-bottom: 12px;
}

.workflow-header h3 {
  font-size: 18px;
  font-weight: 600;
  color: var(--text-primary);
  margin: 0;
}

.workflow-actions {
  display: flex;
  gap: 8px;
}

.workflow-actions button {
  padding: 4px 8px;
  font-size: 12px;
}

.workflow-description {
  color: var(--text-secondary);
  margin-bottom: 16px;
  font-size: 14px;
  line-height: 1.4;
}

.workflow-stats {
  display: flex;
  gap: 16px;
  margin-bottom: 12px;
}

.workflow-stats span {
  color: var(--text-secondary);
  font-size: 12px;
}

.workflow-meta {
  border-top: 1px solid var(--border-color);
  padding-top: 12px;
}

.created-date {
  color: var(--text-secondary);
  font-size: 12px;
}

.invite-code {
  margin-top: 8px;
  display: flex;
  align-items: center;
  gap: 8px;
}

.invite-label {
  color: var(--text-secondary);
  font-size: 12px;
}

.invite-code-text {
  background: var(--surface-color);
  color: var(--primary-color);
  padding: 2px 6px;
  border-radius: 4px;
  font-size: 11px;
  cursor: pointer;
  transition: all 0.2s ease;
}

.invite-code-text:hover {
  background: var(--primary-color);
  color: white;
}
</style>