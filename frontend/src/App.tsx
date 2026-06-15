import { useEffect, useState } from 'react';
import AppShell from './components/AppShell';
import { authStore, api } from './lib/api';
import CostsPage from './pages/CostsPage';
import DashboardPage from './pages/DashboardPage';
import LoginPage from './pages/LoginPage';
import VehicleDetailPage from './pages/VehicleDetailPage';
import VehiclesPage from './pages/VehiclesPage';

type View = 'dashboard' | 'vehicles' | 'costs';

export default function App() {
  const [authenticated, setAuthenticated] = useState(Boolean(authStore.token));
  const [view, setView] = useState<View>('dashboard');
  const [vehicleId, setVehicleId] = useState<string | null>(null);
  const [checking, setChecking] = useState(Boolean(authStore.token));

  useEffect(() => {
    if (!authStore.token) return;
    api.me()
      .then(() => setAuthenticated(true))
      .catch(() => {
        authStore.clear();
        setAuthenticated(false);
      })
      .finally(() => setChecking(false));
  }, []);

  function openVehicle(id: string) {
    setVehicleId(id);
    setView('vehicles');
  }

  function logout() {
    authStore.clear();
    setAuthenticated(false);
    setVehicleId(null);
  }

  if (checking) return <main className="flex min-h-screen items-center justify-center bg-[#f5f5f7] text-sm text-slate-500">Loading...</main>;
  if (!authenticated) return <LoginPage onLogin={() => setAuthenticated(true)} />;

  return (
    <AppShell view={view} onView={(nextView) => { setView(nextView); setVehicleId(null); }} onLogout={logout}>
      {vehicleId ? <VehicleDetailPage vehicleId={vehicleId} onBack={() => setVehicleId(null)} /> : (
        <>
          {view === 'dashboard' && <DashboardPage onOpenVehicle={openVehicle} />}
          {view === 'vehicles' && <VehiclesPage onOpenVehicle={openVehicle} />}
          {view === 'costs' && <CostsPage />}
        </>
      )}
    </AppShell>
  );
}
