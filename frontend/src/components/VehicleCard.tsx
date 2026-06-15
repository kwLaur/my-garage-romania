import type { Vehicle } from '../types/domain';
import AppleCard from './AppleCard';

export default function VehicleCard({ vehicle, onOpen }: { vehicle: Vehicle; onOpen: (id: string) => void }) {
  return (
    <button onClick={() => onOpen(vehicle.id)} className="text-left">
      <AppleCard className="h-full overflow-hidden p-0 transition hover:-translate-y-0.5 hover:shadow-xl">
        <div className="aspect-[16/10] bg-slate-100">
          {vehicle.imageUrl ? <img src={vehicle.imageUrl} alt="" className="h-full w-full object-cover" /> : <div className="h-full w-full bg-gradient-to-br from-slate-100 to-slate-200" />}
        </div>
        <div className="p-5">
          <div className="flex items-start justify-between gap-4">
            <div>
              <h3 className="text-lg font-semibold text-slate-950">{vehicle.name}</h3>
              <p className="mt-1 text-sm text-slate-500">{vehicle.brand} {vehicle.model}</p>
            </div>
            <span className="rounded-full bg-slate-100 px-3 py-1 text-xs font-semibold text-slate-700">{vehicle.licensePlate}</span>
          </div>
          <div className="mt-5 text-sm text-slate-500">{vehicle.currentKm.toLocaleString()} km</div>
        </div>
      </AppleCard>
    </button>
  );
}
