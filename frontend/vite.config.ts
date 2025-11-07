import { defineConfig } from 'vite'
import vue from '@vitejs/plugin-vue'
import { resolve } from 'path'

export default defineConfig({
  plugins: [vue()],
  resolve: {
    alias: {
      '@': resolve(__dirname, 'src'),
      '@/screens': resolve(__dirname, 'src/screens'),
      '@/services': resolve(__dirname, 'src/services'),
      '@/widgets': resolve(__dirname, 'src/widgets'),
      '@/models': resolve(__dirname, 'src/models'),
      '@/utils': resolve(__dirname, 'src/utils'),
      '@/components': resolve(__dirname, 'src/components'),
      '@/stores': resolve(__dirname, 'src/stores')
    }
  },
  server: {
    port: 5173,
    host: true
  }
})