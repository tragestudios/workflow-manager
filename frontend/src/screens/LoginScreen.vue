<template>
  <div class="login-screen">
    <div class="login-container">
      <div class="login-card card">
        <h2>{{ isLogin ? 'Login to Workflow Manager' : 'Register for Workflow Manager' }}</h2>

        <form @submit.prevent="isLogin ? handleLogin() : handleRegister()" class="login-form">
          <div v-if="!isLogin" class="form-group">
            <label for="name">Name</label>
            <input
              id="name"
              v-model="name"
              type="text"
              required
              placeholder="Enter your full name"
            />
          </div>

          <div class="form-group">
            <label for="email">Email</label>
            <input
              id="email"
              v-model="email"
              type="email"
              required
              placeholder="Enter your email"
            />
          </div>

          <div class="form-group">
            <label for="password">Password</label>
            <input
              id="password"
              v-model="password"
              type="password"
              required
              placeholder="Enter your password"
            />
          </div>

          <button type="submit" class="btn-primary login-btn" :disabled="loading">
            {{ loading ? (isLogin ? 'Logging in...' : 'Registering...') : (isLogin ? 'Login' : 'Register') }}
          </button>

          <div v-if="error" class="error-message">
            {{ error }}
          </div>

          <div class="auth-switch">
            <p v-if="isLogin">
              Don't have an account?
              <button type="button" @click="isLogin = false" class="switch-btn">Register here</button>
            </p>
            <p v-else>
              Already have an account?
              <button type="button" @click="isLogin = true" class="switch-btn">Login here</button>
            </p>
          </div>
        </form>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref } from 'vue'
import { useRouter } from 'vue-router'
import { useAuthStore } from '@/stores/auth'

const router = useRouter()
const authStore = useAuthStore()

const isLogin = ref(true)
const name = ref('')
const email = ref('')
const password = ref('')
const loading = ref(false)
const error = ref('')

const handleLogin = async () => {
  if (!email.value || !password.value) return

  loading.value = true
  error.value = ''

  try {
    await authStore.login(email.value, password.value)
    router.push('/')
  } catch (err: any) {
    error.value = err.response?.data?.error || 'Login failed'
  } finally {
    loading.value = false
  }
}

const handleRegister = async () => {
  if (!name.value || !email.value || !password.value) return

  loading.value = true
  error.value = ''

  try {
    await authStore.register(email.value, name.value, password.value)
    isLogin.value = true
    error.value = ''
    name.value = ''
    email.value = ''
    password.value = ''
    alert('Registration successful! Please login with your credentials.')
  } catch (err: any) {
    error.value = err.response?.data?.error || 'Registration failed'
  } finally {
    loading.value = false
  }
}
</script>

<style scoped>
.login-screen {
  height: 100vh;
  display: flex;
  align-items: center;
  justify-content: center;
  background: var(--surface-color);
}

.login-container {
  width: 100%;
  max-width: 400px;
  padding: 24px;
}

.login-card {
  padding: 32px;
  text-align: center;
}

.login-card h2 {
  margin-bottom: 32px;
  color: var(--text-primary);
  font-weight: 600;
}

.login-form {
  display: flex;
  flex-direction: column;
  gap: 20px;
}

.form-group {
  text-align: left;
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

.login-btn {
  width: 100%;
  padding: 12px;
  font-size: 16px;
  margin-top: 8px;
}

.login-btn:disabled {
  opacity: 0.6;
  cursor: not-allowed;
}

.error-message {
  color: var(--error-color);
  font-size: 14px;
  margin-top: 8px;
}

.auth-switch {
  margin-top: 24px;
  text-align: center;
}

.auth-switch p {
  color: var(--text-secondary);
  font-size: 14px;
  margin: 0;
}

.switch-btn {
  background: none;
  border: none;
  color: var(--primary-color);
  cursor: pointer;
  text-decoration: underline;
  font-size: 14px;
  padding: 0;
  margin-left: 4px;
}

.switch-btn:hover {
  color: var(--primary-dark);
}
</style>