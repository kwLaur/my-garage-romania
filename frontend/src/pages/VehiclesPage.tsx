import { useEffect, useState } from 'react';
import type { FormEvent } from 'react';
import { Plus } from 'lucide-react';
import AppleButton from '../components/AppleButton';
import AppleCard from '../components/AppleCard';
import VehicleCard from '../components/VehicleCard';
import { api } from '../lib/api';
import type { Vehicle } from '../types/domain';

export default function VehiclesPage({ onOpenVehicle }: { onOpenVehicle: (id: string) => void }) {
  const [vehicles, setVehicles] = useState<Vehicle[]>([]);
  const [form, setForm] = useState<Partial<Vehicle>>({ active: true, currentKm: 0, fuelProfile: 'DIESEL' });
  const [error, setError] = useState('');

  async function load() {
    setVehicles(await api.vehicles());
  }

  useEffect(() => { load().catch((err) => setError(err.message)); }, []);

  async function save(event: FormEvent) {
    event.preventDefault();
    await api.saveVehicle(form);
    setForm({ active: true, currentKm: 0, fuelProfile: 'DIESEL' });
    await load();
  }

  const update = (key: keyof Vehicle, value: string | number | boolean) => setForm((current) => ({ ...current, [key]: value }));

  return (
    <div className="space-y-8">
      <div>
        <h1 className="text-4xl font-semibold tracking-normal text-slate-950">Vehicles</h1>
        <p className="mt-2 text-slate-500">Personal cars, odometers, identity data, and images.</p>
      </div>
      {error && <AppleCard><p className="text-red-700">{error}</p></AppleCard>}
      <AppleCard>
        <form onSubmit={save} className="grid gap-3 md:grid-cols-4">
          <input placeholder="Name" value={form.name ?? ''} onChange={(e) => update('name', e.target.value)} required />
          <input placeholder="License plate" value={form.licensePlate ?? ''} onChange={(e) => update('licensePlate', e.target.value)} required />
          <input placeholder="Brand" value={form.brand ?? ''} onChange={(e) => update('brand', e.target.value)} />
          <input placeholder="Model" value={form.model ?? ''} onChange={(e) => update('model', e.target.value)} />
          <input type="number" placeholder="Year" value={form.year ?? ''} onChange={(e) => update('year', Number(e.target.value))} />
          <input type="number" placeholder="Current km" value={form.currentKm ?? ''} onChange={(e) => update('currentKm', Number(e.target.value))} />
          <input placeholder="Fuel profile" value={form.fuelProfile ?? ''} onChange={(e) => update('fuelProfile', e.target.value)} />
          <input placeholder="Image URL" value={form.imageUrl ?? ''} onChange={(e) => update('imageUrl', e.target.value)} />
          <AppleButton className="md:col-span-4"><Plus size={17} />Add vehicle</AppleButton>
        </form>
      </AppleCard>
      <section className="grid gap-5 md:grid-cols-2 xl:grid-cols-3">
        {vehicles.map((vehicle) => <VehicleCard key={vehicle.id} vehicle={vehicle} onOpen={onOpenVehicle} />)}
        {vehicles.length === 0 && <AppleCard><p className="text-sm text-slate-500">No vehicles yet.</p></AppleCard>}
      </section>
    </div>
  );
}
