import { useEffect, useState } from 'react';
import { Line, LineChart, ResponsiveContainer, Tooltip, XAxis, YAxis } from 'recharts';
import AlertList from '../components/AlertList';
import AppleCard from '../components/AppleCard';
import MetricCard from '../components/MetricCard';
import VehicleCard from '../components/VehicleCard';
import { api } from '../lib/api';
import type { Alert, MonthlyCost, Overview, Vehicle } from '../types/domain';

export default function DashboardPage({ onOpenVehicle }: { onOpenVehicle: (id: string) => void }) {
  const [overview, setOverview] = useState<Overview | null>(null);
  const [alerts, setAlerts] = useState<Alert[]>([]);
  const [costs, setCosts] = useState<MonthlyCost[]>([]);
  const [vehicles, setVehicles] = useState<Vehicle[]>([]);
  const [error, setError] = useState('');

  useEffect(() => {
    Promise.all([api.overview(), api.alerts(), api.monthlyCosts(new Date().getFullYear()), api.vehicles()])
      .then(([overviewData, alertsData, costsData, vehiclesData]) => {
        setOverview(overviewData);
        setAlerts(alertsData);
        setCosts(costsData);
        setVehicles(vehiclesData);
      })
      .catch((err) => setError(err instanceof Error ? err.message : 'Could not load dashboard'));
  }, []);

  if (error) return <AppleCard><p className="text-red-700">{error}</p></AppleCard>;
  if (!overview) return <div className="text-sm text-slate-500">Loading dashboard...</div>;

  return (
    <div className="space-y-8">
      <section className="flex flex-col justify-between gap-4 md:flex-row md:items-end">
        <div>
          <h1 className="text-4xl font-semibold tracking-normal text-slate-950">Garage overview</h1>
          <p className="mt-2 text-slate-500">Status, alerts, receipts, and costs in one place.</p>
        </div>
        {overview.latestFuelReceipt && <div className="rounded-full bg-white px-4 py-2 text-sm font-medium text-slate-600 shadow-sm">Latest fuel · {overview.latestFuelReceipt.stationName ?? 'Receipt'}</div>}
      </section>
      <section className="grid gap-4 md:grid-cols-4">
        <MetricCard label="Active vehicles" value={overview.activeVehicles} />
        <MetricCard label="This month" value={`${Number(overview.totalCostCurrentMonth).toFixed(0)} RON`} />
        <MetricCard label="This year" value={`${Number(overview.totalCostCurrentYear).toFixed(0)} RON`} />
        <MetricCard label="Urgent alerts" value={overview.urgentAlerts} />
      </section>
      <section className="grid gap-6 lg:grid-cols-[1fr_380px]">
        <AppleCard>
          <h2 className="text-lg font-semibold text-slate-950">Monthly costs</h2>
          <div className="mt-6 h-72">
            <ResponsiveContainer width="100%" height="100%">
              <LineChart data={costs}>
                <XAxis dataKey="month" tickLine={false} axisLine={false} />
                <YAxis tickLine={false} axisLine={false} />
                <Tooltip />
                <Line type="monotone" dataKey="amount" stroke="#111827" strokeWidth={3} dot={false} />
              </LineChart>
            </ResponsiveContainer>
          </div>
        </AppleCard>
        <AlertList alerts={alerts} onOpenVehicle={onOpenVehicle} />
      </section>
      <section className="grid gap-5 md:grid-cols-2 xl:grid-cols-3">
        {vehicles.map((vehicle) => <VehicleCard key={vehicle.id} vehicle={vehicle} onOpen={onOpenVehicle} />)}
      </section>
    </div>
  );
}
