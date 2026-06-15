package ro.faget.garage.equipment;

import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;
import java.util.UUID;

public interface EquipmentRepository extends JpaRepository<EquipmentItem, UUID> {
    List<EquipmentItem> findByVehicleIdOrderByTypeAsc(UUID vehicleId);
    List<EquipmentItem> findAllByOrderByCreatedAtDesc();
}
