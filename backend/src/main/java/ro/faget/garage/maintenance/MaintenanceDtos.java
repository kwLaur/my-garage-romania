package ro.faget.garage.maintenance;

import jakarta.validation.constraints.DecimalMin;
import jakarta.validation.constraints.Min;
import jakarta.validation.constraints.NotNull;

import java.math.BigDecimal;
import java.time.Instant;
import java.time.LocalDate;
import java.util.UUID;

public class MaintenanceDtos {
    public record MaintenanceRequest(
            @NotNull MaintenanceType type,
            @Min(0) Integer lastKm,
            LocalDate lastDate,
            @Min(0) Integer intervalKm,
            @Min(0) Integer intervalDays,
            @DecimalMin("0.00") BigDecimal cost,
            String notes
    ) {}

    public record MaintenanceResponse(
            UUID id,
            UUID vehicleId,
            MaintenanceType type,
            Integer lastKm,
            LocalDate lastDate,
            Integer intervalKm,
            Integer intervalDays,
            BigDecimal cost,
            String notes,
            Integer kmRemaining,
            Integer daysRemaining,
            Integer nextDueKm,
            LocalDate nextDueDate,
            MaintenanceStatus status,
            Instant createdAt,
            Instant updatedAt
    ) {}

    public record MaintenanceProjection(Integer kmRemaining, Integer daysRemaining, Integer nextDueKm,
                                        LocalDate nextDueDate, MaintenanceStatus status) {}
}
