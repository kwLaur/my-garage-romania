import { BarChart3, Car, Gauge, LogOut } from 'lucide-react';
import type { ReactNode } from 'react';
import AppleButton from './AppleButton';

type View = 'dashboard' | 'vehicles' | 'costs';

export default function AppShell({ view, onView, onLogout, children }: { view: View; onView: (view: View) => void; onLogout: () => void; children: ReactNode }) {
  const nav = [
    { id: 'dashboard' as const, label: 'Dashboard', icon: Gauge },
    { id: 'vehicles' as const, label: 'Vehicles', icon: Car },
    { id: 'costs' as const, label: 'Costs', icon: BarChart3 }
  ];
  return (
    <div className="min-h-screen bg-[#f5f5f7]">
      <header className="sticky top-0 z-20 border-b border-white/70 bg-[#f5f5f7]/80 backdrop-blur-xl">
        <div className="mx-auto flex max-w-7xl items-center justify-between px-4 py-4 sm:px-6 lg:px-8">
          <button onClick={() => onView('dashboard')} className="text-left">
            <div className="text-lg font-semibold text-slate-950">My Garage Romania</div>
            <div className="text-xs text-slate-500">Personal car manager</div>
          </button>
          <nav className="hidden items-center gap-2 md:flex">
            {nav.map((item) => {
              const Icon = item.icon;
              return (
                <button key={item.id} onClick={() => onView(item.id)} className={`flex items-center gap-2 rounded-2xl px-4 py-2 text-sm font-semibold transition ${view === item.id ? 'bg-white text-slate-950 shadow-sm' : 'text-slate-500 hover:bg-white/70'}`}>
                  <Icon size={17} />
                  {item.label}
                </button>
              );
            })}
          </nav>
          <AppleButton variant="ghost" onClick={onLogout} title="Log out">
            <LogOut size={17} />
          </AppleButton>
        </div>
      </header>
      <main className="mx-auto max-w-7xl px-4 py-8 sm:px-6 lg:px-8">{children}</main>
    </div>
  );
}
