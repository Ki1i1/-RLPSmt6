import { useState } from 'react'
import PrimaryButton from './components/PrimaryButton'
import StatusCard from './components/StatusCard'

// Data simulasi BFF untuk pengujian visual Modul 3.
const sensorList = [
  { id: 'S1', title: 'Suhu Ruangan', value: 24.5, unit: '°C', status: 'OK' },
  { id: 'S2', title: 'Suhu Perangkat', value: 38.2, unit: '°C', status: 'WARNING' },
  { id: 'S3', title: 'Suhu Inti', value: 88.2, unit: '°C', status: 'DANGER' },
]

export default function App() {
  const [isCompact, setIsCompact] = useState(false)

  return (
    <div className="min-h-screen bg-tech-bg font-sans text-slate-900">
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
          <span className="inline-flex items-center gap-2 rounded-full border border-slate-200 px-3 py-1.5 text-xs font-medium text-slate-600">
            <span aria-hidden="true" className="h-2 w-2 rounded-full bg-tech-primary" />
            Mode simulasi
          </span>
        </div>
      </header>

      <main className="mx-auto max-w-6xl p-safe-pad pb-12 md:pt-12">
        <div className="mb-8 max-w-2xl">
          <p className="mb-3 text-xs font-semibold uppercase tracking-[0.2em] text-tech-primary">
            Dashboard / Overview
          </p>
          <h1 className="text-3xl font-bold tracking-tight md:text-4xl">
            Dashboard Monitoring Suhu
          </h1>
          <p className="mt-3 text-sm leading-6 text-slate-500">
            Pantau kondisi sensor dalam satu tampilan. Kenali suhu normal,
            peringatan, dan kondisi kritis melalui indikator status.
          </p>
        </div>

        <section aria-labelledby="sensor-heading">
          <div className="mb-4 flex flex-wrap items-center justify-between gap-2">
            <h2 id="sensor-heading" className="text-sm font-semibold text-slate-700">
              Ringkasan sensor
            </h2>
            <p className="text-xs text-slate-500">3 sensor · Data contoh BFF</p>
          </div>

          <div id="sensor-grid" className="grid grid-cols-1 gap-4 md:grid-cols-2 lg:grid-cols-3">
            {sensorList.map((sensor) => (
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

        <footer className="mt-10 flex flex-col gap-2 border-t border-slate-200 pt-5 text-xs leading-5 text-slate-500 sm:flex-row sm:justify-between">
          <p>SensorNodes · Prototipe UI Modul 3</p>
          <p>Data simulasi · Belum terhubung ke perangkat IoT</p>
        </footer>
      </main>
    </div>
  )
}
