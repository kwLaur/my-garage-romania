package ro.faget.garage.vehicle.lookup;

import java.util.List;

public class VehicleLookupDtos {
    public record VehicleLookupRequest(String vin, String licensePlate) {}

    public record VehicleLookupResponse(
            String vin,
            String licensePlate,
            String brand,
            String model,
            Integer year,
            String fuelProfile,
            CnairRovinietaStatus rovinieta,
            CnairRovinietaStatus itp,
            RarAutoPassStatus rarAutoPass,
            List<String> warnings,
            List<ExternalLink> externalLinks
    ) {}

    public record ExternalLink(String type, String label, String url) {}

    public record CnairRovinietaStatus(String status, String validUntil, String source) {}

    public record RarAutoPassStatus(String status, String source) {}
}
