package ro.faget.garage.notification;

import org.junit.jupiter.api.Test;
import ro.faget.garage.common.BadRequestException;

import java.util.List;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;

class NotificationPreferenceValidatorTest {
    @Test
    void normalizesReminderDaysDescending() {
        assertThat(NotificationPreferenceValidator.normalizeReminderDays(List.of(1, 30, 7, 14)))
                .containsExactly(30, 14, 7, 1);
    }

    @Test
    void rejectsDuplicateReminderDays() {
        assertThatThrownBy(() -> NotificationPreferenceValidator.normalizeReminderDays(List.of(30, 7, 7)))
                .isInstanceOf(BadRequestException.class)
                .hasMessageContaining("duplicates");
    }

    @Test
    void rejectsOutOfRangeReminderDays() {
        assertThatThrownBy(() -> NotificationPreferenceValidator.normalizeReminderDays(List.of(366)))
                .isInstanceOf(BadRequestException.class)
                .hasMessageContaining("between 0 and 365");
    }

    @Test
    void normalizesNotificationTimeDefaultAndFormat() {
        assertThat(NotificationPreferenceValidator.normalizeNotificationTime(null)).isEqualTo("09:00");
        assertThat(NotificationPreferenceValidator.normalizeNotificationTime(" 08:30 ")).isEqualTo("08:30");
    }

    @Test
    void rejectsInvalidNotificationTime() {
        assertThatThrownBy(() -> NotificationPreferenceValidator.normalizeNotificationTime("9:00"))
                .isInstanceOf(BadRequestException.class)
                .hasMessageContaining("HH:mm");
        assertThatThrownBy(() -> NotificationPreferenceValidator.normalizeNotificationTime("24:00"))
                .isInstanceOf(BadRequestException.class)
                .hasMessageContaining("HH:mm");
    }
}
