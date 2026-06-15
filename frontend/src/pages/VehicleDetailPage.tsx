import { useEffect, useState } from 'react';
import type { ReactNode } from 'react';
import AppleButton from '../components/AppleButton';
import AppleCard from '../components/AppleCard';
import FuelReceiptForm from '../components/FuelReceiptForm';
import StatusBadge from '../components/StatusBadge';
import { api } from '../lib/api';
import type { EquipmentItem, Expense, FuelReceipt, LegalDocument, MaintenanceItem, TireSet, Vehicle } from '../types/domain';

type Tab = 'maintenance' | 'legal' | 'fuel' | 'costs' | 'tires' | 'equipment';

export default function VehicleDetailPage({ vehicleId, onBack }: { vehicleId: string; onBack: () => void }) {
  const [vehicle, setVehicle] = useState<Vehicle | null>(null);
  const [tab, setTab] = useState<Tab>('maintenance');
  const [maintenance, setMaintenance] = useState<MaintenanceItem[]>([]);
  const [legal, setLegal] = useState<LegalDocument[]>([]);
  const [fuel, setFuel] = useState<FuelReceipt[]>([]);
  const [expenses, setExpenses] = useState<Expense[]>([]);
  const [tires, setTires] = useState<TireSet[]>([]);
  const [equipment, setEquipment] = useState<EquipmentItem[]>([]);
  const [error, setError] = useState('');

  async function load() {
    const [v, m, l, f, e, t, eq] = await Promise.all([
      api.vehicle(vehicleId),
      api.maintenance(vehicleId),
      api.legalDocuments(vehicleId),
      api.fuelReceipts(vehicleId),
      api.expenses(vehicleId),
      api.tires(vehicleId),
      api.equipment(vehicleId)
    ]);
    setVehicle(v); setMaintenance(m); setLegal(l); setFuel(f); setExpenses(e); setTires(t); setEquipment(eq);
  }

  useEffect(() => { load().catch((err) => setError(err.message)); }, [vehicleId]);

  if (error) return <AppleCard><p className="text-red-700">{error}</p></AppleCard>;
  if (!vehicle) return <div className="text-sm text-slate-500">Loading vehicle...</div>;

  return (
    <div className="space-y-8">
      <button onClick={onBack} className="text-sm font-semibold text-slate-500 hover:text-slate-950">Back to garage</button>
      <AppleCard className="overflow-hidden p-0">
        <div className="grid lg:grid-cols-[420px_1fr]">
          <div className="aspect-[16/11] bg-slate-100 lg:aspect-auto">
            {vehicle.imageUrl && <img src={vehicle.imageUrl} alt="" className="h-full w-full object-cover" />}
          </div>
          <div className="p-7">
            <div className="flex flex-col gap-4 sm:flex-row sm:items-start sm:justify-between">
              <div>
                <h1 className="text-4xl font-semibold tracking-normal text-slate-950">{vehicle.name}</h1>
                <p className="mt-2 text-slate-500">{vehicle.brand} {vehicle.model} · {vehicle.licensePlate}</p>
              </div>
              <div className="rounded-full bg-slate-100 px-4 py-2 text-sm font-semibold text-slate-700">{vehicle.currentKm.toLocaleString()} km</div>
            </div>
            <VehicleEditForm vehicle={vehicle} onSaved={async () => { await load(); }} />
          </div>
        </div>
      </AppleCard>
      <div className="flex gap-2 overflow-x-auto pb-1">
        {(['maintenance', 'legal', 'fuel', 'costs', 'tires', 'equipment'] as Tab[]).map((item) => (
          <button key={item} onClick={() => setTab(item)} className={`rounded-2xl px-4 py-2 text-sm font-semibold capitalize ${tab === item ? 'bg-white text-slate-950 shadow-sm' : 'text-slate-500 hover:bg-white/70'}`}>{item}</button>
        ))}
      </div>
      {tab === 'maintenance' && <MaintenanceSection items={maintenance} vehicleId={vehicleId} reload={load} />}
      {tab === 'legal' && <LegalSection items={legal} vehicleId={vehicleId} reload={load} />}
      {tab === 'fuel' && <FuelSection items={fuel} vehicleId={vehicleId} reload={load} />}
      {tab === 'costs' && <CostsSection items={expenses} vehicleId={vehicleId} reload={load} />}
      {tab === 'tires' && <TireSection items={tires} vehicleId={vehicleId} reload={load} />}
      {tab === 'equipment' && <EquipmentSection items={equipment} vehicleId={vehicleId} reload={load} />}
    </div>
  );
}

function VehicleEditForm({ vehicle, onSaved }: { vehicle: Vehicle; onSaved: () => Promise<void> }) {
  const [form, setForm] = useState<Partial<Vehicle>>(vehicle);
  const update = (key: keyof Vehicle, value: string | number | boolean) => setForm((current) => ({ ...current, [key]: value }));
  return (
    <form className="mt-8 grid gap-3 md:grid-cols-4" onSubmit={async (e) => { e.preventDefault(); await api.saveVehicle(form); await onSaved(); }}>
      <input value={form.name ?? ''} onChange={(e) => update('name', e.target.value)} />
      <input value={form.licensePlate ?? ''} onChange={(e) => update('licensePlate', e.target.value)} />
      <input value={form.brand ?? ''} onChange={(e) => update('brand', e.target.value)} />
      <input value={form.model ?? ''} onChange={(e) => update('model', e.target.value)} />
      <input type="number" value={form.currentKm ?? 0} onChange={(e) => update('currentKm', Number(e.target.value))} />
      <input value={form.vin ?? ''} onChange={(e) => update('vin', e.target.value)} placeholder="VIN" />
      <input value={form.imageUrl ?? ''} onChange={(e) => update('imageUrl', e.target.value)} placeholder="Image URL" />
      <AppleButton>Save vehicle</AppleButton>
    </form>
  );
}

function MaintenanceSection({ items, vehicleId, reload }: { items: MaintenanceItem[]; vehicleId: string; reload: () => Promise<void> }) {
  const [form, setForm] = useState<Partial<MaintenanceItem>>({ type: 'ENGINE_OIL', intervalKm: 12000, intervalDays: 365 });
  return (
    <GridSection title="Maintenance" form={
      <form className="grid gap-3 md:grid-cols-4" onSubmit={async (e) => { e.preventDefault(); await api.saveMaintenance(vehicleId, form); setForm({ type: 'ENGINE_OIL', intervalKm: 12000, intervalDays: 365 }); await reload(); }}>
        <select value={form.type ?? 'ENGINE_OIL'} onChange={(e) => setForm({ ...form, type: e.target.value })}>{['GENERAL_SERVICE', 'ENGINE_OIL', 'GEARBOX_OIL', 'TIMING_BELT', 'BRAKE_FLUID', 'COOLANT'].map(x => <option key={x}>{x}</option>)}</select>
        <input type="number" placeholder="Last km" onChange={(e) => setForm({ ...form, lastKm: Number(e.target.value) })} />
        <input type="date" onChange={(e) => setForm({ ...form, lastDate: e.target.value })} />
        <input type="number" placeholder="Interval km" value={form.intervalKm ?? ''} onChange={(e) => setForm({ ...form, intervalKm: Number(e.target.value) })} />
        <input type="number" placeholder="Interval days" value={form.intervalDays ?? ''} onChange={(e) => setForm({ ...form, intervalDays: Number(e.target.value) })} />
        <input type="number" placeholder="Cost" onChange={(e) => setForm({ ...form, cost: Number(e.target.value) })} />
        <input placeholder="Notes" onChange={(e) => setForm({ ...form, notes: e.target.value })} />
        <AppleButton>Save maintenance</AppleButton>
      </form>
    }>
      {items.map((item) => <Row key={item.id} title={item.type} detail={`${item.kmRemaining ?? '-'} km · ${item.daysRemaining ?? '-'} days`} right={<StatusBadge status={item.status} />} />)}
    </GridSection>
  );
}

function LegalSection({ items, vehicleId, reload }: { items: LegalDocument[]; vehicleId: string; reload: () => Promise<void> }) {
  const [form, setForm] = useState<Partial<LegalDocument>>({ type: 'RCA', source: 'MANUAL', ignored: false });
  return (
    <GridSection title="Legal documents" form={
      <form className="grid gap-3 md:grid-cols-4" onSubmit={async (e) => { e.preventDefault(); await api.saveLegalDocument(vehicleId, form); setForm({ type: 'RCA', source: 'MANUAL', ignored: false }); await reload(); }}>
        <select value={form.type ?? 'RCA'} onChange={(e) => setForm({ ...form, type: e.target.value })}>{['RCA', 'CASCO', 'ITP', 'ROVINIETA'].map(x => <option key={x}>{x}</option>)}</select>
        <input type="date" onChange={(e) => setForm({ ...form, startDate: e.target.value })} />
        <input type="date" onChange={(e) => setForm({ ...form, endDate: e.target.value })} />
        <input placeholder="Provider" onChange={(e) => setForm({ ...form, provider: e.target.value })} />
        <input placeholder="Policy number" onChange={(e) => setForm({ ...form, policyNumber: e.target.value })} />
        <input type="number" placeholder="Cost" onChange={(e) => setForm({ ...form, cost: Number(e.target.value) })} />
        <input placeholder="Document URL" onChange={(e) => setForm({ ...form, documentUrl: e.target.value })} />
        <AppleButton>Save document</AppleButton>
      </form>
    }>
      {items.map((item) => <Row key={item.id} title={item.type} detail={`${item.provider ?? 'Manual'} · ${item.endDate ?? 'No end date'}`} right={<StatusBadge status={item.status} />} />)}
    </GridSection>
  );
}

function FuelSection({ items, vehicleId, reload }: { items: FuelReceipt[]; vehicleId: string; reload: () => Promise<void> }) {
  return (
    <GridSection title="Fuel receipts" form={<FuelReceiptForm onSubmit={async (receipt, image) => { image ? await api.uploadFuelReceipt(vehicleId, receipt, image) : await api.saveFuelReceipt(vehicleId, receipt); await reload(); }} />}>
      {items.map((item) => <Row key={item.id} title={item.stationName ?? item.fuelType} detail={`${item.receiptDate} · ${item.totalAmount ?? 0} RON · ${item.odometerKm ?? '-'} km`} />)}
    </GridSection>
  );
}

function CostsSection({ items, vehicleId, reload }: { items: Expense[]; vehicleId: string; reload: () => Promise<void> }) {
  const [form, setForm] = useState<Partial<Expense>>({ date: new Date().toISOString().slice(0, 10), type: 'OTHER' });
  return (
    <GridSection title="Costs" form={
      <form className="grid gap-3 md:grid-cols-4" onSubmit={async (e) => { e.preventDefault(); await api.saveExpense(vehicleId, form); setForm({ date: new Date().toISOString().slice(0, 10), type: 'OTHER' }); await reload(); }}>
        <input placeholder="Title" onChange={(e) => setForm({ ...form, title: e.target.value })} required />
        <input type="number" placeholder="Amount" onChange={(e) => setForm({ ...form, amount: Number(e.target.value) })} required />
        <input type="date" value={form.date ?? ''} onChange={(e) => setForm({ ...form, date: e.target.value })} />
        <select value={form.type ?? 'OTHER'} onChange={(e) => setForm({ ...form, type: e.target.value })}>{['SERVICE', 'FUEL', 'LEGAL', 'TIRE', 'EQUIPMENT', 'BATTERY', 'OTHER'].map(x => <option key={x}>{x}</option>)}</select>
        <input className="md:col-span-3" placeholder="Description" onChange={(e) => setForm({ ...form, description: e.target.value })} />
        <AppleButton>Save expense</AppleButton>
      </form>
    }>
      {items.map((item) => <Row key={item.id} title={item.title} detail={`${item.date} · ${item.type}`} right={<span className="font-semibold">{item.amount} RON</span>} />)}
    </GridSection>
  );
}

function TireSection({ items, vehicleId, reload }: { items: TireSet[]; vehicleId: string; reload: () => Promise<void> }) {
  const [form, setForm] = useState<Partial<TireSet>>({ tireType: 'SUMMER', mountType: 'ON_RIMS', installed: false });
  return (
    <GridSection title="Tires" form={
      <form className="grid gap-3 md:grid-cols-4" onSubmit={async (e) => { e.preventDefault(); await api.saveTire(vehicleId, form); setForm({ tireType: 'SUMMER', mountType: 'ON_RIMS', installed: false }); await reload(); }}>
        <select value={form.tireType ?? 'SUMMER'} onChange={(e) => setForm({ ...form, tireType: e.target.value })}>{['SUMMER', 'WINTER', 'ALL_SEASON'].map(x => <option key={x}>{x}</option>)}</select>
        <select value={form.mountType ?? 'ON_RIMS'} onChange={(e) => setForm({ ...form, mountType: e.target.value })}>{['TIRES_ONLY', 'ON_RIMS'].map(x => <option key={x}>{x}</option>)}</select>
        <input placeholder="Brand model" onChange={(e) => setForm({ ...form, brandModel: e.target.value })} />
        <input placeholder="Size" onChange={(e) => setForm({ ...form, size: e.target.value })} />
        <input placeholder="DOT" onChange={(e) => setForm({ ...form, dot: e.target.value })} />
        <input placeholder="Storage" onChange={(e) => setForm({ ...form, storageLocation: e.target.value })} />
        <input type="number" placeholder="Cost" onChange={(e) => setForm({ ...form, cost: Number(e.target.value) })} />
        <AppleButton>Save tires</AppleButton>
      </form>
    }>
      {items.map((item) => <Row key={item.id} title={`${item.tireType} · ${item.size ?? ''}`} detail={`${item.brandModel ?? 'Tire set'} · ${item.installed ? 'Installed' : item.storageLocation ?? 'Stored'}`} />)}
    </GridSection>
  );
}

function EquipmentSection({ items, vehicleId, reload }: { items: EquipmentItem[]; vehicleId: string; reload: () => Promise<void> }) {
  const [form, setForm] = useState<Partial<EquipmentItem>>({ type: 'FIRST_AID_KIT', present: true });
  return (
    <GridSection title="Equipment" form={
      <form className="grid gap-3 md:grid-cols-4" onSubmit={async (e) => { e.preventDefault(); await api.saveEquipment(vehicleId, form); setForm({ type: 'FIRST_AID_KIT', present: true }); await reload(); }}>
        <select value={form.type ?? 'FIRST_AID_KIT'} onChange={(e) => setForm({ ...form, type: e.target.value })}>{['FIRST_AID_KIT', 'EXTINGUISHER', 'REFLECTIVE_VEST', 'WARNING_TRIANGLE', 'SPARE_WHEEL', 'JACK', 'COMPRESSOR', 'SNOW_CHAINS', 'OTHER'].map(x => <option key={x}>{x}</option>)}</select>
        <input placeholder="Name" onChange={(e) => setForm({ ...form, name: e.target.value })} />
        <input type="date" onChange={(e) => setForm({ ...form, expiryDate: e.target.value })} />
        <input placeholder="Location" onChange={(e) => setForm({ ...form, location: e.target.value })} />
        <input type="number" placeholder="Cost" onChange={(e) => setForm({ ...form, cost: Number(e.target.value) })} />
        <AppleButton>Save equipment</AppleButton>
      </form>
    }>
      {items.map((item) => <Row key={item.id} title={item.name ?? item.type} detail={`${item.location ?? 'Vehicle'} · expires ${item.expiryDate ?? 'n/a'}`} right={<span className={item.present ? 'text-emerald-700' : 'text-red-700'}>{item.present ? 'Present' : 'Missing'}</span>} />)}
    </GridSection>
  );
}

function GridSection({ title, form, children }: { title: string; form: ReactNode; children: ReactNode }) {
  return (
    <div className="grid gap-6 lg:grid-cols-[minmax(0,1fr)_420px]">
      <AppleCard>
        <h2 className="text-xl font-semibold text-slate-950">{title}</h2>
        <div className="mt-5 divide-y divide-slate-100">{children || <p className="text-sm text-slate-500">No records yet.</p>}</div>
      </AppleCard>
      <AppleCard>
        <h3 className="mb-5 text-lg font-semibold text-slate-950">Add record</h3>
        {form}
      </AppleCard>
    </div>
  );
}

function Row({ title, detail, right }: { title: string; detail: string; right?: ReactNode }) {
  return (
    <div className="flex items-center justify-between gap-4 py-4">
      <div>
        <div className="font-semibold text-slate-950">{title}</div>
        <div className="mt-1 text-sm text-slate-500">{detail}</div>
      </div>
      {right}
    </div>
  );
}
