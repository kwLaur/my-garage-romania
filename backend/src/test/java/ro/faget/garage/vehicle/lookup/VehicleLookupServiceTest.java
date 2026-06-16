package ro.faget.garage.vehicle.lookup;

import org.junit.jupiter.api.Test;

import java.util.List;

import static org.assertj.core.api.Assertions.assertThat;
import static ro.faget.garage.vehicle.lookup.VehicleLookupDtos.VehicleLookupRequest;

class VehicleLookupServiceTest {
    @Test
    void lookupReturnsWarningsAndExternalLinksWhenProvidersAreManual() {
        CnairRovinietaProperties cnair = new CnairRovinietaProperties();
        cnair.setEnabled(false);
        cnair.setMode(ProviderMode.MANUAL);
        RarAutoPassProperties rar = new RarAutoPassProperties();
        rar.setEnabled(false);
        rar.setMode(ProviderMode.MANUAL);
        VehicleLookupService service = new VehicleLookupService(List.of(
                new LocalVinDecoderProvider(),
                new CnairRovinietaProvider(cnair),
                new RarAutoPassProvider(rar)
        ));

        var response = service.lookup(new VehicleLookupRequest("wv1zzz2hzjh012345", " b-123 abc "));

        assertThat(response.vin()).isEqualTo("WV1ZZZ2HZJH012345");
        assertThat(response.licensePlate()).isEqualTo("B123ABC");
        assertThat(response.warnings()).contains(
                "Automatic CNAIR API integration is not configured. Use the official CNAIR check page.",
                "Automatic RAR Auto-Pass API integration is not configured. Use the official RAR Auto-Pass portal."
        );
        assertThat(response.externalLinks()).extracting("type").contains("CNAIR_ROVINIETA", "RAR_AUTOPASS");
    }
}
