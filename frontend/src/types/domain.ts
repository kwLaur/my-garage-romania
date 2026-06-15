export type Vehicle = {
  id: string;
  name: string;
  licensePlate: string;
  vin?: string;
  brand?: string;
  model?: string;
  year?: number;
  currentKm: number;
  fuelProfile?: string;
  imageUrl?: string;
  active: boolean;
  createdAt: string;
  updatedAt: string;
};

export type Status = 'OK' | 'SOON' | 'OVERDUE' | 'UNKNOWN' | 'VALID' | 'EXPIRING_SOON' | 'EXPIRED' | 'IGNORED';

export type MaintenanceItem = {
  id: string;
  vehicleId: string;
  type: string;
  lastKm?: number;
  lastDate?: string;
  intervalKm?: number;
  intervalDays?: number;
  cost?: number;
  notes?: string;
  kmRemaining?: number;
  daysRemaining?: number;
  nextDueKm?: number;
  nextDueDate?: string;
  status: Status;
};

export type LegalDocument = {
  id: string;
  vehicleId: string;
  type: string;
  startDate?: string;
  endDate?: string;
  provider?: string;
  policyNumber?: string;
  documentUrl?: string;
  cost?: number;
  source: string;
  ignored: boolean;
  notes?: string;
  daysRemaining?: number;
  status: Status;
};

export type FuelReceipt = {
  id: string;
  vehicleId: string;
  receiptDate: string;
  stationName?: string;
  fuelType: string;
  quantityLiters?: number;
  unitPrice?: number;
  totalAmount?: number;
  odometerKm?: number;
  fullTank: boolean;
  source: string;
  confidenceScore?: number;
  receiptImageUrl?: string;
  rawOcrText?: string;
  notes?: string;
};

export type Expense = {
  id: string;
  vehicleId: string;
  title: string;
  description?: string;
  amount: number;
  date: string;
  type: string;
};

export type TireSet = {
  id: string;
  vehicleId: string;
  tireType: string;
  mountType: string;
  brandModel?: string;
  size?: string;
  dot?: string;
  purchaseDate?: string;
  totalKm?: number;
  cost?: number;
  installed: boolean;
  storageLocation?: string;
  pressureFront?: number;
  pressureRear?: number;
  notes?: string;
};

export type EquipmentItem = {
  id: string;
  vehicleId: string;
  type: string;
  name?: string;
  purchaseDate?: string;
  expiryDate?: string;
  present: boolean;
  location?: string;
  cost?: number;
  notes?: string;
};

export type Alert = {
  severity: 'URGENT' | 'SOON';
  category: string;
  vehicleId: string;
  vehicleName: string;
  entityId: string;
  title: string;
  detail: string;
};

export type Overview = {
  activeVehicles: number;
  totalCostCurrentMonth: number;
  totalCostCurrentYear: number;
  urgentAlerts: number;
  latestFuelReceipt?: FuelReceipt;
  vehicles: Array<{ id: string; name: string; licensePlate: string; currentKm: number; imageUrl?: string; active: boolean }>;
};

export type MonthlyCost = { month: number; amount: number };
