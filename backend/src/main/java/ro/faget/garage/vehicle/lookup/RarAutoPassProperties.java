package ro.faget.garage.vehicle.lookup;

import org.springframework.boot.context.properties.ConfigurationProperties;
import org.springframework.stereotype.Component;

@Component
@ConfigurationProperties(prefix = "app.integrations.rar-autopass")
public class RarAutoPassProperties {
    private boolean enabled;
    private ProviderMode mode = ProviderMode.MANUAL;
    private String officialUrl = "https://apps.rarom.ro/autopass-client";
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

    public String getOfficialUrl() {
        return officialUrl;
    }

    public void setOfficialUrl(String officialUrl) {
        this.officialUrl = officialUrl;
    }

    public String getApiBaseUrl() {
        return apiBaseUrl;
    }

    public void setApiBaseUrl(String apiBaseUrl) {
        this.apiBaseUrl = apiBaseUrl;
    }
}
