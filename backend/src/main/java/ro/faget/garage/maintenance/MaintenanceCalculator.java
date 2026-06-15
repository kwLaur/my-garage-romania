package ro.faget.garage.maintenance;

import org.springframework.stereotype.Component;

import java.time.Clock;
import java.time.LocalDate;
import java.time.temporal.ChronoUnit;

import static ro.faget.garage.maintenance.MaintenanceDtos.*;

@Component
public class MaintenanceCalculator {
    static final int SOON_KM = 1000;
    static final int SOON_DAYS = 30;
    private final Clock clock;

    public MaintenanceCalculator() {
        this(Clock.systemDefaultZone());
    }

    MaintenanceCalculator(Clock clock) {
        this.clock = clock;
    }

    public MaintenanceProjection calculate(Integer currentKm, Integer lastKm, LocalDate lastDate, Integer intervalKm, Integer intervalDays) {
        Integer nextDueKm = null;
        Integer kmRemaining = null;
        LocalDate nextDueDate = null;
        Integer daysRemaining = null;
        LocalDate today = LocalDate.now(clock);

        if (lastKm != null && intervalKm != null && intervalKm > 0 && currentKm != null) {
            nextDueKm = lastKm + intervalKm;
            kmRemaining = nextDueKm - currentKm;
        }
        if (lastDate != null && intervalDays != null && intervalDays > 0) {
            nextDueDate = lastDate.plusDays(intervalDays);
            daysRemaining = Math.toIntExact(ChronoUnit.DAYS.between(today, nextDueDate));
        }
        if (kmRemaining == null && daysRemaining == null) {
            return new MaintenanceProjection(null, null, nextDueKm, nextDueDate, MaintenanceStatus.UNKNOWN);
        }
        if ((kmRemaining != null && kmRemaining <= 0) || (daysRemaining != null && daysRemaining <= 0)) {
            return new MaintenanceProjection(kmRemaining, daysRemaining, nextDueKm, nextDueDate, MaintenanceStatus.OVERDUE);
        }
        if ((kmRemaining != null && kmRemaining <= SOON_KM) || (daysRemaining != null && daysRemaining <= SOON_DAYS)) {
            return new MaintenanceProjection(kmRemaining, daysRemaining, nextDueKm, nextDueDate, MaintenanceStatus.SOON);
        }
        return new MaintenanceProjection(kmRemaining, daysRemaining, nextDueKm, nextDueDate, MaintenanceStatus.OK);
    }
}
