<template>
  <div v-if="isOpen" class="modal-overlay" @click.self="closeModal">
    <div class="modal-container">
      <div class="modal-header">
        <div class="header-info">
          <h2>{{ node?.name || 'Node Tasks' }}</h2>
          <span class="node-type-badge" :class="`type-${node?.type}`">
            {{ node?.type }}
          </span>
        </div>
        <button class="close-btn" @click="closeModal">&times;</button>
      </div>

      <div class="progress-section">
        <div class="progress-info">
          <span>Overall Progress</span>
          <span class="progress-text">{{ node?.progressPercentage || 0 }}%</span>
        </div>
        <div class="progress-bar">
          <div
            class="progress-fill"
            :style="{ width: `${node?.progressPercentage || 0}%` }"
            :class="getProgressClass(node?.progressPercentage || 0)"
          ></div>
        </div>
      </div>

      <div class="modal-body">
        <!-- Task List -->
        <div class="tasks-section">
          <h3>Tasks ({{ tasks.length }})</h3>

          <div v-if="tasks.length === 0" class="empty-state">
            <p>No tasks yet. Create your first task below!</p>
          </div>

          <div v-else class="tasks-list">
            <div
              v-for="task in tasks"
              :key="task.id"
              class="task-item"
              :class="{ 'task-completed': task.status === 'completed' }"
            >
              <div class="task-checkbox">
                <input
                  type="checkbox"
                  :checked="task.status === 'completed'"
                  :disabled="!canToggleTask(task)"
                  @change="toggleTaskComplete(task)"
                  :title="getCheckboxTitle(task)"
                />
              </div>

              <div class="task-content">
                <div class="task-header">
                  <h4>{{ task.title }}</h4>
                  <span class="task-status" :class="`status-${task.status}`">
                    {{ formatStatus(task.status) }}
                  </span>
                </div>
                <p v-if="task.description" class="task-description">
                  {{ task.description }}
                </p>
                <div class="task-meta">
                  <div v-if="task.assignedTo" class="assigned-to">
                    <span class="avatar">{{ task.assignedTo.name[0] }}</span>
                    <span>{{ task.assignedTo.name }}</span>
                  </div>
                  <div v-else class="not-assigned">
                    <select
                      @change="assignTaskToUser(task, $event)"
                      class="assign-select"
                    >
                      <option value="">Assign to...</option>
                      <option
                        v-for="member in members"
                        :key="member.id"
                        :value="member.userId"
                      >
                        {{ member.user?.name || member.userId }}
                      </option>
                    </select>
                  </div>
                </div>
              </div>

              <div class="task-actions">
                <button
                  @click="editTask(task)"
                  class="btn-icon"
                  title="Edit task"
                >
                  ✏️
                </button>
                <button
                  @click="deleteTaskConfirm(task)"
                  class="btn-icon delete"
                  title="Delete task"
                >
                  🗑️
                </button>
              </div>
            </div>
          </div>
        </div>

        <!-- Add New Task Form -->
        <div class="add-task-section">
          <h3>{{ editingTask ? 'Edit Task' : 'Add New Task' }}</h3>
          <form @submit.prevent="submitTask" class="task-form">
            <div class="form-row">
              <input
                v-model="taskForm.title"
                type="text"
                placeholder="Task title *"
                required
                class="form-input"
              />
            </div>
            <div class="form-row">
              <textarea
                v-model="taskForm.description"
                placeholder="Task description (optional)"
                rows="3"
                class="form-textarea"
              ></textarea>
            </div>
            <div class="form-row">
              <select v-model="taskForm.status" class="form-select">
                <option value="pending">Pending</option>
                <option value="in_progress">In Progress</option>
                <option value="completed">Completed</option>
              </select>
              <select v-model="taskForm.assignedToId" class="form-select">
                <option value="">Not assigned</option>
                <option
                  v-for="member in members"
                  :key="member.id"
                  :value="member.userId"
                >
                  {{ member.user?.name || member.userId }}
                </option>
              </select>
            </div>
            <div class="form-actions">
              <button
                v-if="editingTask"
                type="button"
                @click="cancelEdit"
                class="btn-secondary"
              >
                Cancel
              </button>
              <button type="submit" class="btn-primary">
                {{ editingTask ? 'Update Task' : 'Add Task' }}
              </button>
            </div>
          </form>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, computed, watch, onMounted } from 'vue'
import { taskService, type Task } from '@/services/TaskService'
import { apiClient } from '@/services/ApiClient'
import type { Node, WorkflowMember } from '@/models'
import { useAuthStore } from '@/stores/auth'

const props = defineProps<{
  nodeId: string | null
  workflowId: string
}>()

const emit = defineEmits<{
  close: []
  taskUpdated: []
}>()

const authStore = useAuthStore()
const isOpen = computed(() => !!props.nodeId)
const node = ref<Node | null>(null)
const tasks = ref<Task[]>([])
const members = ref<WorkflowMember[]>([])
const editingTask = ref<Task | null>(null)

const taskForm = ref({
  title: '',
  description: '',
  status: 'pending' as Task['status'],
  assignedToId: ''
})

const closeModal = () => {
  emit('close')
  resetForm()
}

const resetForm = () => {
  taskForm.value = {
    title: '',
    description: '',
    status: 'pending',
    assignedToId: ''
  }
  editingTask.value = null
}

const loadNodeData = async () => {
  if (!props.nodeId) return

  try {
    // Load node details
    const nodeData = await apiClient.get<Node>(`/nodes/${props.nodeId}`)
    node.value = nodeData

    // Load tasks
    await loadTasks()

    // Load workflow members
    await loadMembers()
  } catch (error) {
    console.error('Failed to load node data:', error)
  }
}

const loadTasks = async () => {
  if (!props.nodeId) return

  try {
    tasks.value = await taskService.getNodeTasks(props.nodeId)
  } catch (error) {
    console.error('Failed to load tasks:', error)
  }
}

const loadMembers = async () => {
  try {
    members.value = await apiClient.get<WorkflowMember[]>(`/workflows/${props.workflowId}/members`)
  } catch (error) {
    console.error('Failed to load members:', error)
  }
}

const submitTask = async () => {
  if (!props.nodeId) return

  try {
    const taskData = {
      title: taskForm.value.title,
      description: taskForm.value.description,
      status: taskForm.value.status,
      assignedToId: taskForm.value.assignedToId || undefined
    }

    if (editingTask.value) {
      await taskService.updateTask(editingTask.value.id, taskData)
    } else {
      await taskService.createTask(props.nodeId, taskData)
    }

    await loadTasks()
    await loadNodeData() // Refresh node progress
    resetForm()
    emit('taskUpdated')
  } catch (error) {
    console.error('Failed to save task:', error)
    alert('Failed to save task')
  }
}

const toggleTaskComplete = async (task: Task) => {
  const newStatus = task.status === 'completed' ? 'pending' : 'completed'

  try {
    await taskService.updateTask(task.id, { status: newStatus })
    await loadTasks()
    await loadNodeData() // Refresh node progress
    emit('taskUpdated')
  } catch (error) {
    console.error('Failed to update task:', error)
  }
}

const assignTaskToUser = async (task: Task, event: Event) => {
  const userId = (event.target as HTMLSelectElement).value

  if (!userId) return

  try {
    await taskService.assignTask(task.id, userId)
    await loadTasks()
  } catch (error) {
    console.error('Failed to assign task:', error)
  }
}

const editTask = (task: Task) => {
  editingTask.value = task
  taskForm.value = {
    title: task.title,
    description: task.description || '',
    status: task.status,
    assignedToId: task.assignedToId || ''
  }
}

const cancelEdit = () => {
  resetForm()
}

const deleteTaskConfirm = async (task: Task) => {
  if (!confirm(`Are you sure you want to delete "${task.title}"?`)) return

  try {
    await taskService.deleteTask(task.id)
    await loadTasks()
    await loadNodeData() // Refresh node progress
    emit('taskUpdated')
  } catch (error) {
    console.error('Failed to delete task:', error)
    alert('Failed to delete task')
  }
}

const formatStatus = (status: string) => {
  return status.replace('_', ' ').replace(/\b\w/g, l => l.toUpperCase())
}

const getProgressClass = (progress: number) => {
  if (progress >= 80) return 'progress-high'
  if (progress >= 50) return 'progress-medium'
  return 'progress-low'
}

const canToggleTask = (task: Task): boolean => {
  // User can toggle if they are assigned to the task
  return task.assignedToId === authStore.user?.id
}

const getCheckboxTitle = (task: Task): string => {
  if (task.assignedToId === authStore.user?.id) {
    return task.status === 'completed' ? 'Mark as incomplete' : 'Mark as complete'
  }
  if (task.assignedTo) {
    return `Only ${task.assignedTo.name} can toggle this task`
  }
  return 'Assign this task to someone to enable completion'
}

watch(() => props.nodeId, (newId) => {
  if (newId) {
    loadNodeData()
  }
})

onMounted(() => {
  if (props.nodeId) {
    loadNodeData()
  }
})
</script>

<style scoped>
.modal-overlay {
  position: fixed;
  top: 0;
  left: 0;
  right: 0;
  bottom: 0;
  background: rgba(0, 0, 0, 0.6);
  display: flex;
  align-items: center;
  justify-content: center;
  z-index: 1000;
  padding: 20px;
}

.modal-container {
  background: var(--card-background);
  border-radius: 12px;
  width: 100%;
  max-width: 800px;
  max-height: 90vh;
  display: flex;
  flex-direction: column;
  box-shadow: 0 10px 40px rgba(0, 0, 0, 0.3);
}

.modal-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 24px;
  border-bottom: 1px solid var(--border-color);
}

.header-info {
  display: flex;
  align-items: center;
  gap: 12px;
}

.header-info h2 {
  margin: 0;
  font-size: 24px;
  color: var(--text-primary);
}

.node-type-badge {
  padding: 4px 12px;
  border-radius: 12px;
  font-size: 12px;
  font-weight: 500;
  text-transform: capitalize;
}

.type-start { background: #dbeafe; color: #1e40af; }
.type-process { background: #ddd6fe; color: #5b21b6; }
.type-decision { background: #fed7aa; color: #c2410c; }
.type-end { background: #d1fae5; color: #065f46; }

.close-btn {
  background: none;
  border: none;
  font-size: 32px;
  cursor: pointer;
  color: var(--text-secondary);
  padding: 0;
  width: 32px;
  height: 32px;
  display: flex;
  align-items: center;
  justify-content: center;
}

.close-btn:hover {
  color: var(--text-primary);
}

.progress-section {
  padding: 16px 24px;
  background: var(--surface-color);
  border-bottom: 1px solid var(--border-color);
}

.progress-info {
  display: flex;
  justify-content: space-between;
  margin-bottom: 8px;
  font-size: 14px;
  color: var(--text-secondary);
}

.progress-text {
  font-weight: 600;
  color: var(--text-primary);
}

.progress-bar {
  height: 8px;
  background: var(--border-color);
  border-radius: 4px;
  overflow: hidden;
}

.progress-fill {
  height: 100%;
  transition: width 0.3s ease, background-color 0.3s ease;
}

.progress-low { background: #ef4444; }
.progress-medium { background: #f59e0b; }
.progress-high { background: #10b981; }

.modal-body {
  flex: 1;
  overflow-y: auto;
  padding: 24px;
}

.tasks-section {
  margin-bottom: 32px;
}

.tasks-section h3 {
  margin: 0 0 16px 0;
  color: var(--text-primary);
  font-size: 18px;
}

.empty-state {
  text-align: center;
  padding: 40px 20px;
  color: var(--text-secondary);
}

.tasks-list {
  display: flex;
  flex-direction: column;
  gap: 12px;
}

.task-item {
  display: flex;
  gap: 12px;
  padding: 16px;
  background: var(--surface-color);
  border: 1px solid var(--border-color);
  border-radius: 8px;
  transition: all 0.2s;
}

.task-item:hover {
  background: var(--hover-color, var(--surface-color));
  border-color: var(--border-hover, var(--border-color));
}

.task-completed {
  opacity: 0.6;
}

.task-completed .task-content h4 {
  text-decoration: line-through;
}

.task-checkbox {
  padding-top: 2px;
}

.task-checkbox input[type="checkbox"] {
  width: 20px;
  height: 20px;
  cursor: pointer;
}

.task-checkbox input[type="checkbox"]:disabled {
  cursor: not-allowed;
  opacity: 0.5;
}

.task-content {
  flex: 1;
}

.task-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 8px;
}

.task-header h4 {
  margin: 0;
  font-size: 16px;
  color: var(--text-primary);
}

.task-status {
  padding: 2px 8px;
  border-radius: 6px;
  font-size: 12px;
  font-weight: 500;
}

.status-pending { background: #fee2e2; color: #991b1b; }
.status-in_progress { background: #dbeafe; color: #1e40af; }
.status-completed { background: #d1fae5; color: #065f46; }

.task-description {
  margin: 0 0 12px 0;
  color: var(--text-secondary);
  font-size: 14px;
}

.task-meta {
  display: flex;
  align-items: center;
  gap: 8px;
}

.assigned-to {
  display: flex;
  align-items: center;
  gap: 8px;
  font-size: 14px;
  color: var(--text-secondary);
}

.avatar {
  width: 24px;
  height: 24px;
  border-radius: 50%;
  background: var(--primary-color);
  color: white;
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 12px;
  font-weight: 500;
}

.assign-select {
  padding: 4px 8px;
  border: 1px solid var(--border-color);
  border-radius: 4px;
  font-size: 14px;
  background: var(--card-background);
  color: var(--text-primary);
  cursor: pointer;
}

.task-actions {
  display: flex;
  gap: 8px;
}

.btn-icon {
  background: none;
  border: none;
  cursor: pointer;
  font-size: 16px;
  padding: 4px 8px;
  border-radius: 4px;
  transition: background 0.2s;
}

.btn-icon:hover {
  background: var(--surface-color);
}

.btn-icon.delete:hover {
  background: #fee2e2;
}

.add-task-section h3 {
  margin: 0 0 16px 0;
  color: var(--text-primary);
  font-size: 18px;
}

.task-form {
  display: flex;
  flex-direction: column;
  gap: 12px;
}

.form-row {
  display: flex;
  gap: 12px;
}

.form-input,
.form-textarea,
.form-select {
  flex: 1;
  padding: 8px 12px;
  border: 1px solid var(--border-color);
  border-radius: 6px;
  font-size: 14px;
  font-family: inherit;
  background: var(--card-background);
  color: var(--text-primary);
}

.form-input:focus,
.form-textarea:focus,
.form-select:focus {
  outline: none;
  border-color: var(--primary-color);
  box-shadow: 0 0 0 2px rgba(99, 102, 241, 0.1);
}

.form-actions {
  display: flex;
  gap: 12px;
  justify-content: flex-end;
}

.btn-primary,
.btn-secondary {
  padding: 8px 16px;
  border: none;
  border-radius: 6px;
  font-size: 14px;
  font-weight: 500;
  cursor: pointer;
  transition: all 0.2s;
}

.btn-primary {
  background: var(--primary-color);
  color: white;
}

.btn-primary:hover {
  background: var(--primary-dark);
}

.btn-secondary {
  background: var(--surface-color);
  color: var(--text-primary);
  border: 1px solid var(--border-color);
}

.btn-secondary:hover {
  background: var(--hover-color, var(--surface-color));
}
</style>
