package ro.faget.garage.tire;

import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;
import java.util.UUID;

public interface TireSetRepository extends JpaRepository<TireSet, UUID> {
    List<TireSet> findByVehicleIdOrderByInstalledDescCreatedAtDesc(UUID vehicleId);
}
