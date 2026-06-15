import { useEffect, useState } from 'react';
import { Bar, BarChart, ResponsiveContainer, Tooltip, XAxis, YAxis } from 'recharts';
import AppleCard from '../components/AppleCard';
import { api } from '../lib/api';
import type { MonthlyCost } from '../types/domain';

export default function CostsPage() {
  const [costs, setCosts] = useState<MonthlyCost[]>([]);
  const [error, setError] = useState('');

  useEffect(() => {
    api.monthlyCosts(new Date().getFullYear()).then(setCosts).catch((err) => setError(err.message));
  }, []);

  return (
    <div className="space-y-8">
      <div>
        <h1 className="text-4xl font-semibold tracking-normal text-slate-950">Costs</h1>
        <p className="mt-2 text-slate-500">Monthly spending generated from fuel, legal records, and manual expenses.</p>
      </div>
      <AppleCard>
        {error ? <p className="text-red-700">{error}</p> : (
          <div className="h-[420px]">
            <ResponsiveContainer width="100%" height="100%">
              <BarChart data={costs}>
                <XAxis dataKey="month" tickLine={false} axisLine={false} />
                <YAxis tickLine={false} axisLine={false} />
                <Tooltip />
                <Bar dataKey="amount" fill="#111827" radius={[10, 10, 0, 0]} />
              </BarChart>
            </ResponsiveContainer>
          </div>
        )}
      </AppleCard>
    </div>
  );
}
