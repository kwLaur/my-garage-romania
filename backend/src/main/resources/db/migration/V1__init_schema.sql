create extension if not exists pgcrypto;

create table app_users (
    id uuid primary key,
    email varchar(255) not null unique,
    password_hash varchar(255) not null,
    display_name varchar(255) not null,
    created_at timestamptz not null,
    updated_at timestamptz not null
);

create table vehicles (
    id uuid primary key,
    name varchar(255) not null,
    license_plate varchar(64) not null,
    vin varchar(64),
    brand varchar(128),
    model varchar(128),
    year integer,
    current_km integer not null default 0,
    fuel_profile varchar(64),
    image_url varchar(1024),
    active boolean not null default true,
    created_at timestamptz not null,
    updated_at timestamptz not null
);

create index idx_vehicles_active on vehicles(active);

create table maintenance_items (
    id uuid primary key,
    vehicle_id uuid not null references vehicles(id) on delete cascade,
    type varchar(64) not null,
    last_km integer,
    last_date date,
    interval_km integer,
    interval_days integer,
    cost numeric(12,2),
    notes text,
    created_at timestamptz not null,
    updated_at timestamptz not null
);

create index idx_maintenance_vehicle on maintenance_items(vehicle_id);

create table legal_documents (
    id uuid primary key,
    vehicle_id uuid not null references vehicles(id) on delete cascade,
    type varchar(64) not null,
    start_date date,
    end_date date,
    provider varchar(255),
    policy_number varchar(255),
    document_url varchar(1024),
    cost numeric(12,2),
    source varchar(32) not null default 'MANUAL',
    ignored boolean not null default false,
    notes text,
    created_at timestamptz not null,
    updated_at timestamptz not null
);

create index idx_legal_vehicle on legal_documents(vehicle_id);
create index idx_legal_end_date on legal_documents(end_date);

create table fuel_receipts (
    id uuid primary key,
    vehicle_id uuid not null references vehicles(id) on delete cascade,
    receipt_date date not null,
    station_name varchar(255),
    fuel_type varchar(32) not null,
    quantity_liters numeric(12,3),
    unit_price numeric(12,3),
    total_amount numeric(12,2),
    odometer_km integer,
    full_tank boolean not null default false,
    source varchar(32) not null default 'MANUAL',
    confidence_score numeric(4,3),
    receipt_image_url varchar(1024),
    raw_ocr_text text,
    notes text,
    created_at timestamptz not null,
    updated_at timestamptz not null
);

create index idx_fuel_vehicle_date on fuel_receipts(vehicle_id, receipt_date desc);

create table expenses (
    id uuid primary key,
    vehicle_id uuid not null references vehicles(id) on delete cascade,
    title varchar(255) not null,
    description text,
    amount numeric(12,2),
    date date,
    type varchar(32) not null,
    linked_entity_type varchar(64),
    linked_entity_id uuid,
    created_at timestamptz not null,
    updated_at timestamptz not null
);

create index idx_expense_vehicle_date on expenses(vehicle_id, date desc);
create unique index idx_expense_linked on expenses(linked_entity_type, linked_entity_id) where linked_entity_type is not null and linked_entity_id is not null;

create table tire_sets (
    id uuid primary key,
    vehicle_id uuid not null references vehicles(id) on delete cascade,
    tire_type varchar(32) not null,
    mount_type varchar(32) not null,
    brand_model varchar(255),
    size varchar(64),
    dot varchar(64),
    purchase_date date,
    total_km integer,
    cost numeric(12,2),
    installed boolean not null default false,
    storage_location varchar(255),
    pressure_front numeric(4,2),
    pressure_rear numeric(4,2),
    notes text,
    created_at timestamptz not null,
    updated_at timestamptz not null
);

create index idx_tire_vehicle on tire_sets(vehicle_id);

create table equipment_items (
    id uuid primary key,
    vehicle_id uuid not null references vehicles(id) on delete cascade,
    type varchar(64) not null,
    name varchar(255),
    purchase_date date,
    expiry_date date,
    present boolean not null default true,
    location varchar(255),
    cost numeric(12,2),
    notes text,
    created_at timestamptz not null,
    updated_at timestamptz not null
);

create index idx_equipment_vehicle on equipment_items(vehicle_id);
create index idx_equipment_expiry on equipment_items(expiry_date);
