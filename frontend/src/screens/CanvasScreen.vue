<template>
  <div class="canvas-screen">
    <CanvasToolbar
      ref="canvasToolbarRef"
      :show-invitation-manager="showInvitationManager"
      @toggle-invitations="toggleInvitationManager"
    />
    <div class="canvas-container">
      <WorkflowCanvas @node-double-click="handleNodeDoubleClick" />
      <CanvasInfoWidget />
      <NodeTypesWidget />
      <ZoomWidget />
      <InvitationManagerWidget
        v-if="workflowStore.currentWorkflow && showInvitationManager"
        :workflow-id="workflowStore.currentWorkflow.id"
        ref="invitationManagerRef"
        @refresh-count="refreshPendingCount"
      />
      <NodeDetailsWidget
        :selected-node-id="canvasStore.selectedNodeForDetails"
        @close="canvasStore.setSelectedNodeForDetails(null)"
      />
      <NodeTaskModal
        :node-id="selectedNodeForTasks"
        :workflow-id="workflowStore.currentWorkflow?.id || ''"
        @close="selectedNodeForTasks = null"
        @task-updated="handleTaskUpdated"
      />
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, onMounted, onUnmounted } from 'vue'
import { useRoute } from 'vue-router'
import { useWorkflowStore } from '@/stores/workflow'
import { useCanvasStore } from '@/stores/canvas'
import CanvasToolbar from '@/widgets/CanvasToolbar.vue'
import WorkflowCanvas from '@/widgets/WorkflowCanvas.vue'
import CanvasInfoWidget from '@/widgets/CanvasInfoWidget.vue'
import NodeTypesWidget from '@/widgets/NodeTypesWidget.vue'
import ZoomWidget from '@/widgets/ZoomWidget.vue'
import InvitationManagerWidget from '@/widgets/InvitationManagerWidget.vue'
import NodeDetailsWidget from '@/widgets/NodeDetailsWidget.vue'
import NodeTaskModal from '@/widgets/NodeTaskModal.vue'

const route = useRoute()
const workflowStore = useWorkflowStore()
const canvasStore = useCanvasStore()

const showInvitationManager = ref(false)
const invitationManagerRef = ref<HTMLElement>()
const canvasToolbarRef = ref<InstanceType<typeof CanvasToolbar>>()
const selectedNodeForTasks = ref<string | null>(null)

const toggleInvitationManager = () => {
  showInvitationManager.value = !showInvitationManager.value
}

const refreshPendingCount = () => {
  // Refresh pending count in toolbar
  canvasToolbarRef.value?.loadPendingCount?.()
}

const handleNodeDoubleClick = (nodeId: string) => {
  selectedNodeForTasks.value = nodeId
}

const handleTaskUpdated = () => {
  // Reload workflow to get updated node progress
  const workflowId = route.params.id as string
  if (workflowId) {
    workflowStore.loadWorkflow(workflowId)
  }
}

const handleClickOutside = (event: MouseEvent) => {
  // Close invitation manager if clicked outside of it
  if (
    showInvitationManager.value &&
    invitationManagerRef.value &&
    !invitationManagerRef.value.contains(event.target as Node)
  ) {
    showInvitationManager.value = false
  }
}

onMounted(() => {
  const workflowId = route.params.id as string
  if (workflowId) {
    workflowStore.loadWorkflow(workflowId)
  }

  // Add click outside listener
  document.addEventListener('click', handleClickOutside)
})

onUnmounted(() => {
  // Remove click outside listener
  document.removeEventListener('click', handleClickOutside)
})
</script>

<style scoped>
.canvas-screen {
  height: 100vh;
  display: flex;
  flex-direction: column;
  overflow: hidden;
}

.canvas-container {
  flex: 1;
  position: relative;
  overflow: hidden;
}
</style>