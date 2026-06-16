package ro.faget.garage.vehicle.lookup;

import org.junit.jupiter.api.Test;
import ro.faget.garage.common.BadRequestException;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;

class VehicleLookupNormalizerTest {
    @Test
    void validatesAndNormalizesVin() {
        assertThat(VinNormalizer.normalize(" wv1zzz2hzjh012345 ")).isEqualTo("WV1ZZZ2HZJH012345");
    }

    @Test
    void rejectsInvalidVinLengthAndForbiddenCharacters() {
        assertThatThrownBy(() -> VinNormalizer.normalize("SHORT"))
                .isInstanceOf(BadRequestException.class)
                .hasMessageContaining("17 characters");

        assertThatThrownBy(() -> VinNormalizer.normalize("WAUZZZ8V1Q1234567"))
                .isInstanceOf(BadRequestException.class)
                .hasMessageContaining("I, O, or Q");
    }

    @Test
    void normalizesLicensePlateForLookup() {
        assertThat(LicensePlateNormalizer.normalize(" b 123-abc ")).isEqualTo("B123ABC");
    }
}
