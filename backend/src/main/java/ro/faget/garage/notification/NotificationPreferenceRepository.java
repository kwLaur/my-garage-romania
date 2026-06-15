package ro.faget.garage.notification;

import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;
import java.util.Optional;
import java.util.UUID;

public interface NotificationPreferenceRepository extends JpaRepository<NotificationPreference, UUID> {
    List<NotificationPreference> findByAppUserIdAndVehicleIdOrderByEntityTypeAscEntityIdAsc(UUID appUserId, UUID vehicleId);
    Optional<NotificationPreference> findByAppUserIdAndEntityTypeAndEntityId(UUID appUserId, NotificationEntityType entityType, UUID entityId);
}
