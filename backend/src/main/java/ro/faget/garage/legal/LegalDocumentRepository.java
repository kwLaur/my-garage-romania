package ro.faget.garage.legal;

import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;
import java.util.UUID;

public interface LegalDocumentRepository extends JpaRepository<LegalDocument, UUID> {
    List<LegalDocument> findByVehicleIdOrderByEndDateAsc(UUID vehicleId);
    List<LegalDocument> findAllByOrderByEndDateAsc();
}
