package ro.faget.garage.legal;

import org.junit.jupiter.api.Test;

import java.time.Clock;
import java.time.Instant;
import java.time.LocalDate;
import java.time.ZoneOffset;

import static org.assertj.core.api.Assertions.assertThat;

class LegalStatusCalculatorTest {
    private final LegalStatusCalculator calculator = new LegalStatusCalculator(Clock.fixed(Instant.parse("2026-06-15T00:00:00Z"), ZoneOffset.UTC));

    @Test
    void ignoredOverridesDate() {
        assertThat(calculator.calculate(LocalDate.parse("2020-01-01"), true).status()).isEqualTo(LegalDocumentStatus.IGNORED);
    }

    @Test
    void handlesExpiryRules() {
        assertThat(calculator.calculate(LocalDate.parse("2026-06-14"), false).status()).isEqualTo(LegalDocumentStatus.EXPIRED);
        assertThat(calculator.calculate(LocalDate.parse("2026-07-01"), false).status()).isEqualTo(LegalDocumentStatus.EXPIRING_SOON);
        assertThat(calculator.calculate(LocalDate.parse("2026-09-01"), false).status()).isEqualTo(LegalDocumentStatus.VALID);
    }
}
