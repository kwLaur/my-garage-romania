package ro.faget.garage.equipment;

import jakarta.validation.constraints.DecimalMin;
import jakarta.validation.constraints.NotNull;

import java.math.BigDecimal;
import java.time.Instant;
import java.time.LocalDate;
import java.util.UUID;

public class EquipmentDtos {
    public record EquipmentRequest(@NotNull EquipmentType type, String name, LocalDate purchaseDate, LocalDate expiryDate,
                                   Boolean present, String location, @DecimalMin("0.00") BigDecimal cost, String notes) {}

    public record EquipmentResponse(UUID id, UUID vehicleId, EquipmentType type, String name, LocalDate purchaseDate,
                                    LocalDate expiryDate, boolean present, String location, BigDecimal cost, String notes,
                                    Instant createdAt, Instant updatedAt) {}
}
