<template>
  <div class="zoom-widget">
    <button @click="zoomOut" class="zoom-btn" :disabled="!canZoomOut">-</button>
    <div class="zoom-display">{{ Math.round(canvasStore.canvasState.position.zoom * 100) }}%</div>
    <button @click="zoomIn" class="zoom-btn" :disabled="!canZoomIn">+</button>
    <button @click="resetZoom" class="zoom-btn reset">Reset</button>
  </div>
</template>

<script setup lang="ts">
import { computed } from 'vue'
import { useCanvasStore } from '@/stores/canvas'

const canvasStore = useCanvasStore()

const canZoomOut = computed(() => canvasStore.canvasState.position.zoom > 0.1)
const canZoomIn = computed(() => canvasStore.canvasState.position.zoom < 3)

const zoomOut = () => {
  if (canZoomOut.value) {
    const newZoom = Math.max(0.1, canvasStore.canvasState.position.zoom - 0.1)
    canvasStore.setZoom(newZoom)
  }
}

const zoomIn = () => {
  if (canZoomIn.value) {
    const newZoom = Math.min(3, canvasStore.canvasState.position.zoom + 0.1)
    canvasStore.setZoom(newZoom)
  }
}

const resetZoom = () => {
  canvasStore.resetCanvas()
}
</script>

<style scoped>
.zoom-widget {
  position: absolute;
  bottom: 16px;
  right: 16px;
  display: flex;
  align-items: center;
  background: var(--card-background);
  backdrop-filter: blur(4px);
  border: 1px solid var(--border-color);
  border-radius: 8px;
  overflow: hidden;
  z-index: 100;
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.1);
}

.zoom-btn {
  padding: 8px 12px;
  border: none;
  background: transparent;
  color: var(--text-primary);
  font-size: 14px;
  font-weight: 500;
  cursor: pointer;
  transition: background 0.2s ease;
}

.zoom-btn:hover:not(:disabled) {
  background: var(--surface-color);
}

.zoom-btn:disabled {
  opacity: 0.5;
  cursor: not-allowed;
}

.zoom-btn.reset {
  border-left: 1px solid var(--border-color);
  font-size: 12px;
}

.zoom-display {
  padding: 8px 12px;
  font-size: 12px;
  font-weight: 600;
  color: var(--text-primary);
  background: var(--input-background);
  min-width: 50px;
  text-align: center;
}
</style>