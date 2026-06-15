import type { Status } from '../types/domain';

const palette: Record<string, string> = {
  OK: 'bg-emerald-50 text-emerald-700 ring-emerald-200',
  VALID: 'bg-emerald-50 text-emerald-700 ring-emerald-200',
  SOON: 'bg-amber-50 text-amber-700 ring-amber-200',
  EXPIRING_SOON: 'bg-amber-50 text-amber-700 ring-amber-200',
  OVERDUE: 'bg-red-50 text-red-700 ring-red-200',
  EXPIRED: 'bg-red-50 text-red-700 ring-red-200',
  UNKNOWN: 'bg-slate-100 text-slate-600 ring-slate-200',
  IGNORED: 'bg-slate-100 text-slate-500 ring-slate-200'
};

export default function StatusBadge({ status }: { status: Status | string }) {
  return <span className={`rounded-full px-3 py-1 text-xs font-semibold ring-1 ${palette[status] ?? palette.UNKNOWN}`}>{status.replace('_', ' ')}</span>;
}
