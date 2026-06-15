package ro.faget.garage.tire;

import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import ro.faget.garage.common.NotFoundException;
import ro.faget.garage.vehicle.VehicleService;

import java.util.List;
import java.util.UUID;

import static ro.faget.garage.tire.TireDtos.*;

@Service
public class TireSetService {
    private final TireSetRepository tireSets;
    private final VehicleService vehicles;

    public TireSetService(TireSetRepository tireSets, VehicleService vehicles) {
        this.tireSets = tireSets;
        this.vehicles = vehicles;
    }

    @Transactional(readOnly = true)
    public List<TireSetResponse> list(UUID vehicleId) {
        vehicles.getEntity(vehicleId);
        return tireSets.findByVehicleIdOrderByInstalledDescCreatedAtDesc(vehicleId).stream().map(this::toResponse).toList();
    }

    @Transactional
    public TireSetResponse create(UUID vehicleId, TireSetRequest request) {
        TireSet tireSet = new TireSet();
        tireSet.setVehicle(vehicles.getEntity(vehicleId));
        apply(tireSet, request);
        return toResponse(tireSets.save(tireSet));
    }

    @Transactional
    public TireSetResponse update(UUID id, TireSetRequest request) {
        TireSet tireSet = tireSets.findById(id).orElseThrow(() -> new NotFoundException("Tire set not found"));
        apply(tireSet, request);
        return toResponse(tireSet);
    }

    @Transactional
    public void delete(UUID id) {
        tireSets.delete(tireSets.findById(id).orElseThrow(() -> new NotFoundException("Tire set not found")));
    }

    private void apply(TireSet tireSet, TireSetRequest request) {
        tireSet.setTireType(request.tireType());
        tireSet.setMountType(request.mountType());
        tireSet.setBrandModel(request.brandModel());
        tireSet.setSize(request.size());
        tireSet.setDot(request.dot());
        tireSet.setPurchaseDate(request.purchaseDate());
        tireSet.setTotalKm(request.totalKm());
        tireSet.setCost(request.cost());
        tireSet.setInstalled(Boolean.TRUE.equals(request.installed()));
        tireSet.setStorageLocation(request.storageLocation());
        tireSet.setPressureFront(request.pressureFront());
        tireSet.setPressureRear(request.pressureRear());
        tireSet.setNotes(request.notes());
    }

    private TireSetResponse toResponse(TireSet tireSet) {
        return new TireSetResponse(tireSet.getId(), tireSet.getVehicle().getId(), tireSet.getTireType(), tireSet.getMountType(),
                tireSet.getBrandModel(), tireSet.getSize(), tireSet.getDot(), tireSet.getPurchaseDate(), tireSet.getTotalKm(),
                tireSet.getCost(), tireSet.isInstalled(), tireSet.getStorageLocation(), tireSet.getPressureFront(),
                tireSet.getPressureRear(), tireSet.getNotes(), tireSet.getCreatedAt(), tireSet.getUpdatedAt());
    }
}
