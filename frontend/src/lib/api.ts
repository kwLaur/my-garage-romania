import type { Alert, EquipmentItem, Expense, FuelReceipt, LegalDocument, MaintenanceItem, MonthlyCost, Overview, TireSet, Vehicle } from '../types/domain';

const API_BASE = import.meta.env.VITE_API_BASE_URL ?? '';
const TOKEN_KEY = 'my-garage-token';

export const authStore = {
  get token() {
    return localStorage.getItem(TOKEN_KEY);
  },
  setToken(token: string) {
    localStorage.setItem(TOKEN_KEY, token);
  },
  clear() {
    localStorage.removeItem(TOKEN_KEY);
  }
};

async function request<T>(path: string, options: RequestInit = {}): Promise<T> {
  const headers = new Headers(options.headers);
  if (!(options.body instanceof FormData)) {
    headers.set('Content-Type', 'application/json');
  }
  if (authStore.token) {
    headers.set('Authorization', `Bearer ${authStore.token}`);
  }
  const response = await fetch(`${API_BASE}${path}`, { ...options, headers });
  if (!response.ok) {
    const body = await response.json().catch(() => ({ message: response.statusText }));
    throw new Error(body.message ?? 'Request failed');
  }
  if (response.status === 204) {
    return undefined as T;
  }
  return response.json();
}

export const api = {
  login: (email: string, password: string) => request<{ token: string; user: { email: string; displayName: string } }>('/api/auth/login', {
    method: 'POST',
    body: JSON.stringify({ email, password })
  }),
  me: () => request<{ email: string; displayName: string }>('/api/auth/me'),
  overview: () => request<Overview>('/api/dashboard/overview'),
  alerts: () => request<Alert[]>('/api/dashboard/alerts'),
  monthlyCosts: (year: number) => request<MonthlyCost[]>(`/api/dashboard/costs/monthly?year=${year}`),
  vehicles: () => request<Vehicle[]>('/api/vehicles'),
  vehicle: (id: string) => request<Vehicle>(`/api/vehicles/${id}`),
  saveVehicle: (vehicle: Partial<Vehicle>) => request<Vehicle>(vehicle.id ? `/api/vehicles/${vehicle.id}` : '/api/vehicles', {
    method: vehicle.id ? 'PUT' : 'POST',
    body: JSON.stringify(vehicle)
  }),
  maintenance: (vehicleId: string) => request<MaintenanceItem[]>(`/api/vehicles/${vehicleId}/maintenance`),
  saveMaintenance: (vehicleId: string, item: Partial<MaintenanceItem>) => request<MaintenanceItem>(item.id ? `/api/maintenance/${item.id}` : `/api/vehicles/${vehicleId}/maintenance`, {
    method: item.id ? 'PUT' : 'POST',
    body: JSON.stringify(item)
  }),
  legalDocuments: (vehicleId: string) => request<LegalDocument[]>(`/api/vehicles/${vehicleId}/legal-documents`),
  saveLegalDocument: (vehicleId: string, item: Partial<LegalDocument>) => request<LegalDocument>(item.id ? `/api/legal-documents/${item.id}` : `/api/vehicles/${vehicleId}/legal-documents`, {
    method: item.id ? 'PUT' : 'POST',
    body: JSON.stringify(item)
  }),
  fuelReceipts: (vehicleId: string) => request<FuelReceipt[]>(`/api/vehicles/${vehicleId}/fuel-receipts`),
  saveFuelReceipt: (vehicleId: string, item: Partial<FuelReceipt>) => request<FuelReceipt>(item.id ? `/api/fuel-receipts/${item.id}` : `/api/vehicles/${vehicleId}/fuel-receipts`, {
    method: item.id ? 'PUT' : 'POST',
    body: JSON.stringify(item)
  }),
  uploadFuelReceipt: (vehicleId: string, item: Partial<FuelReceipt>, image: File) => {
    const formData = new FormData();
    formData.set('metadata', new Blob([JSON.stringify(item)], { type: 'application/json' }));
    formData.set('image', image);
    return request<FuelReceipt>(`/api/vehicles/${vehicleId}/fuel-receipts/with-image`, { method: 'POST', body: formData });
  },
  expenses: (vehicleId: string) => request<Expense[]>(`/api/vehicles/${vehicleId}/expenses`),
  saveExpense: (vehicleId: string, item: Partial<Expense>) => request<Expense>(item.id ? `/api/expenses/${item.id}` : `/api/vehicles/${vehicleId}/expenses`, {
    method: item.id ? 'PUT' : 'POST',
    body: JSON.stringify(item)
  }),
  tires: (vehicleId: string) => request<TireSet[]>(`/api/vehicles/${vehicleId}/tire-sets`),
  saveTire: (vehicleId: string, item: Partial<TireSet>) => request<TireSet>(item.id ? `/api/tire-sets/${item.id}` : `/api/vehicles/${vehicleId}/tire-sets`, {
    method: item.id ? 'PUT' : 'POST',
    body: JSON.stringify(item)
  }),
  equipment: (vehicleId: string) => request<EquipmentItem[]>(`/api/vehicles/${vehicleId}/equipment`),
  saveEquipment: (vehicleId: string, item: Partial<EquipmentItem>) => request<EquipmentItem>(item.id ? `/api/equipment/${item.id}` : `/api/vehicles/${vehicleId}/equipment`, {
    method: item.id ? 'PUT' : 'POST',
    body: JSON.stringify(item)
  })
};
