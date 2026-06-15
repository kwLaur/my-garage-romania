package ro.faget.garage.notification;

import ro.faget.garage.common.BadRequestException;

import java.util.ArrayList;
import java.util.Comparator;
import java.util.HashSet;
import java.util.List;
import java.util.Set;

final class NotificationPreferenceValidator {
    private NotificationPreferenceValidator() {
    }

    static List<Integer> normalizeReminderDays(List<Integer> reminderDaysBefore) {
        if (reminderDaysBefore == null) {
            return List.of();
        }

        Set<Integer> seen = new HashSet<>();
        List<Integer> normalized = new ArrayList<>();
        for (Integer value : reminderDaysBefore) {
            if (value == null || value < 0 || value > 365) {
                throw new BadRequestException("reminderDaysBefore values must be between 0 and 365");
            }
            if (!seen.add(value)) {
                throw new BadRequestException("reminderDaysBefore must not contain duplicates");
            }
            normalized.add(value);
        }
        normalized.sort(Comparator.reverseOrder());
        return List.copyOf(normalized);
    }

    static String normalizeNotificationTime(String notificationTime) {
        String value = notificationTime == null || notificationTime.isBlank() ? "09:00" : notificationTime.trim();
        if (!value.matches("\\d{2}:\\d{2}")) {
            throw new BadRequestException("notificationTime must use HH:mm format");
        }
        int hour = Integer.parseInt(value.substring(0, 2));
        int minute = Integer.parseInt(value.substring(3, 5));
        if (hour > 23 || minute > 59) {
            throw new BadRequestException("notificationTime must use HH:mm format");
        }
        return value;
    }
}
