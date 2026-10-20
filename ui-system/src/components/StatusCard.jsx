const statusStyles = {
  OK: {
    className: 'border-tech-primary bg-tech-primary/5 text-tech-primary',
    label: 'Normal',
    message: 'SYSTEM SECURE',
  },
  WARNING: {
    className: 'border-brand-warning bg-brand-warning/5 text-brand-warning',
    label: 'Peringatan',
    message: 'ACTION REQUIRED',
  },
  DANGER: {
    className: 'border-tech-danger bg-tech-danger/5 text-tech-danger',
    label: 'Kritis',
    message: 'ACTION REQUIRED',
  },
  default: {
    className: 'border-slate-300 bg-tech-bg text-slate-500',
    label: 'Belum diketahui',
    message: 'STATUS UNAVAILABLE',
  },
}

export default function StatusCard({
  title,
  label,
  value,
  unit = '',
  status = 'default',
  isCompact = false,
}) {
  // BFF Modul 2 memakai WARN; prototipe Modul 3 memakai WARNING.
  const normalizedStatus = status === 'WARN' ? 'WARNING' : status
  const currentStyle = Object.hasOwn(statusStyles, normalizedStatus)
    ? statusStyles[normalizedStatus]
    : statusStyles.default

  return (
    <article
      aria-label={title ?? label}
      className={`rounded-xl border-l-8 p-safe-area shadow-sm transition-colors ${currentStyle.className}`}
    >
      <div className="flex flex-wrap items-center justify-between gap-3">
        <h3 className="text-xs font-bold uppercase tracking-widest text-slate-600">
          {title ?? label}
        </h3>
        <span className="inline-flex items-center gap-1.5 rounded-full bg-white/80 px-2.5 py-1 text-xs font-semibold">
          <span aria-hidden="true" className="h-1.5 w-1.5 rounded-full bg-current" />
          {currentStyle.label}
        </span>
      </div>

      <p className="mt-6 flex items-baseline gap-1.5">
        <span className="text-5xl font-black tabular-nums tracking-tight">
          {value ?? '—'}
        </span>
        <span className="text-lg font-medium">{unit}</span>
      </p>

      {!isCompact && (
        <div className="mt-6 flex flex-wrap items-center justify-between gap-2 border-t border-black/5 pt-4 text-[10px]">
          <span className="font-semibold tracking-wider text-slate-500">
            INTEGRITY STATUS
          </span>
          <span className="rounded border border-black/5 bg-white/70 px-2 py-1 font-bold tracking-wide">
            {currentStyle.message}
          </span>
        </div>
      )}
    </article>
  )
}
