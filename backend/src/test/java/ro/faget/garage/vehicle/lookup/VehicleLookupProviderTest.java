package ro.faget.garage.vehicle.lookup;

import org.junit.jupiter.api.Test;

import static org.assertj.core.api.Assertions.assertThat;

class VehicleLookupProviderTest {
    private final VehicleLookupInput input = new VehicleLookupInput("WV1ZZZ2HZJH012345", "B123ABC");

    @Test
    void cnairManualModeReturnsOfficialLinkWithoutHttpCall() {
        CnairRovinietaProperties properties = new CnairRovinietaProperties();
        properties.setEnabled(false);
        properties.setMode(ProviderMode.MANUAL);

        VehicleLookupProviderResult result = new CnairRovinietaProvider(properties).lookup(input);

        assertThat(result.externalLinks()).anyMatch(link -> link.type().equals("CNAIR_ROVINIETA"));
        assertThat(result.warnings()).contains("Automatic CNAIR API integration is not configured. Use the official CNAIR check page.");
        assertThat(result.rovinieta()).isNull();
    }

    @Test
    void rarManualModeReturnsOfficialLinkWithoutHttpCall() {
        RarAutoPassProperties properties = new RarAutoPassProperties();
        properties.setEnabled(false);
        properties.setMode(ProviderMode.MANUAL);

        VehicleLookupProviderResult result = new RarAutoPassProvider(properties).lookup(input);

        assertThat(result.externalLinks()).anyMatch(link -> link.type().equals("RAR_AUTOPASS"));
        assertThat(result.warnings()).contains("Automatic RAR Auto-Pass API integration is not configured. Use the official RAR Auto-Pass portal.");
        assertThat(result.rarAutoPass()).isNull();
    }
}
