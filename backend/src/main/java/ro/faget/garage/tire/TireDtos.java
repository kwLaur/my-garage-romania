package ro.faget.garage.tire;

import jakarta.validation.constraints.DecimalMin;
import jakarta.validation.constraints.Min;
import jakarta.validation.constraints.NotNull;

import java.math.BigDecimal;
import java.time.Instant;
import java.time.LocalDate;
import java.util.UUID;

public class TireDtos {
    public record TireSetRequest(
            @NotNull TireType tireType,
            @NotNull TireMountType mountType,
            String brandModel,
            String size,
            String dot,
            LocalDate purchaseDate,
            @Min(0) Integer totalKm,
            @DecimalMin("0.00") BigDecimal cost,
            Boolean installed,
            String storageLocation,
            @DecimalMin("0.00") BigDecimal pressureFront,
            @DecimalMin("0.00") BigDecimal pressureRear,
            String notes
    ) {}

    public record TireSetResponse(UUID id, UUID vehicleId, TireType tireType, TireMountType mountType, String brandModel,
                                  String size, String dot, LocalDate purchaseDate, Integer totalKm, BigDecimal cost,
                                  boolean installed, String storageLocation, BigDecimal pressureFront, BigDecimal pressureRear,
                                  String notes, Instant createdAt, Instant updatedAt) {}
}
