import AppleCard from './AppleCard';

export default function MetricCard({ label, value, helper }: { label: string; value: string | number; helper?: string }) {
  return (
    <AppleCard>
      <div className="text-sm font-medium text-slate-500">{label}</div>
      <div className="mt-3 text-3xl font-semibold tracking-normal text-slate-950">{value}</div>
      {helper && <div className="mt-2 text-sm text-slate-500">{helper}</div>}
    </AppleCard>
  );
}
