package ro.faget.garage.vehicle.lookup;

import org.springframework.stereotype.Component;

@Component
public class LocalVinDecoderProvider implements VehicleLookupProvider {
    @Override
    public VehicleLookupProviderResult lookup(VehicleLookupInput input) {
        VehicleLookupProviderResult result = new VehicleLookupProviderResult();
        if (input.vin() == null) {
            return result;
        }

        result.warnings().add("No local VIN metadata decoder is configured. VIN was validated only.");
        return result;
    }
}
