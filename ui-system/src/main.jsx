import { StrictMode } from 'react'
import { createRoot } from 'react-dom/client'
import { registerSW } from 'virtual:pwa-register'
import './index.css'
import App from './App.jsx'

// Plugin menonaktifkan service worker pada mode dev; uji offline dengan build + preview.
registerSW({
  onRegisterError(error) {
    console.error('Pendaftaran service worker gagal:', error)
  },
})

createRoot(document.getElementById('root')).render(
  <StrictMode>
    <App />
  </StrictMode>,
)
