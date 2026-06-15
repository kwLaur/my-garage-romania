package ro.faget.garage.maintenance;

import ro.faget.garage.common.BaseEntity;
import ro.faget.garage.vehicle.Vehicle;
import jakarta.persistence.Entity;
import jakarta.persistence.EnumType;
import jakarta.persistence.Enumerated;
import jakarta.persistence.FetchType;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.ManyToOne;
import jakarta.persistence.Table;

import java.math.BigDecimal;
import java.time.LocalDate;

@Entity
@Table(name = "maintenance_items")
public class MaintenanceItem extends BaseEntity {
    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    @JoinColumn(name = "vehicle_id", nullable = false)
    private Vehicle vehicle;
    @Enumerated(EnumType.STRING)
    private MaintenanceType type;
    private Integer lastKm;
    private LocalDate lastDate;
    private Integer intervalKm;
    private Integer intervalDays;
    private BigDecimal cost;
    private String notes;

    public Vehicle getVehicle() { return vehicle; }
    public void setVehicle(Vehicle vehicle) { this.vehicle = vehicle; }
    public MaintenanceType getType() { return type; }
    public void setType(MaintenanceType type) { this.type = type; }
    public Integer getLastKm() { return lastKm; }
    public void setLastKm(Integer lastKm) { this.lastKm = lastKm; }
    public LocalDate getLastDate() { return lastDate; }
    public void setLastDate(LocalDate lastDate) { this.lastDate = lastDate; }
    public Integer getIntervalKm() { return intervalKm; }
    public void setIntervalKm(Integer intervalKm) { this.intervalKm = intervalKm; }
    public Integer getIntervalDays() { return intervalDays; }
    public void setIntervalDays(Integer intervalDays) { this.intervalDays = intervalDays; }
    public BigDecimal getCost() { return cost; }
    public void setCost(BigDecimal cost) { this.cost = cost; }
    public String getNotes() { return notes; }
    public void setNotes(String notes) { this.notes = notes; }
}
