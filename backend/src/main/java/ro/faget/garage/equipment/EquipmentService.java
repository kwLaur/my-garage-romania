package ro.faget.garage.equipment;

import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import ro.faget.garage.common.NotFoundException;
import ro.faget.garage.vehicle.VehicleService;

import java.util.List;
import java.util.UUID;

import static ro.faget.garage.equipment.EquipmentDtos.*;

@Service
public class EquipmentService {
    private final EquipmentRepository equipment;
    private final VehicleService vehicles;

    public EquipmentService(EquipmentRepository equipment, VehicleService vehicles) {
        this.equipment = equipment;
        this.vehicles = vehicles;
    }

    @Transactional(readOnly = true)
    public List<EquipmentResponse> list(UUID vehicleId) {
        vehicles.getEntity(vehicleId);
        return equipment.findByVehicleIdOrderByTypeAsc(vehicleId).stream().map(this::toResponse).toList();
    }

    @Transactional
    public EquipmentResponse create(UUID vehicleId, EquipmentRequest request) {
        EquipmentItem item = new EquipmentItem();
        item.setVehicle(vehicles.getEntity(vehicleId));
        apply(item, request);
        return toResponse(equipment.save(item));
    }

    @Transactional
    public EquipmentResponse update(UUID id, EquipmentRequest request) {
        EquipmentItem item = equipment.findById(id).orElseThrow(() -> new NotFoundException("Equipment item not found"));
        apply(item, request);
        return toResponse(item);
    }

    @Transactional
    public void delete(UUID id) {
        equipment.delete(equipment.findById(id).orElseThrow(() -> new NotFoundException("Equipment item not found")));
    }

    private void apply(EquipmentItem item, EquipmentRequest request) {
        item.setType(request.type());
        item.setName(request.name());
        item.setPurchaseDate(request.purchaseDate());
        item.setExpiryDate(request.expiryDate());
        item.setPresent(request.present() == null || request.present());
        item.setLocation(request.location());
        item.setCost(request.cost());
        item.setNotes(request.notes());
    }

    public EquipmentResponse toResponse(EquipmentItem item) {
        return new EquipmentResponse(item.getId(), item.getVehicle().getId(), item.getType(), item.getName(), item.getPurchaseDate(),
                item.getExpiryDate(), item.isPresent(), item.getLocation(), item.getCost(), item.getNotes(), item.getCreatedAt(), item.getUpdatedAt());
    }
}
