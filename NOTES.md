# Reference Domain Notes

Reference inspected: `HAForgeLabs/car_manager_romania`, a Home Assistant integration for Romanian personal vehicle management.

## Domain Concepts Extracted

- Vehicles are the aggregate root. Each vehicle owns odometer data, identity fields, legal terms, mechanical maintenance, fuel receipts, costs, tires, and equipment.
- Maintenance is interval-based. Items are checked by kilometers, days, or both, with automatic status: unknown, ok, soon, overdue. The useful thresholds are 1,000 km and 30 days.
- Romanian legal documents are separate from mechanical maintenance. RCA, CASCO, ITP, and rovinieta are date-validity records with expiry/soon/valid/unknown states. Rovinieta can later support CNAIR integration, but manual tracking is the right standalone baseline.
- Fuel receipts are operational cost records. The HA integration tracks receipt date, station, fuel type, liters, price, amount, odometer, full tank, source, OCR text, and confidence.
- Costs are an explicit module and should also be generated from linked records such as fuel receipts and legal documents.
- Tire sets and vehicle equipment are independent vehicle modules. Equipment can expire or be missing, so it contributes to dashboard alerts.
- Dashboard value comes from aggregating urgent states: overdue maintenance, expiring/expired legal documents, expiring/missing equipment, latest fuel receipt, active vehicles, and cost summaries.

## Standalone Application Decisions

- This project rebuilds the domain as a Spring Boot API and React app, not as Home Assistant entities/services.
- Licensing, Home Assistant services, Lovelace card code, backups, and entity registry concepts are intentionally excluded.
- The app targets one owner and personal vehicles only, so there is local authentication but no SaaS tenant model.
- External integrations such as CNAIR rovinieta lookup and OCR are left as future adapters; current records preserve source fields and OCR placeholders.
