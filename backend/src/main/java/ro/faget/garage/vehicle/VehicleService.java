package ro.faget.garage.vehicle;

import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import ro.faget.garage.common.NotFoundException;

import java.util.List;
import java.util.UUID;

import static ro.faget.garage.vehicle.VehicleDtos.*;

@Service
public class VehicleService {
    private final VehicleRepository vehicles;

    public VehicleService(VehicleRepository vehicles) {
        this.vehicles = vehicles;
    }

    @Transactional(readOnly = true)
    public List<VehicleResponse> list() {
        return vehicles.findAllByOrderByCreatedAtDesc().stream().map(VehicleMapper::toResponse).toList();
    }

    @Transactional(readOnly = true)
    public Vehicle getEntity(UUID id) {
        return vehicles.findById(id).orElseThrow(() -> new NotFoundException("Vehicle not found"));
    }

    @Transactional(readOnly = true)
    public VehicleResponse get(UUID id) {
        return VehicleMapper.toResponse(getEntity(id));
    }

    @Transactional
    public VehicleResponse create(VehicleRequest request) {
        Vehicle vehicle = new Vehicle();
        VehicleMapper.apply(vehicle, request);
        return VehicleMapper.toResponse(vehicles.save(vehicle));
    }

    @Transactional
    public VehicleResponse update(UUID id, VehicleRequest request) {
        Vehicle vehicle = getEntity(id);
        VehicleMapper.apply(vehicle, request);
        return VehicleMapper.toResponse(vehicle);
    }

    @Transactional
    public VehicleResponse updateOdometer(UUID id, OdometerRequest request) {
        Vehicle vehicle = getEntity(id);
        vehicle.setCurrentKm(request.currentKm());
        return VehicleMapper.toResponse(vehicle);
    }

    @Transactional
    public void delete(UUID id) {
        vehicles.delete(getEntity(id));
    }
}
