package ro.faget.garage.vehicle.lookup;

public interface VehicleLookupProvider {
    VehicleLookupProviderResult lookup(VehicleLookupInput input);
}
