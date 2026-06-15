package ro.faget.garage.notification;

import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import ro.faget.garage.auth.AppUser;
import ro.faget.garage.auth.CurrentUserService;
import ro.faget.garage.common.BadRequestException;
import ro.faget.garage.common.NotFoundException;
import ro.faget.garage.legal.LegalDocument;
import ro.faget.garage.legal.LegalDocumentRepository;
import ro.faget.garage.maintenance.MaintenanceItem;
import ro.faget.garage.maintenance.MaintenanceRepository;
import ro.faget.garage.vehicle.Vehicle;
import ro.faget.garage.vehicle.VehicleService;

import java.util.List;
import java.util.UUID;

import static ro.faget.garage.notification.NotificationPreferenceDtos.*;

@Service
public class NotificationPreferenceService {
    private final NotificationPreferenceRepository preferences;
    private final CurrentUserService currentUserService;
    private final VehicleService vehicles;
    private final LegalDocumentRepository legalDocuments;
    private final MaintenanceRepository maintenance;

    public NotificationPreferenceService(NotificationPreferenceRepository preferences, CurrentUserService currentUserService,
                                         VehicleService vehicles, LegalDocumentRepository legalDocuments,
                                         MaintenanceRepository maintenance) {
        this.preferences = preferences;
        this.currentUserService = currentUserService;
        this.vehicles = vehicles;
        this.legalDocuments = legalDocuments;
        this.maintenance = maintenance;
    }

    @Transactional(readOnly = true)
    public List<NotificationPreferenceResponse> list(UUID vehicleId) {
        AppUser user = currentUserService.currentUser();
        vehicles.getEntity(vehicleId);
        return preferences.findByAppUserIdAndVehicleIdOrderByEntityTypeAscEntityIdAsc(user.getId(), vehicleId).stream()
                .map(this::toResponse)
                .toList();
    }

    @Transactional(readOnly = true)
    public NotificationPreferenceResponse get(NotificationEntityType entityType, UUID entityId) {
        AppUser user = currentUserService.currentUser();
        return preferences.findByAppUserIdAndEntityTypeAndEntityId(user.getId(), entityType, entityId)
                .map(this::toResponse)
                .orElseThrow(() -> new NotFoundException("Notification preference not found"));
    }

    @Transactional
    public NotificationPreferenceResponse upsert(NotificationEntityType entityType, UUID entityId, NotificationPreferenceRequest request) {
        AppUser user = currentUserService.currentUser();
        Vehicle vehicle = resolveAndValidateEntityVehicle(entityType, entityId, request.vehicleId());
        List<Integer> reminderDays = NotificationPreferenceValidator.normalizeReminderDays(request.reminderDaysBefore());
        String notificationTime = NotificationPreferenceValidator.normalizeNotificationTime(request.notificationTime());

        NotificationPreference preference = preferences.findByAppUserIdAndEntityTypeAndEntityId(user.getId(), entityType, entityId)
                .orElseGet(() -> {
                    NotificationPreference created = new NotificationPreference();
                    created.setAppUser(user);
                    created.setEntityType(entityType);
                    created.setEntityId(entityId);
                    return created;
                });

        preference.setVehicle(vehicle);
        preference.setEnabled(request.enabled());
        preference.setReminderDaysBefore(reminderDays);
        preference.setNotifyOnDueDate(request.notifyOnDueDate());
        preference.setNotificationTime(notificationTime);
        return toResponse(preferences.save(preference));
    }

    @Transactional
    public void delete(NotificationEntityType entityType, UUID entityId) {
        AppUser user = currentUserService.currentUser();
        preferences.findByAppUserIdAndEntityTypeAndEntityId(user.getId(), entityType, entityId)
                .ifPresent(preferences::delete);
    }

    private Vehicle resolveAndValidateEntityVehicle(NotificationEntityType entityType, UUID entityId, UUID vehicleId) {
        Vehicle vehicle = vehicles.getEntity(vehicleId);
        UUID actualVehicleId = switch (entityType) {
            case LEGAL_DOCUMENT -> legalDocuments.findById(entityId)
                    .map(LegalDocument::getVehicle)
                    .map(Vehicle::getId)
                    .orElseThrow(() -> new NotFoundException("Legal document not found"));
            case MAINTENANCE -> maintenance.findById(entityId)
                    .map(MaintenanceItem::getVehicle)
                    .map(Vehicle::getId)
                    .orElseThrow(() -> new NotFoundException("Maintenance item not found"));
        };
        if (!vehicle.getId().equals(actualVehicleId)) {
            throw new BadRequestException("vehicleId does not match the notification entity");
        }
        return vehicle;
    }

    private NotificationPreferenceResponse toResponse(NotificationPreference preference) {
        return new NotificationPreferenceResponse(preference.getId(), preference.getVehicle().getId(),
                preference.getEntityType(), preference.getEntityId(), preference.isEnabled(),
                preference.getReminderDaysBefore(), preference.isNotifyOnDueDate(), preference.getNotificationTime(),
                preference.getCreatedAt(), preference.getUpdatedAt());
    }
}
