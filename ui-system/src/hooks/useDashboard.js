import { useEffect, useState } from 'react'
import { fetchDashboard, readDashboardCache, writeDashboardCache } from '../api/dashboard'
import useNetworkStatus from './useNetworkStatus'

export default function useDashboard() {
  const { isOnline, revision } = useNetworkStatus()
  const [refreshCount, setRefreshCount] = useState(0)
  const [result, setResult] = useState(() => ({
    snapshot: readDashboardCache(),
    requestId: null,
    failed: false,
  }))
  const requestId = `${revision}:${refreshCount}`

  useEffect(() => {
    if (!isOnline) return

    const controller = new AbortController()
    const { signal } = controller
    fetchDashboard(signal)
      .then((snapshot) => {
        if (signal.aborted) return
        writeDashboardCache(snapshot)
        setResult({ snapshot, requestId, failed: false })
      })
      .catch(() => {
        if (signal.aborted) return
        setResult((previous) => ({ ...previous, requestId, failed: true }))
      })

    return () => controller.abort()
  }, [isOnline, requestId])

  const isLoading = isOnline && result.requestId !== requestId
  return {
    snapshot: result.snapshot,
    isOnline,
    isLoading,
    failed: isOnline && !isLoading && result.failed,
    isConnected: isOnline && !isLoading && !result.failed,
    refresh: () => setRefreshCount((count) => count + 1),
  }
}
