import type { Alert } from '../types/domain';
import AppleCard from './AppleCard';

export default function AlertList({ alerts, onOpenVehicle }: { alerts: Alert[]; onOpenVehicle?: (vehicleId: string) => void }) {
  return (
    <AppleCard>
      <div className="flex items-center justify-between">
        <h2 className="text-lg font-semibold text-slate-950">Alerts</h2>
        <span className="text-sm text-slate-500">{alerts.length}</span>
      </div>
      <div className="mt-5 space-y-3">
        {alerts.length === 0 && <p className="text-sm text-slate-500">No urgent items right now.</p>}
        {alerts.map((alert) => (
          <button key={`${alert.category}-${alert.entityId}`} onClick={() => onOpenVehicle?.(alert.vehicleId)} className="w-full rounded-2xl border border-slate-100 p-4 text-left transition hover:bg-slate-50">
            <div className="flex items-start justify-between gap-4">
              <div>
                <div className="text-sm font-semibold text-slate-950">{alert.title}</div>
                <div className="mt-1 text-sm text-slate-500">{alert.vehicleName} · {alert.detail}</div>
              </div>
              <span className={`rounded-full px-3 py-1 text-xs font-semibold ${alert.severity === 'URGENT' ? 'bg-red-50 text-red-700' : 'bg-amber-50 text-amber-700'}`}>{alert.severity}</span>
            </div>
          </button>
        ))}
      </div>
    </AppleCard>
  );
}
