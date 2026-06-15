package ro.faget.garage.fuel;

import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;
import java.util.Optional;
import java.util.UUID;

public interface FuelReceiptRepository extends JpaRepository<FuelReceipt, UUID> {
    List<FuelReceipt> findByVehicleIdOrderByReceiptDateDescCreatedAtDesc(UUID vehicleId);
    Optional<FuelReceipt> findFirstByOrderByReceiptDateDescCreatedAtDesc();
}
