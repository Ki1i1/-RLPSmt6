import axios from 'axios'

const baseURL = import.meta.env.VITE_API_BASE_URL || 'http://localhost:3000'
const api = axios.create({ baseURL, timeout: 8000 })
const cacheKey = `sensornodes:dashboard:v1:${baseURL}`

function isDashboardSnapshot(snapshot) {
  return Array.isArray(snapshot?.sensors) && snapshot.sensors.every((sensor) => (
    typeof sensor?.id === 'string' &&
    typeof sensor.deviceName === 'string' &&
    Number.isFinite(sensor.reading?.current) &&
    typeof sensor.reading.unit === 'string' &&
    typeof sensor.reading.isOptimal === 'boolean'
  )) && typeof snapshot.light?.isOn === 'boolean' &&
    Number.isFinite(snapshot.light.brightness)
}

export async function fetchDashboard(signal) {
  const [sensorResponse, lightResponse] = await Promise.all([
    api.get('/sensor/web/analytics', { signal }),
    api.get('/light-control/web', { signal }),
  ])
  const snapshot = { sensors: sensorResponse.data, light: lightResponse.data }

  if (!isDashboardSnapshot(snapshot)) {
    throw new Error('Format data dashboard tidak sesuai kontrak BFF.')
  }

  return snapshot
}

export function readDashboardCache() {
  try {
    const snapshot = JSON.parse(localStorage.getItem(cacheKey))
    return isDashboardSnapshot(snapshot) ? snapshot : null
  } catch {
    return null
  }
}

export function writeDashboardCache(snapshot) {
  try {
    localStorage.setItem(cacheKey, JSON.stringify(snapshot))
  } catch {
    // Data tetap dapat ditampilkan ketika penyimpanan browser dibatasi.
  }
}
