package ro.faget.garage.health;

import org.junit.jupiter.api.Test;

import static org.assertj.core.api.Assertions.assertThat;

class HealthControllerTest {
    @Test
    void healthReturnsStaticPublicStatus() {
        var response = new HealthController().health();

        assertThat(response.status()).isEqualTo("UP");
        assertThat(response.app()).isEqualTo("my-garage-romania");
    }
}
