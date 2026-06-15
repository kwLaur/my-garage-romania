package ro.faget.garage.notification;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.EnumType;
import jakarta.persistence.Enumerated;
import jakarta.persistence.FetchType;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.ManyToOne;
import jakarta.persistence.Table;
import org.hibernate.annotations.JdbcTypeCode;
import org.hibernate.type.SqlTypes;
import ro.faget.garage.auth.AppUser;
import ro.faget.garage.common.BaseEntity;
import ro.faget.garage.vehicle.Vehicle;

import java.util.ArrayList;
import java.util.List;
import java.util.UUID;

@Entity
@Table(name = "notification_preferences")
public class NotificationPreference extends BaseEntity {
    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    @JoinColumn(name = "user_id", nullable = false)
    private AppUser appUser;

    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    @JoinColumn(name = "vehicle_id", nullable = false)
    private Vehicle vehicle;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false)
    private NotificationEntityType entityType;

    @Column(nullable = false)
    private UUID entityId;

    @Column(nullable = false)
    private boolean enabled = true;

    @JdbcTypeCode(SqlTypes.JSON)
    @Column(nullable = false, columnDefinition = "jsonb")
    private List<Integer> reminderDaysBefore = new ArrayList<>();

    @Column(nullable = false)
    private boolean notifyOnDueDate = true;

    @Column(nullable = false, length = 5)
    private String notificationTime = "09:00";

    public AppUser getAppUser() { return appUser; }
    public void setAppUser(AppUser appUser) { this.appUser = appUser; }
    public Vehicle getVehicle() { return vehicle; }
    public void setVehicle(Vehicle vehicle) { this.vehicle = vehicle; }
    public NotificationEntityType getEntityType() { return entityType; }
    public void setEntityType(NotificationEntityType entityType) { this.entityType = entityType; }
    public UUID getEntityId() { return entityId; }
    public void setEntityId(UUID entityId) { this.entityId = entityId; }
    public boolean isEnabled() { return enabled; }
    public void setEnabled(boolean enabled) { this.enabled = enabled; }
    public List<Integer> getReminderDaysBefore() { return reminderDaysBefore; }
    public void setReminderDaysBefore(List<Integer> reminderDaysBefore) { this.reminderDaysBefore = reminderDaysBefore; }
    public boolean isNotifyOnDueDate() { return notifyOnDueDate; }
    public void setNotifyOnDueDate(boolean notifyOnDueDate) { this.notifyOnDueDate = notifyOnDueDate; }
    public String getNotificationTime() { return notificationTime; }
    public void setNotificationTime(String notificationTime) { this.notificationTime = notificationTime; }
}
