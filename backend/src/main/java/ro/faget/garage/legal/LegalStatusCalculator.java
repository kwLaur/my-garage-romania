package ro.faget.garage.legal;

import org.springframework.stereotype.Component;

import java.time.Clock;
import java.time.LocalDate;
import java.time.temporal.ChronoUnit;

import static ro.faget.garage.legal.LegalDtos.*;

@Component
public class LegalStatusCalculator {
    static final int SOON_DAYS = 30;
    private final Clock clock;

    public LegalStatusCalculator() {
        this(Clock.systemDefaultZone());
    }

    LegalStatusCalculator(Clock clock) {
        this.clock = clock;
    }

    public LegalStatusProjection calculate(LocalDate endDate, boolean ignored) {
        if (ignored) {
            return new LegalStatusProjection(null, LegalDocumentStatus.IGNORED);
        }
        if (endDate == null) {
            return new LegalStatusProjection(null, LegalDocumentStatus.UNKNOWN);
        }
        LocalDate today = LocalDate.now(clock);
        int daysRemaining = Math.toIntExact(ChronoUnit.DAYS.between(today, endDate));
        if (endDate.isBefore(today)) {
            return new LegalStatusProjection(daysRemaining, LegalDocumentStatus.EXPIRED);
        }
        if (daysRemaining <= SOON_DAYS) {
            return new LegalStatusProjection(daysRemaining, LegalDocumentStatus.EXPIRING_SOON);
        }
        return new LegalStatusProjection(daysRemaining, LegalDocumentStatus.VALID);
    }
}
