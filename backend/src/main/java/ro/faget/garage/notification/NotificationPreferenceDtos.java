package ro.faget.garage.notification;

import jakarta.validation.constraints.NotNull;

import java.time.Instant;
import java.util.List;
import java.util.UUID;

public class NotificationPreferenceDtos {
    public record NotificationPreferenceRequest(
            @NotNull UUID vehicleId,
            boolean enabled,
            List<Integer> reminderDaysBefore,
            boolean notifyOnDueDate,
            String notificationTime
    ) {}

    public record NotificationPreferenceResponse(
            UUID id,
            UUID vehicleId,
            NotificationEntityType entityType,
            UUID entityId,
            boolean enabled,
            List<Integer> reminderDaysBefore,
            boolean notifyOnDueDate,
            String notificationTime,
            Instant createdAt,
            Instant updatedAt
    ) {}
}
