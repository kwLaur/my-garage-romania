package ro.faget.garage.expense;

import jakarta.validation.constraints.DecimalMin;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;

import java.math.BigDecimal;
import java.time.Instant;
import java.time.LocalDate;
import java.util.UUID;

public class ExpenseDtos {
    public record ExpenseRequest(
            @NotBlank String title,
            String description,
            @NotNull @DecimalMin("0.00") BigDecimal amount,
            @NotNull LocalDate date,
            @NotNull ExpenseType type,
            LinkedEntityType linkedEntityType,
            UUID linkedEntityId
    ) {}

    public record ExpenseResponse(
            UUID id,
            UUID vehicleId,
            String title,
            String description,
            BigDecimal amount,
            LocalDate date,
            ExpenseType type,
            LinkedEntityType linkedEntityType,
            UUID linkedEntityId,
            Instant createdAt,
            Instant updatedAt
    ) {}
}
