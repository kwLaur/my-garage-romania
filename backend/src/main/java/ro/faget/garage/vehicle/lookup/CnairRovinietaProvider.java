package ro.faget.garage.vehicle.lookup;

import org.springframework.stereotype.Component;

import static ro.faget.garage.vehicle.lookup.VehicleLookupDtos.ExternalLink;

@Component
public class CnairRovinietaProvider implements VehicleLookupProvider {
    private static final String LINK_TYPE = "CNAIR_ROVINIETA";
    private static final String LINK_LABEL = "Official CNAIR rovinietă check";
    private final CnairRovinietaProperties properties;

    public CnairRovinietaProvider(CnairRovinietaProperties properties) {
        this.properties = properties;
    }

    @Override
    public VehicleLookupProviderResult lookup(VehicleLookupInput input) {
        VehicleLookupProviderResult result = new VehicleLookupProviderResult();
        ProviderMode mode = properties.isEnabled() ? properties.getMode() : ProviderMode.MANUAL;
        if (properties.isEnabled() && mode == ProviderMode.DISABLED) {
            result.warnings().add("CNAIR rovinietă provider is disabled.");
            return result;
        }

        if (mode == ProviderMode.API) {
            if (isBlank(properties.getApiBaseUrl())) {
                result.warnings().add("Automatic CNAIR API integration is not configured. Use the official CNAIR check page.");
                addOfficialLink(result);
                return result;
            }
            result.warnings().add("CNAIR API adapter is configured but no official contract implementation is enabled yet.");
            addOfficialLink(result);
            return result;
        }

        addOfficialLink(result);
        result.warnings().add("Automatic CNAIR API integration is not configured. Use the official CNAIR check page.");
        return result;
    }

    private void addOfficialLink(VehicleLookupProviderResult result) {
        if (!isBlank(properties.getOfficialCheckUrl())) {
            result.externalLinks().add(new ExternalLink(LINK_TYPE, LINK_LABEL, properties.getOfficialCheckUrl()));
        }
    }

    private boolean isBlank(String value) {
        return value == null || value.isBlank();
    }
}
