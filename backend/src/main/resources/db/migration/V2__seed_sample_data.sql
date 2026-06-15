insert into vehicles (id, name, license_plate, vin, brand, model, year, current_km, fuel_profile, image_url, active, created_at, updated_at)
values
('11111111-1111-1111-1111-111111111111', 'Daily Driver', 'B-101-GAR', 'WVWZZZ1KZ9W000001', 'Volkswagen', 'Golf', 2018, 84500, 'DIESEL', 'https://images.unsplash.com/photo-1542362567-b07e54358753?auto=format&fit=crop&w=1200&q=80', true, now(), now()),
('22222222-2222-2222-2222-222222222222', 'Weekend Car', 'IF-22-MGR', 'WBA8E9G50GNU00002', 'BMW', 'Seria 3', 2020, 46200, 'GASOLINE', 'https://images.unsplash.com/photo-1555215695-3004980ad54e?auto=format&fit=crop&w=1200&q=80', true, now(), now());

insert into maintenance_items (id, vehicle_id, type, last_km, last_date, interval_km, interval_days, cost, notes, created_at, updated_at)
values
(gen_random_uuid(), '11111111-1111-1111-1111-111111111111', 'ENGINE_OIL', 73500, current_date - 340, 12000, 365, 720.00, 'Oil and filters', now(), now()),
(gen_random_uuid(), '11111111-1111-1111-1111-111111111111', 'TIMING_BELT', 30000, current_date - 1300, 100000, 1825, null, 'Track belt kit interval', now(), now()),
(gen_random_uuid(), '22222222-2222-2222-2222-222222222222', 'GENERAL_SERVICE', 39000, current_date - 190, 15000, 365, 980.00, 'Annual service', now(), now());

insert into legal_documents (id, vehicle_id, type, start_date, end_date, provider, policy_number, document_url, cost, source, ignored, notes, created_at, updated_at)
values
('aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa', '11111111-1111-1111-1111-111111111111', 'RCA', current_date - 300, current_date + 20, 'Allianz-Tiriac', 'RCA-101', null, 860.00, 'MANUAL', false, null, now(), now()),
('bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb', '11111111-1111-1111-1111-111111111111', 'ITP', current_date - 700, current_date - 5, 'ITP Bucuresti', 'ITP-2024', null, 180.00, 'MANUAL', false, 'Renewal required', now(), now()),
('cccccccc-cccc-cccc-cccc-cccccccccccc', '22222222-2222-2222-2222-222222222222', 'ROVINIETA', current_date - 40, current_date + 325, 'CNAIR', 'RV-22', null, 140.00, 'MANUAL', false, null, now(), now());

insert into fuel_receipts (id, vehicle_id, receipt_date, station_name, fuel_type, quantity_liters, unit_price, total_amount, odometer_km, full_tank, source, confidence_score, receipt_image_url, raw_ocr_text, notes, created_at, updated_at)
values
('dddddddd-dddd-dddd-dddd-dddddddddddd', '11111111-1111-1111-1111-111111111111', current_date - 8, 'OMV', 'DIESEL', 48.200, 7.45, 359.09, 84450, true, 'MANUAL', null, null, null, null, now(), now()),
('eeeeeeee-eeee-eeee-eeee-eeeeeeeeeeee', '22222222-2222-2222-2222-222222222222', current_date - 17, 'MOL', 'GASOLINE', 41.000, 7.38, 302.58, 46150, true, 'MANUAL', null, null, null, null, now(), now());

insert into expenses (id, vehicle_id, title, description, amount, date, type, linked_entity_type, linked_entity_id, created_at, updated_at)
values
(gen_random_uuid(), '11111111-1111-1111-1111-111111111111', 'RCA B-101-GAR', 'Allianz-Tiriac', 860.00, current_date - 300, 'LEGAL', 'LEGAL_DOCUMENT', 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa', now(), now()),
(gen_random_uuid(), '11111111-1111-1111-1111-111111111111', 'ITP B-101-GAR', 'ITP Bucuresti', 180.00, current_date - 700, 'LEGAL', 'LEGAL_DOCUMENT', 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb', now(), now()),
(gen_random_uuid(), '22222222-2222-2222-2222-222222222222', 'ROVINIETA IF-22-MGR', 'CNAIR', 140.00, current_date - 40, 'LEGAL', 'LEGAL_DOCUMENT', 'cccccccc-cccc-cccc-cccc-cccccccccccc', now(), now()),
(gen_random_uuid(), '11111111-1111-1111-1111-111111111111', 'Fuel B-101-GAR', 'OMV', 359.09, current_date - 8, 'FUEL', 'FUEL_RECEIPT', 'dddddddd-dddd-dddd-dddd-dddddddddddd', now(), now()),
(gen_random_uuid(), '22222222-2222-2222-2222-222222222222', 'Fuel IF-22-MGR', 'MOL', 302.58, current_date - 17, 'FUEL', 'FUEL_RECEIPT', 'eeeeeeee-eeee-eeee-eeee-eeeeeeeeeeee', now(), now());

insert into tire_sets (id, vehicle_id, tire_type, mount_type, brand_model, size, dot, purchase_date, total_km, cost, installed, storage_location, pressure_front, pressure_rear, notes, created_at, updated_at)
values
(gen_random_uuid(), '11111111-1111-1111-1111-111111111111', 'SUMMER', 'ON_RIMS', 'Michelin Primacy 4', '205/55 R16', '1223', current_date - 420, 18000, 2100.00, true, 'On car', 2.30, 2.20, null, now(), now()),
(gen_random_uuid(), '11111111-1111-1111-1111-111111111111', 'WINTER', 'TIRES_ONLY', 'Continental WinterContact', '205/55 R16', '4022', current_date - 700, 12000, 1800.00, false, 'Garage shelf', 2.30, 2.20, null, now(), now());

insert into equipment_items (id, vehicle_id, type, name, purchase_date, expiry_date, present, location, cost, notes, created_at, updated_at)
values
(gen_random_uuid(), '11111111-1111-1111-1111-111111111111', 'FIRST_AID_KIT', 'Trusa medicala', current_date - 600, current_date + 24, true, 'Portbagaj', 85.00, null, now(), now()),
(gen_random_uuid(), '11111111-1111-1111-1111-111111111111', 'EXTINGUISHER', 'Stingator 1kg', current_date - 800, current_date - 12, true, 'Portbagaj', 120.00, 'Needs replacement', now(), now()),
(gen_random_uuid(), '22222222-2222-2222-2222-222222222222', 'WARNING_TRIANGLE', 'Triunghi reflectorizant', current_date - 100, null, true, 'Portbagaj', 45.00, null, now(), now());
