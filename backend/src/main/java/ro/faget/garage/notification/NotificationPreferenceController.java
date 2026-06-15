package ro.faget.garage.notification;

import jakarta.validation.Valid;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;
import java.util.UUID;

import static ro.faget.garage.notification.NotificationPreferenceDtos.*;

@RestController
@RequestMapping("/api")
public class NotificationPreferenceController {
    private final NotificationPreferenceService notificationPreferences;

    public NotificationPreferenceController(NotificationPreferenceService notificationPreferences) {
        this.notificationPreferences = notificationPreferences;
    }

    @GetMapping("/vehicles/{vehicleId}/notification-preferences")
    List<NotificationPreferenceResponse> list(@PathVariable UUID vehicleId) {
        return notificationPreferences.list(vehicleId);
    }

    @GetMapping("/notification-preferences/{entityType}/{entityId}")
    NotificationPreferenceResponse get(@PathVariable NotificationEntityType entityType, @PathVariable UUID entityId) {
        return notificationPreferences.get(entityType, entityId);
    }

    @PutMapping("/notification-preferences/{entityType}/{entityId}")
    NotificationPreferenceResponse upsert(@PathVariable NotificationEntityType entityType, @PathVariable UUID entityId,
                                          @Valid @RequestBody NotificationPreferenceRequest request) {
        return notificationPreferences.upsert(entityType, entityId, request);
    }

    @DeleteMapping("/notification-preferences/{entityType}/{entityId}")
    void delete(@PathVariable NotificationEntityType entityType, @PathVariable UUID entityId) {
        notificationPreferences.delete(entityType, entityId);
    }
}
