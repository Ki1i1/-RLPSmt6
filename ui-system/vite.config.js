import react from '@vitejs/plugin-react'
import { defineConfig } from 'vite'
import { VitePWA } from 'vite-plugin-pwa'
import tailwindConfig from './tailwind.config.js'

const techColors = tailwindConfig.theme.extend.colors.tech

// https://vite.dev/config/
export default defineConfig({
  plugins: [
    react(),
    {
      name: 'sensor-theme-color',
      transformIndexHtml() {
        return [{ tag: 'meta', attrs: { name: 'theme-color', content: techColors.primary }, injectTo: 'head' }]
      },
    },
    VitePWA({
      registerType: 'autoUpdate',
      // Plugin mendeteksi virtual:pwa-register di main.jsx tanpa registrasi ganda.
      injectRegister: 'auto',
      workbox: {
        globPatterns: ['**/*.{js,css,html,ico,png,svg}'],
        cleanupOutdatedCaches: true,
        navigateFallback: 'index.html',
      },
      manifest: {
        id: '/',
        name: 'SensorNodes Controller - Monitoring Suhu',
        short_name: 'SensorNodes',
        description: 'Dashboard monitoring suhu yang dapat digunakan secara offline.',
        lang: 'id',
        start_url: '/',
        scope: '/',
        display: 'standalone',
        theme_color: techColors.primary,
        background_color: techColors.bg,
        icons: [
          { src: 'pwa-192x192.png', sizes: '192x192', type: 'image/png' },
          { src: 'pwa-512x512.png', sizes: '512x512', type: 'image/png' },
          { src: 'pwa-maskable-512x512.png', sizes: '512x512', type: 'image/png', purpose: 'maskable' },
        ],
      },
    }),
  ],
})
