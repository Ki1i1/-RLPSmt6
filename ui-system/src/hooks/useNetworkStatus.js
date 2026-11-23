import { useEffect, useState } from 'react'

export default function useNetworkStatus() {
  const [network, setNetwork] = useState(() => ({
    isOnline: navigator.onLine,
    revision: 0,
  }))

  useEffect(() => {
    const updateNetworkStatus = () => {
      const isOnline = navigator.onLine
      setNetwork(({ revision }) => ({ isOnline, revision: revision + 1 }))
    }

    window.addEventListener('online', updateNetworkStatus)
    window.addEventListener('offline', updateNetworkStatus)

    return () => {
      window.removeEventListener('online', updateNetworkStatus)
      window.removeEventListener('offline', updateNetworkStatus)
    }
  }, [])

  return network
}
