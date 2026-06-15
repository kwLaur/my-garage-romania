package ro.faget.garage.maintenance;

import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;
import java.util.UUID;

public interface MaintenanceRepository extends JpaRepository<MaintenanceItem, UUID> {
    List<MaintenanceItem> findByVehicleIdOrderByTypeAsc(UUID vehicleId);
    List<MaintenanceItem> findAllByOrderByCreatedAtDesc();
}
