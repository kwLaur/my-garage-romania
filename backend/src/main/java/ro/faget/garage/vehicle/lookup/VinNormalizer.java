package ro.faget.garage.vehicle.lookup;

import ro.faget.garage.common.BadRequestException;

public final class VinNormalizer {
    private static final String FORBIDDEN_CHARACTERS = "IOQ";

    private VinNormalizer() {
    }

    public static String normalize(String vin) {
        if (vin == null || vin.trim().isEmpty()) {
            return null;
        }
        String normalized = vin.trim().toUpperCase();
        if (normalized.length() != 17) {
            throw new BadRequestException("VIN must have 17 characters");
        }
        if (normalized.chars().anyMatch(character -> FORBIDDEN_CHARACTERS.indexOf(character) >= 0)) {
            throw new BadRequestException("VIN cannot contain I, O, or Q");
        }
        return normalized;
    }
}
