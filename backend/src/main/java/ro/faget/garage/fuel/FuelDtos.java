package ro.faget.garage.fuel;

import jakarta.validation.constraints.DecimalMax;
import jakarta.validation.constraints.DecimalMin;
import jakarta.validation.constraints.Min;
import jakarta.validation.constraints.NotNull;

import java.math.BigDecimal;
import java.time.Instant;
import java.time.LocalDate;
import java.util.UUID;

public class FuelDtos {
    public record FuelReceiptRequest(
            @NotNull LocalDate receiptDate,
            String stationName,
            @NotNull FuelType fuelType,
            @DecimalMin("0.00") BigDecimal quantityLiters,
            @DecimalMin("0.00") BigDecimal unitPrice,
            @DecimalMin("0.00") BigDecimal totalAmount,
            @Min(0) Integer odometerKm,
            Boolean fullTank,
            FuelReceiptSource source,
            @DecimalMin("0.00") @DecimalMax("1.00") BigDecimal confidenceScore,
            String receiptImageUrl,
            String rawOcrText,
            String notes
    ) {}

    public record FuelReceiptResponse(
            UUID id,
            UUID vehicleId,
            LocalDate receiptDate,
            String stationName,
            FuelType fuelType,
            BigDecimal quantityLiters,
            BigDecimal unitPrice,
            BigDecimal totalAmount,
            Integer odometerKm,
            boolean fullTank,
            FuelReceiptSource source,
            BigDecimal confidenceScore,
            String receiptImageUrl,
            String rawOcrText,
            String notes,
            Instant createdAt,
            Instant updatedAt
    ) {}
}
