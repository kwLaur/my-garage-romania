package ro.faget.garage.vehicle.lookup;

public final class LicensePlateNormalizer {
    private LicensePlateNormalizer() {
    }

    public static String normalize(String licensePlate) {
        if (licensePlate == null || licensePlate.trim().isEmpty()) {
            return null;
        }
        String normalized = licensePlate.trim().toUpperCase();
        normalized = normalized.replaceAll("[\\s-]+", "");
        return normalized.isBlank() ? null : normalized;
    }
}
