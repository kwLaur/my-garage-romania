package ro.faget.garage.vehicle;

import static ro.faget.garage.vehicle.VehicleDtos.*;

public class VehicleMapper {
    private VehicleMapper() {}

    public static VehicleResponse toResponse(Vehicle vehicle) {
        return new VehicleResponse(vehicle.getId(), vehicle.getName(), vehicle.getLicensePlate(), vehicle.getVin(),
                vehicle.getBrand(), vehicle.getModel(), vehicle.getYear(), vehicle.getCurrentKm(), vehicle.getFuelProfile(),
                vehicle.getImageUrl(), vehicle.isActive(), vehicle.getCreatedAt(), vehicle.getUpdatedAt());
    }

    public static void apply(Vehicle vehicle, VehicleRequest request) {
        vehicle.setName(request.name());
        vehicle.setLicensePlate(request.licensePlate());
        vehicle.setVin(request.vin());
        vehicle.setBrand(request.brand());
        vehicle.setModel(request.model());
        vehicle.setYear(request.year());
        vehicle.setCurrentKm(request.currentKm() == null ? 0 : request.currentKm());
        vehicle.setFuelProfile(request.fuelProfile());
        vehicle.setImageUrl(request.imageUrl());
        vehicle.setActive(request.active() == null || request.active());
    }
}
