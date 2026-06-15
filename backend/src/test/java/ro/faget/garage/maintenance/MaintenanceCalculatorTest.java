package ro.faget.garage.maintenance;

import org.junit.jupiter.api.Test;

import java.time.Clock;
import java.time.Instant;
import java.time.LocalDate;
import java.time.ZoneOffset;

import static org.assertj.core.api.Assertions.assertThat;

class MaintenanceCalculatorTest {
    private final MaintenanceCalculator calculator = new MaintenanceCalculator(Clock.fixed(Instant.parse("2026-06-15T00:00:00Z"), ZoneOffset.UTC));

    @Test
    void marksUnknownWhenNoUsableIntervalExists() {
        assertThat(calculator.calculate(10_000, null, null, null, null).status()).isEqualTo(MaintenanceStatus.UNKNOWN);
    }

    @Test
    void marksOverdueByKmOrDate() {
        assertThat(calculator.calculate(22_000, 10_000, LocalDate.parse("2025-06-01"), 12_000, 365).status()).isEqualTo(MaintenanceStatus.OVERDUE);
    }

    @Test
    void marksSoonByThresholds() {
        var result = calculator.calculate(21_100, 10_000, LocalDate.parse("2025-07-15"), 12_000, 365);
        assertThat(result.status()).isEqualTo(MaintenanceStatus.SOON);
        assertThat(result.kmRemaining()).isEqualTo(900);
    }
}
