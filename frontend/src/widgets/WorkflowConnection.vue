<template>
  <svg class="workflow-connection" :class="{ selected }">
    <defs>
      <marker
        id="arrowhead"
        markerWidth="10"
        markerHeight="7"
        refX="9"
        refY="3.5"
        orient="auto"
      >
        <polygon
          points="0 0, 10 3.5, 0 7"
          :fill="strokeColor"
        />
      </marker>
    </defs>
    <path
      :d="pathData"
      :stroke="strokeColor"
      :stroke-width="strokeWidth"
      fill="none"
      :marker-end="markerEnd"
    />
    <text
      v-if="connection.label"
      :x="labelPosition.x"
      :y="labelPosition.y"
      class="connection-label"
      text-anchor="middle"
    >
      {{ connection.label }}
    </text>
  </svg>
</template>

<script setup lang="ts">
import { computed } from 'vue'
import type { Connection, Node } from '@/models'

interface Props {
  connection: Connection
  nodes: Map<string, Node>
  selected: boolean
}

interface Emits {
  select: [connectionId: string]
  delete: [connectionId: string]
}

const props = defineProps<Props>()
const emit = defineEmits<Emits>()

const sourceNode = computed(() => props.nodes.get(props.connection.sourceNodeId))
const targetNode = computed(() => props.nodes.get(props.connection.targetNodeId))

const pathData = computed(() => {
  if (!sourceNode.value || !targetNode.value) return ''

  const sourcePos = sourceNode.value.position
  const targetPos = targetNode.value.position

  if (!sourcePos || !targetPos) return ''

  // Node dimensions (width: 200px, height: 80px)
  const nodeWidth = 200
  const nodeHeight = 80

  // Default output connector position (right side, center)
  let startX = sourcePos.x + nodeWidth / 2
  let startY = sourcePos.y

  // Adjust start position for decision node outputs
  if (sourceNode.value.type === 'decision' && props.connection.sourceConnector) {
    if (props.connection.sourceConnector === 'output-yes') {
      // Yes connector is at 30% height from center
      startY = sourcePos.y - nodeHeight / 2 + (nodeHeight * 0.3)
    } else if (props.connection.sourceConnector === 'output-no') {
      // No connector is at 70% height from center
      startY = sourcePos.y - nodeHeight / 2 + (nodeHeight * 0.7)
    }
  }

  // Input connector position (left side, center)
  const endX = targetPos.x - nodeWidth / 2
  const endY = targetPos.y

  const controlOffset = Math.abs(endX - startX) * 0.3

  return `M ${startX} ${startY} C ${startX + controlOffset} ${startY} ${endX - controlOffset} ${endY} ${endX} ${endY}`
})

const strokeColor = computed(() => {
  return props.selected ? 'var(--primary-color)' : '#6b7280'
})

const strokeWidth = computed(() => {
  return props.selected ? '3' : '2'
})

const markerEnd = computed(() => {
  return 'url(#arrowhead)'
})

const labelPosition = computed(() => {
  if (!sourceNode.value || !targetNode.value) return { x: 0, y: 0 }

  const sourcePos = sourceNode.value.position
  const targetPos = targetNode.value.position

  if (!sourcePos || !targetPos) return { x: 0, y: 0 }

  const nodeWidth = 200

  const startX = sourcePos.x + nodeWidth / 2
  const startY = sourcePos.y
  const endX = targetPos.x - nodeWidth / 2
  const endY = targetPos.y

  return {
    x: (startX + endX) / 2,
    y: (startY + endY) / 2 - 8
  }
})

const handleClick = (event: MouseEvent) => {
  event.stopPropagation()
  console.log('Connection clicked - selecting:', props.connection.id)
  emit('select', props.connection.id)
}

const handleDelete = (event: MouseEvent) => {
  event.stopPropagation()
  event.preventDefault()
  console.log('Delete button clicked for connection:', props.connection.id)
  emit('delete', props.connection.id)
}
</script>

<style scoped>
.workflow-connection {
  position: absolute;
  top: 0;
  left: 0;
  width: 100%;
  height: 100%;
  pointer-events: none;
  z-index: -1;
}

.workflow-connection path {
  pointer-events: stroke;
  cursor: default;
  transition: all 0.2s ease;
}

.workflow-connection path:hover {
  cursor: default;
}

.workflow-connection.selected path {
  filter: drop-shadow(0 2px 4px rgba(99, 102, 241, 0.3));
}

.connection-label {
  font-size: 12px;
  font-weight: 500;
  fill: var(--text-secondary);
  pointer-events: none;
}

svg {
  overflow: visible;
}

</style>