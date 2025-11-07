<template>
  <nav class="navbar">
    <div class="navbar-content">
      <div class="navbar-brand">
        <h1>Workflow Manager</h1>
      </div>

      <div class="navbar-menu">
        <router-link to="/" class="nav-link">Workflows</router-link>
      </div>

      <div class="navbar-user">
        <div class="user-info">
          <button @click="toggleTheme" class="theme-toggle" :title="isDark ? 'Light Mode' : 'Dark Mode'">
            {{ isDark ? '☀️' : '🌙' }}
          </button>
          <span>{{ authStore.user?.name }}</span>
          <button @click="logout" class="btn-secondary">Logout</button>
        </div>
      </div>
    </div>
  </nav>
</template>

<script setup lang="ts">
import { ref, onMounted } from 'vue'
import { useAuthStore } from '@/stores/auth'
import { useRouter } from 'vue-router'

const authStore = useAuthStore()
const router = useRouter()
const isDark = ref(false)

const logout = () => {
  authStore.logout()
  router.push('/login')
}

const toggleTheme = () => {
  isDark.value = !isDark.value
  const theme = isDark.value ? 'dark' : 'light'
  document.documentElement.setAttribute('data-theme', theme)
  localStorage.setItem('theme', theme)
}

onMounted(() => {
  const savedTheme = localStorage.getItem('theme')
  if (savedTheme === 'dark') {
    isDark.value = true
    document.documentElement.setAttribute('data-theme', 'dark')
  } else if (savedTheme === 'light') {
    isDark.value = false
    document.documentElement.setAttribute('data-theme', 'light')
  } else {
    // Default to system preference
    const prefersDark = window.matchMedia('(prefers-color-scheme: dark)').matches
    isDark.value = prefersDark
    document.documentElement.setAttribute('data-theme', prefersDark ? 'dark' : 'light')
  }
})
</script>

<style scoped>
.navbar {
  background: var(--card-background);
  border-bottom: 1px solid var(--border-color);
  padding: 0 24px;
  height: 64px;
  display: flex;
  align-items: center;
  box-shadow: 0 1px 3px rgba(0, 0, 0, 0.1);
}

.navbar-content {
  display: flex;
  align-items: center;
  justify-content: space-between;
  width: 100%;
}

.navbar-brand h1 {
  font-size: 20px;
  font-weight: 600;
  color: var(--primary-color);
}

.navbar-menu {
  display: flex;
  gap: 24px;
}

.nav-link {
  color: var(--text-secondary);
  text-decoration: none;
  font-weight: 500;
  padding: 8px 0;
  border-bottom: 2px solid transparent;
  transition: all 0.2s ease;
}

.nav-link:hover,
.nav-link.router-link-active {
  color: var(--primary-color);
  border-bottom-color: var(--primary-color);
}

.navbar-user {
  display: flex;
  align-items: center;
}

.user-info {
  display: flex;
  align-items: center;
  gap: 12px;
}

.user-info span {
  font-weight: 500;
  color: var(--text-primary);
}

.theme-toggle {
  background: var(--secondary-color);
  border: 1px solid var(--border-color);
  border-radius: 6px;
  padding: 8px 12px;
  font-size: 18px;
  cursor: pointer;
  transition: all 0.2s ease;
}

.theme-toggle:hover {
  background: var(--hover-background);
  transform: scale(1.1);
}
</style>