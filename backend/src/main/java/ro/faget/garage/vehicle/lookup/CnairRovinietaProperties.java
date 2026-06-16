package ro.faget.garage.vehicle.lookup;

import org.springframework.boot.context.properties.ConfigurationProperties;
import org.springframework.stereotype.Component;

@Component
@ConfigurationProperties(prefix = "app.integrations.cnair")
public class CnairRovinietaProperties {
    private boolean enabled;
    private ProviderMode mode = ProviderMode.MANUAL;
    private String officialCheckUrl = "https://www.cnadnr.ro/ro/verificare-rovinieta";
    private String apiBaseUrl;

    public boolean isEnabled() {
        return enabled;
    }

    public void setEnabled(boolean enabled) {
        this.enabled = enabled;
    }

    public ProviderMode getMode() {
        return mode;
    }

    public void setMode(ProviderMode mode) {
        this.mode = mode;
    }

    public String getOfficialCheckUrl() {
        return officialCheckUrl;
    }

    public void setOfficialCheckUrl(String officialCheckUrl) {
        this.officialCheckUrl = officialCheckUrl;
    }

    public String getApiBaseUrl() {
        return apiBaseUrl;
    }

    public void setApiBaseUrl(String apiBaseUrl) {
        this.apiBaseUrl = apiBaseUrl;
    }
}
