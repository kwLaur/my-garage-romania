package ro.faget.garage.vehicle.lookup;

import org.springframework.stereotype.Component;

import static ro.faget.garage.vehicle.lookup.VehicleLookupDtos.ExternalLink;

@Component
public class RarAutoPassProvider implements VehicleLookupProvider {
    private static final String LINK_TYPE = "RAR_AUTOPASS";
    private static final String LINK_LABEL = "RAR Auto-Pass";
    private final RarAutoPassProperties properties;

    public RarAutoPassProvider(RarAutoPassProperties properties) {
        this.properties = properties;
    }

    @Override
    public VehicleLookupProviderResult lookup(VehicleLookupInput input) {
        VehicleLookupProviderResult result = new VehicleLookupProviderResult();
        ProviderMode mode = properties.isEnabled() ? properties.getMode() : ProviderMode.MANUAL;
        if (properties.isEnabled() && mode == ProviderMode.DISABLED) {
            result.warnings().add("RAR Auto-Pass provider is disabled.");
            return result;
        }

        if (mode == ProviderMode.API) {
            if (isBlank(properties.getApiBaseUrl())) {
                result.warnings().add("Automatic RAR Auto-Pass API integration is not configured. Use the official RAR Auto-Pass portal.");
                addOfficialLink(result);
                return result;
            }
            result.warnings().add("RAR Auto-Pass API adapter is configured but no official contract implementation is enabled yet.");
            addOfficialLink(result);
            return result;
        }

        addOfficialLink(result);
        result.warnings().add("Automatic RAR Auto-Pass API integration is not configured. Use the official RAR Auto-Pass portal.");
        return result;
    }

    private void addOfficialLink(VehicleLookupProviderResult result) {
        if (!isBlank(properties.getOfficialUrl())) {
            result.externalLinks().add(new ExternalLink(LINK_TYPE, LINK_LABEL, properties.getOfficialUrl()));
        }
    }

    private boolean isBlank(String value) {
        return value == null || value.isBlank();
    }
}
