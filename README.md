# My Garage Romania

Production-shaped personal car manager for Romanian vehicle ownership: vehicles, maintenance, legal documents, fuel receipts with image upload, expenses, tires, equipment, and dashboard alerts.

## Stack

- Backend: Java 21, Spring Boot 3, Gradle, Spring Data JPA, PostgreSQL, Flyway, Spring Security JWT
- Frontend: React, Vite, TypeScript, Tailwind CSS, Recharts
- Local infrastructure: Docker Compose with PostgreSQL

## Default Login

- Email: `admin@garage.local`
- Password: `garage123`

Change these with `APP_DEFAULT_USER_EMAIL` and `APP_DEFAULT_USER_PASSWORD` before first startup in a real environment.

## Run With Docker Compose

```bash
docker compose up --build
```

If your Docker installation exposes the legacy hyphenated command instead:

```bash
docker-compose up --build
```

Services:

- PostgreSQL: `localhost:5432`
- Backend API: `http://localhost:8080`
- Swagger UI: `http://localhost:8080/swagger-ui.html`
- Frontend: `http://localhost:5173`

## Run Locally

Start only PostgreSQL:

```bash
docker compose up postgres
```

Run the backend with Gradle from the repository root:

```bash
gradle :backend:bootRun
```

Run backend tests:

```bash
gradle :backend:test
```

Run the frontend:

```bash
cd frontend
npm install
npm run dev
```

Build the frontend:

```bash
cd frontend
npm run build
```

## iPhone Local Development

Use these steps to install the iOS app on a physical iPhone and connect it to the backend running on your Mac.

1. Start PostgreSQL and the backend:

```bash
docker compose up postgres
gradle :backend:bootRun
```

2. Start the web app:

```bash
cd frontend
npm run dev
```

3. Find your Mac Wi-Fi LAN IP:

```bash
ipconfig getifaddr en0
```

4. Confirm the backend is reachable from the Mac:

```bash
curl http://localhost:8080/api/health
```

Expected response:

```json
{"status":"UP","app":"my-garage-romania"}
```

5. On iPhone Safari, test the backend over Wi-Fi:

```text
http://<MAC_IP>:8080/api/health
```

Swagger should also be reachable at:

```text
http://<MAC_IP>:8080/swagger-ui/index.html
```

6. Open `ios/MyGarageRomania.xcodeproj` in Xcode.

7. Select your iPhone device in the run destination.

8. In Signing & Capabilities, set your Team. If Xcode reports a bundle identifier conflict, set a unique Bundle Identifier.

9. Run the app from Xcode. If iOS prompts you to trust the developer profile, open iPhone Settings and trust the profile.

10. In the app, open Settings and set API Base URL:

```text
http://<MAC_IP>:8080
```

11. Tap Test Connection. `Connected` means the app can reach the backend. `Unauthorized but server reachable` means networking is fine but the saved token is missing or invalid.

12. Login, scan a receipt, review and correct the extracted fields, save the receipt, then verify it in the web dashboard.

Development ATS note: the iOS app currently allows arbitrary HTTP loads for Simulator and LAN-device testing. Remove that before production or TestFlight.

## API Notes

All `/api/**` endpoints require a JWT except `POST /api/auth/login`, `GET /api/health`, and Swagger/OpenAPI documentation. Use:

```http
Authorization: Bearer <token>
```

Fuel receipt upload endpoint:

```http
POST /api/vehicles/{vehicleId}/fuel-receipts/with-image
Content-Type: multipart/form-data
```

Parts:

- `metadata`: JSON matching the fuel receipt request
- `image`: JPEG, PNG, or WEBP, max 5 MB

Uploaded receipt paths are stored as relative URLs like `/uploads/receipts/<file>`. Files are stored on the backend filesystem under `uploads/receipts` locally or `/app/uploads/receipts` in Docker.

## Vehicle Lookup and Romanian Providers

Vehicle lookup is available at:

```http
POST /api/vehicles/lookup
Authorization: Bearer <token>
Content-Type: application/json
```

```json
{
  "vin": "WV1ZZZ2HZJH012345",
  "licensePlate": "B 123 ABC"
}
```

The backend validates VIN values when provided:

- VIN is trimmed and uppercased.
- VIN must have exactly 17 characters.
- VIN cannot contain `I`, `O`, or `Q`.

The backend normalizes license plates for lookup by uppercasing and removing spaces and hyphens. For example, `B 123-ABC` becomes `B123ABC`.

The current implementation provides a safe lookup foundation only. It returns normalized input, warnings, and official external links where automatic providers are not configured. It does not invent brand/model/year data when a reliable provider has not supplied it.

### CNAIR rovinieta

CNAIR official rovinieta verification requires both license plate and VIN/chassis series. This project does not scrape CNAIR, does not bypass CAPTCHA or verification codes, and does not call undocumented internal endpoints.

The CNAIR provider is disabled/manual by default:

```yaml
app:
  integrations:
    cnair:
      enabled: false
      mode: MANUAL
      official-check-url: https://www.cnadnr.ro/ro/verificare-rovinieta
```

In manual mode, the backend returns a warning and an official CNAIR link. The iOS app opens that official page for the user. Future `API` mode should be enabled only if an official/stable API contract is configured, including base URL, authentication, request/response contract, timeout behavior, and failure handling.

### RAR Auto-Pass

RAR Auto-Pass is the official RAR path for vehicle history/certificate. This project does not scrape RAR Auto-Pass, does not automate paid certificate flows, and does not store personal billing details.

The RAR Auto-Pass provider is disabled/manual by default:

```yaml
app:
  integrations:
    rar-autopass:
      enabled: false
      mode: MANUAL
      official-url: https://apps.rarom.ro/autopass-client
```

In manual mode, the backend returns a warning and the official RAR Auto-Pass link. The iOS app can open that official portal from vehicle lookup results. Future `API` mode should be enabled only if an official/vendor API contract is configured.

## Database

Flyway migrations:

- `V1__init_schema.sql`: schema, constraints, and indexes
- `V2__seed_sample_data.sql`: two vehicles and starter records

Rollback note: for local development, dropping the database volume resets all state:

```bash
docker compose down -v
```

Do not use that command against data you need to keep.

## Main Endpoints

- `POST /api/auth/login`
- `GET /api/health`
- `GET /api/auth/me`
- `GET|POST /api/vehicles`
- `POST /api/vehicles/lookup`
- `GET|PUT|DELETE /api/vehicles/{id}`
- `PUT /api/vehicles/{id}/odometer`
- `GET|POST /api/vehicles/{vehicleId}/maintenance`
- `PUT|DELETE /api/maintenance/{id}`
- `GET|POST /api/vehicles/{vehicleId}/legal-documents`
- `PUT|DELETE /api/legal-documents/{id}`
- `GET|POST /api/vehicles/{vehicleId}/fuel-receipts`
- `POST /api/vehicles/{vehicleId}/fuel-receipts/with-image`
- `PUT|DELETE /api/fuel-receipts/{id}`
- `GET|POST /api/vehicles/{vehicleId}/expenses`
- `PUT|DELETE /api/expenses/{id}`
- `GET|POST /api/vehicles/{vehicleId}/tire-sets`
- `PUT|DELETE /api/tire-sets/{id}`
- `GET|POST /api/vehicles/{vehicleId}/equipment`
- `PUT|DELETE /api/equipment/{id}`
- `GET /api/dashboard/overview`
- `GET /api/dashboard/alerts`
- `GET /api/dashboard/costs/monthly?year=YYYY`
- `GET /api/dashboard/costs/yearly`
