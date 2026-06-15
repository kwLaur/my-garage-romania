import { useState } from 'react';
import type { FuelReceipt } from '../types/domain';
import AppleButton from './AppleButton';
import ReceiptImageUpload from './ReceiptImageUpload';

export default function FuelReceiptForm({ onSubmit }: { onSubmit: (receipt: Partial<FuelReceipt>, image: File | null) => Promise<void> }) {
  const [form, setForm] = useState<Partial<FuelReceipt>>({ receiptDate: new Date().toISOString().slice(0, 10), fuelType: 'DIESEL', fullTank: true, source: 'MANUAL' });
  const [image, setImage] = useState<File | null>(null);
  const update = (key: keyof FuelReceipt, value: string | number | boolean) => setForm((current) => ({ ...current, [key]: value }));
  return (
    <form className="grid gap-3 sm:grid-cols-2" onSubmit={async (event) => { event.preventDefault(); await onSubmit(form, image); }}>
      <input type="date" value={form.receiptDate ?? ''} onChange={(e) => update('receiptDate', e.target.value)} required />
      <select value={form.fuelType ?? 'DIESEL'} onChange={(e) => update('fuelType', e.target.value)}>
        {['GASOLINE', 'DIESEL', 'LPG', 'ELECTRIC', 'OTHER'].map((type) => <option key={type}>{type}</option>)}
      </select>
      <input placeholder="Station" value={form.stationName ?? ''} onChange={(e) => update('stationName', e.target.value)} />
      <input type="number" step="0.01" placeholder="Total amount" value={form.totalAmount ?? ''} onChange={(e) => update('totalAmount', Number(e.target.value))} />
      <input type="number" step="0.001" placeholder="Liters" value={form.quantityLiters ?? ''} onChange={(e) => update('quantityLiters', Number(e.target.value))} />
      <input type="number" placeholder="Odometer km" value={form.odometerKm ?? ''} onChange={(e) => update('odometerKm', Number(e.target.value))} />
      <div className="sm:col-span-2"><ReceiptImageUpload onFile={setImage} /></div>
      <AppleButton className="sm:col-span-2" type="submit">Save fuel receipt</AppleButton>
    </form>
  );
}
