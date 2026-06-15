package ro.faget.garage.maintenance;

import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import ro.faget.garage.common.NotFoundException;
import ro.faget.garage.vehicle.Vehicle;
import ro.faget.garage.vehicle.VehicleService;

import java.util.List;
import java.util.UUID;

import static ro.faget.garage.maintenance.MaintenanceDtos.*;

@Service
public class MaintenanceService {
    private final MaintenanceRepository maintenance;
    private final VehicleService vehicles;
    private final MaintenanceCalculator calculator;

    public MaintenanceService(MaintenanceRepository maintenance, VehicleService vehicles, MaintenanceCalculator calculator) {
        this.maintenance = maintenance;
        this.vehicles = vehicles;
        this.calculator = calculator;
    }

    @Transactional(readOnly = true)
    public List<MaintenanceResponse> list(UUID vehicleId) {
        vehicles.getEntity(vehicleId);
        return maintenance.findByVehicleIdOrderByTypeAsc(vehicleId).stream().map(this::toResponse).toList();
    }

    @Transactional
    public MaintenanceResponse create(UUID vehicleId, MaintenanceRequest request) {
        MaintenanceItem item = new MaintenanceItem();
        item.setVehicle(vehicles.getEntity(vehicleId));
        apply(item, request);
        return toResponse(maintenance.save(item));
    }

    @Transactional
    public MaintenanceResponse update(UUID id, MaintenanceRequest request) {
        MaintenanceItem item = maintenance.findById(id).orElseThrow(() -> new NotFoundException("Maintenance item not found"));
        apply(item, request);
        return toResponse(item);
    }

    @Transactional
    public void delete(UUID id) {
        maintenance.delete(maintenance.findById(id).orElseThrow(() -> new NotFoundException("Maintenance item not found")));
    }

    public MaintenanceResponse toResponse(MaintenanceItem item) {
        Vehicle vehicle = item.getVehicle();
        MaintenanceProjection projection = calculator.calculate(vehicle.getCurrentKm(), item.getLastKm(), item.getLastDate(), item.getIntervalKm(), item.getIntervalDays());
        return new MaintenanceResponse(item.getId(), vehicle.getId(), item.getType(), item.getLastKm(), item.getLastDate(), item.getIntervalKm(),
                item.getIntervalDays(), item.getCost(), item.getNotes(), projection.kmRemaining(), projection.daysRemaining(),
                projection.nextDueKm(), projection.nextDueDate(), projection.status(), item.getCreatedAt(), item.getUpdatedAt());
    }

    private void apply(MaintenanceItem item, MaintenanceRequest request) {
        item.setType(request.type());
        item.setLastKm(request.lastKm());
        item.setLastDate(request.lastDate());
        item.setIntervalKm(request.intervalKm());
        item.setIntervalDays(request.intervalDays());
        item.setCost(request.cost());
        item.setNotes(request.notes());
    }
}
