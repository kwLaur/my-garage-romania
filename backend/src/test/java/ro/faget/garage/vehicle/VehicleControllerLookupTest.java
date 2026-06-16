package ro.faget.garage.vehicle;

import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.AutoConfigureMockMvc;
import org.springframework.boot.test.autoconfigure.web.servlet.WebMvcTest;
import org.springframework.boot.test.mock.mockito.MockBean;
import org.springframework.http.MediaType;
import org.springframework.test.web.servlet.MockMvc;
import ro.faget.garage.auth.AppUserRepository;
import ro.faget.garage.auth.JwtService;
import ro.faget.garage.vehicle.lookup.VehicleLookupService;

import java.util.List;

import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.when;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;
import static ro.faget.garage.vehicle.lookup.VehicleLookupDtos.*;

@WebMvcTest(VehicleController.class)
@AutoConfigureMockMvc(addFilters = false)
class VehicleControllerLookupTest {
    @Autowired
    private MockMvc mockMvc;

    @MockBean
    private VehicleService vehicleService;

    @MockBean
    private VehicleLookupService vehicleLookupService;

    @MockBean
    private JwtService jwtService;

    @MockBean
    private AppUserRepository appUserRepository;

    @Test
    void lookupEndpointReturnsProviderWarningsAndLinks() throws Exception {
        when(vehicleLookupService.lookup(any())).thenReturn(new VehicleLookupResponse(
                "WV1ZZZ2HZJH012345",
                "B123ABC",
                null,
                null,
                null,
                null,
                null,
                null,
                null,
                List.of("No external provider configured yet"),
                List.of(new ExternalLink("CNAIR_ROVINIETA", "Official CNAIR rovinietă check", "https://www.cnadnr.ro/ro/verificare-rovinieta"))
        ));

        mockMvc.perform(post("/api/vehicles/lookup")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content("""
                                {
                                  "vin": "WV1ZZZ2HZJH012345",
                                  "licensePlate": "B 123 ABC"
                                }
                                """))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.vin").value("WV1ZZZ2HZJH012345"))
                .andExpect(jsonPath("$.licensePlate").value("B123ABC"))
                .andExpect(jsonPath("$.warnings[0]").value("No external provider configured yet"))
                .andExpect(jsonPath("$.externalLinks[0].type").value("CNAIR_ROVINIETA"));
    }
}
