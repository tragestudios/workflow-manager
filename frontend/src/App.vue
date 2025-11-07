<template>
  <div id="app">
    <NavBar v-if="isAuthenticated" />
    <main class="main-content">
      <router-view />
    </main>
  </div>
</template>

<script setup lang="ts">
import { computed, onMounted } from 'vue'
import { useAuthStore } from '@/stores/auth'
import NavBar from '@/components/NavBar.vue'

const authStore = useAuthStore()
const isAuthenticated = computed(() => authStore.isAuthenticated)

// Initialize auth state on app mount
onMounted(async () => {
  // Only load if we have a token but no user data
  if (!authStore.user && authStore.token) {
    try {
      await authStore.loadUserFromToken()
    } catch (error) {
      console.error('Failed to initialize auth state:', error)
    }
  }
})
</script>

<style scoped>
#app {
  height: 100vh;
  display: flex;
  flex-direction: column;
}

.main-content {
  flex: 1;
  overflow: hidden;
}
</style>