package ro.faget.garage.legal;

import jakarta.validation.constraints.DecimalMin;
import jakarta.validation.constraints.NotNull;

import java.math.BigDecimal;
import java.time.Instant;
import java.time.LocalDate;
import java.util.UUID;

public class LegalDtos {
    public record LegalDocumentRequest(
            @NotNull LegalDocumentType type,
            LocalDate startDate,
            LocalDate endDate,
            String provider,
            String policyNumber,
            String documentUrl,
            @DecimalMin("0.00") BigDecimal cost,
            LegalDocumentSource source,
            Boolean ignored,
            String notes
    ) {}

    public record LegalDocumentResponse(
            UUID id,
            UUID vehicleId,
            LegalDocumentType type,
            LocalDate startDate,
            LocalDate endDate,
            String provider,
            String policyNumber,
            String documentUrl,
            BigDecimal cost,
            LegalDocumentSource source,
            boolean ignored,
            String notes,
            Integer daysRemaining,
            LegalDocumentStatus status,
            Instant createdAt,
            Instant updatedAt
    ) {}

    public record LegalStatusProjection(Integer daysRemaining, LegalDocumentStatus status) {}
}
