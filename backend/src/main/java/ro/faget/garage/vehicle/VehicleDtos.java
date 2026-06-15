package ro.faget.garage.vehicle;

import jakarta.validation.constraints.Min;
import jakarta.validation.constraints.NotBlank;

import java.time.Instant;
import java.util.UUID;

public class VehicleDtos {
    public record VehicleRequest(
            @NotBlank String name,
            @NotBlank String licensePlate,
            String vin,
            String brand,
            String model,
            @Min(1886) Integer year,
            @Min(0) Integer currentKm,
            String fuelProfile,
            String imageUrl,
            Boolean active
    ) {}

    public record OdometerRequest(@Min(0) Integer currentKm) {}

    public record VehicleResponse(
            UUID id,
            String name,
            String licensePlate,
            String vin,
            String brand,
            String model,
            Integer year,
            Integer currentKm,
            String fuelProfile,
            String imageUrl,
            boolean active,
            Instant createdAt,
            Instant updatedAt
    ) {}
}
