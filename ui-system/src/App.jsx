import { useState } from 'react'
import PrimaryButton from './components/PrimaryButton'
import StatusCard from './components/StatusCard'
import useDashboard from './hooks/useDashboard'

// Bawaan PWA saat belum ada data BFF yang tersimpan.
const demoSensors = [
  { id: 'S1', title: 'Suhu Ruangan Q2.1', value: 24.5, unit: '°C', status: 'OK' },
  { id: 'S2', title: 'Suhu Ruangan Q2.2', value: 28.2, unit: '°C', status: 'WARNING' },
  { id: 'S3', title: 'Suhu Ruangan Q2.3', value: 33.2, unit: '°C', status: 'DANGER' },
]

export default function App() {
  const [isCompact, setIsCompact] = useState(false)
  const { snapshot, isOnline, isLoading, isConnected, failed, refresh } = useDashboard()
  const sensors = snapshot
    ? snapshot.sensors.map(({ id, deviceName, reading }) => ({
        id,
        title: deviceName,
        value: reading.current,
        unit: reading.unit,
        status: reading.isOptimal ? 'OK' : 'DANGER',
      }))
    : isLoading ? [] : demoSensors
  const light = snapshot?.light
  const sensorSource = isConnected ? 'Data BFF' : snapshot ? 'Data terakhir dari BFF' : 'Data contoh'

  return (
    <div className="min-h-screen bg-tech-bg font-sans text-slate-900">
      {!isOnline && (
        <div role="alert" className="sticky top-0 z-50 bg-red-600 px-5 py-3 text-center text-sm font-medium leading-6 text-white shadow-sm">
          {snapshot
            ? 'Anda sedang offline. Menampilkan data BFF terakhir dari cache lokal.'
            : 'Anda sedang offline. Menampilkan data contoh dari cache lokal aplikasi.'}
        </div>
      )}
      <header className="border-b border-slate-200 bg-white">
        <div className="mx-auto flex max-w-6xl flex-wrap items-center justify-between gap-4 p-safe-pad md:py-6">
          <div>
            <p className="text-lg font-black tracking-tight sm:text-xl">
              SensorNodes <span className="text-tech-primary">Controller</span>
            </p>
            <p className="mt-1 text-[10px] font-semibold uppercase tracking-[0.2em] text-slate-500">
              Smart monitoring system
            </p>
          </div>
          <span role="status" className="inline-flex items-center gap-2 rounded-full border border-slate-200 px-3 py-1.5 text-xs font-medium text-slate-600">
            <span aria-hidden="true" className={`h-2 w-2 rounded-full ${isOnline ? 'bg-tech-primary' : 'bg-tech-danger'}`} />
            {isOnline ? 'Online' : 'Offline'}{isConnected && ' · BFF terhubung'}
          </span>
        </div>
      </header>

      <main className="mx-auto max-w-6xl p-safe-pad pb-12 md:pt-12">
        <div className="mb-8 max-w-2xl">
          <p className="mb-3 text-xs font-semibold uppercase tracking-[0.2em] text-tech-primary">
            Dashboard
          </p>
          <h1 className="text-3xl font-bold tracking-tight md:text-4xl">
            Dashboard Monitoring Suhu
          </h1>
          <p className="mt-3 text-sm leading-6 text-slate-500">
            Pantau kondisi sensor dalam satu tampilan. Kenali suhu normal,
            peringatan, dan kondisi kritis melalui indikator status.
          </p>
        </div>

        <div className="mb-6 flex flex-wrap items-center justify-between gap-3">
          <div role="status" className="text-sm text-slate-600">
            {isLoading && 'Memuat data BFF…'}
            {failed && 'Data BFF gagal dimuat. Coba muat ulang.'}
          </div>
          <PrimaryButton disabled={!isOnline || isLoading} onClick={refresh}>
            Muat ulang data
          </PrimaryButton>
        </div>

        <section aria-labelledby="sensor-heading">
          <div className="mb-4 flex flex-wrap items-center justify-between gap-2">
            <h2 id="sensor-heading" className="text-sm font-semibold text-slate-700">
              Ringkasan sensor
            </h2>
            {(!isLoading || snapshot) && (
              <p className="text-xs text-slate-500">{sensors.length} sensor · {sensorSource}</p>
            )}
          </div>

          <div id="sensor-grid" className="grid grid-cols-1 gap-4 md:grid-cols-2 lg:grid-cols-3">
            {sensors.map((sensor) => (
              <StatusCard key={sensor.id} {...sensor} isCompact={isCompact} />
            ))}
          </div>

          <div className="mt-6 flex flex-col items-start justify-between gap-4 rounded-xl border border-slate-200 bg-white p-safe-pad sm:flex-row sm:items-center">
            <div>
              <p role="status" className="text-sm font-semibold text-slate-700">
                Tampilan {isCompact ? 'ringkas' : 'detail'}
              </p>
              <p className="mt-1 text-xs leading-5 text-slate-500">
                {isCompact
                  ? 'Fokus pada nilai dan status untuk pembacaan cepat di lapangan.'
                  : 'Detail integrity status ditampilkan pada setiap kartu sensor.'}
              </p>
            </div>
            <PrimaryButton
              aria-controls="sensor-grid"
              aria-pressed={isCompact}
              className="w-full shrink-0 sm:w-auto"
              onClick={() => setIsCompact((current) => !current)}
            >
              {isCompact ? 'Tampilkan detail' : 'Gunakan tampilan ringkas'}
            </PrimaryButton>
          </div>
        </section>

        <section aria-labelledby="light-heading" className="mt-6 rounded-xl border border-slate-200 bg-white p-safe-pad">
          <h2 id="light-heading" className="text-sm font-semibold text-slate-700">Status lampu</h2>
          {light ? (
            <dl className="mt-3 grid grid-cols-2 gap-3">
              <div>
                <dt className="text-xs text-slate-500">Kondisi</dt>
                <dd className="text-sm font-semibold">{light.isOn ? 'Menyala' : 'Mati'}</dd>
              </div>
              <div>
                <dt className="text-xs text-slate-500">Kecerahan</dt>
                <dd className="text-sm font-semibold">{light.brightness}%</dd>
              </div>
            </dl>
          ) : (
            <p className="mt-3 text-sm text-slate-500">Data lampu belum tersedia.</p>
          )}
        </section>

        <footer className="mt-10 border-t border-slate-200 pt-5 text-xs leading-5 text-slate-500">
          <p>SensorNodes · Progressive Web App · Modul 6</p>
        </footer>
      </main>
    </div>
  )
}
