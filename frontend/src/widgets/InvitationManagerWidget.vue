<template>
  <div class="invitation-manager" @click.stop>
    <div class="widget-header">
      <h3>Invitation Requests</h3>
      <button @click="loadPendingInvitations" class="refresh-btn">
        🔄
      </button>
    </div>

    <div v-if="loading" class="loading-state">
      Loading invitations...
    </div>

    <div v-else-if="pendingInvitations.length === 0" class="empty-state">
      No pending invitation requests
    </div>

    <div v-else class="invitations-list">
      <div
        v-for="invitation in pendingInvitations"
        :key="invitation.id"
        class="invitation-item"
      >
        <div class="invitation-info">
          <div class="user-info">
            <strong>{{ invitation.invitedUser?.name || 'Unknown User' }}</strong>
            <span class="user-email">{{ invitation.invitedUser?.email }}</span>
          </div>
          <div class="invitation-meta">
            <span class="request-time">
              Requested {{ formatDate(invitation.createdAt) }}
            </span>
            <span class="invite-code">Code: {{ invitation.inviteCode }}</span>
          </div>
        </div>

        <div class="invitation-actions">
          <button
            @click="respondToInvitation(invitation.id, 'approve')"
            class="btn-approve"
            :disabled="responding"
          >
            ✓ Approve
          </button>
          <button
            @click="respondToInvitation(invitation.id, 'reject')"
            class="btn-reject"
            :disabled="responding"
          >
            ✗ Reject
          </button>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, onMounted } from 'vue'
import { apiClient } from '@/services/ApiClient'

interface Invitation {
  id: string
  inviteCode: string
  workflowId: string
  status: string
  createdAt: string
  invitedUser: {
    id: string
    name: string
    email: string
  }
}

interface Props {
  workflowId: string
}

interface Emits {
  refreshCount: []
}

const props = defineProps<Props>()
const emit = defineEmits<Emits>()

const pendingInvitations = ref<Invitation[]>([])
const loading = ref(false)
const responding = ref(false)

onMounted(() => {
  loadPendingInvitations()
})

const loadPendingInvitations = async () => {
  loading.value = true
  try {
    pendingInvitations.value = await apiClient.get(`/invitations/pending/${props.workflowId}`)
    emit('refreshCount')
  } catch (error) {
    console.error('Error loading pending invitations:', error)
  } finally {
    loading.value = false
  }
}

const respondToInvitation = async (invitationId: string, action: 'approve' | 'reject') => {
  responding.value = true
  try {
    await apiClient.patch(`/invitations/${invitationId}/respond`, { action })
    alert(`Invitation ${action}d successfully!`)
    await loadPendingInvitations() // Refresh the list
  } catch (error: any) {
    console.error(`Error ${action}ing invitation:`, error)
    const errorMessage = error.response?.data?.error || `Failed to ${action} invitation`
    alert(errorMessage)
  } finally {
    responding.value = false
  }
}

const formatDate = (dateString: string) => {
  return new Date(dateString).toLocaleDateString()
}
</script>

<style scoped>
.invitation-manager {
  position: absolute;
  top: 16px;
  right: 16px;
  width: 320px;
  max-height: 400px;
  overflow-y: auto;
  background: var(--card-background);
  backdrop-filter: blur(4px);
  border: 1px solid var(--border-color);
  border-radius: 8px;
  padding: 16px;
  z-index: 100;
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.1);
}

.widget-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 16px;
}

.widget-header h3 {
  margin: 0;
  font-size: 16px;
  font-weight: 600;
  color: var(--text-primary);
}

.refresh-btn {
  background: var(--input-background);
  border: 1px solid var(--border-color);
  border-radius: 4px;
  padding: 4px 8px;
  cursor: pointer;
  transition: all 0.2s ease;
  color: var(--text-primary);
}

.refresh-btn:hover {
  background: var(--surface-color);
}

.loading-state,
.empty-state {
  text-align: center;
  color: var(--text-secondary);
  padding: 24px;
  font-style: italic;
}

.invitations-list {
  display: flex;
  flex-direction: column;
  gap: 12px;
}

.invitation-item {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 12px;
  border: 1px solid var(--border-color);
  border-radius: 6px;
  background: var(--input-background);
}

.invitation-info {
  flex: 1;
}

.user-info {
  display: flex;
  flex-direction: column;
  gap: 2px;
}

.user-info strong {
  color: var(--text-primary);
  font-size: 14px;
}

.user-email {
  color: var(--text-secondary);
  font-size: 12px;
}

.invitation-meta {
  margin-top: 8px;
  display: flex;
  gap: 16px;
}

.request-time,
.invite-code {
  color: var(--text-secondary);
  font-size: 11px;
}

.invitation-actions {
  display: flex;
  gap: 8px;
}

.btn-approve,
.btn-reject {
  padding: 6px 12px;
  font-size: 12px;
  border: none;
  border-radius: 4px;
  cursor: pointer;
  transition: all 0.2s ease;
}

.btn-approve {
  background: #22c55e;
  color: white;
}

.btn-approve:hover:not(:disabled) {
  background: #16a34a;
}

.btn-reject {
  background: #ef4444;
  color: white;
}

.btn-reject:hover:not(:disabled) {
  background: #dc2626;
}

.btn-approve:disabled,
.btn-reject:disabled {
  opacity: 0.5;
  cursor: not-allowed;
}
</style>