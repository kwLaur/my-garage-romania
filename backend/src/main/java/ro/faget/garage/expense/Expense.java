package ro.faget.garage.expense;

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
import java.util.UUID;

@Entity
@Table(name = "expenses")
public class Expense extends BaseEntity {
    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    @JoinColumn(name = "vehicle_id", nullable = false)
    private Vehicle vehicle;
    private String title;
    private String description;
    private BigDecimal amount;
    private LocalDate date;
    @Enumerated(EnumType.STRING)
    private ExpenseType type;
    @Enumerated(EnumType.STRING)
    private LinkedEntityType linkedEntityType;
    private UUID linkedEntityId;

    public Vehicle getVehicle() { return vehicle; }
    public void setVehicle(Vehicle vehicle) { this.vehicle = vehicle; }
    public String getTitle() { return title; }
    public void setTitle(String title) { this.title = title; }
    public String getDescription() { return description; }
    public void setDescription(String description) { this.description = description; }
    public BigDecimal getAmount() { return amount; }
    public void setAmount(BigDecimal amount) { this.amount = amount; }
    public LocalDate getDate() { return date; }
    public void setDate(LocalDate date) { this.date = date; }
    public ExpenseType getType() { return type; }
    public void setType(ExpenseType type) { this.type = type; }
    public LinkedEntityType getLinkedEntityType() { return linkedEntityType; }
    public void setLinkedEntityType(LinkedEntityType linkedEntityType) { this.linkedEntityType = linkedEntityType; }
    public UUID getLinkedEntityId() { return linkedEntityId; }
    public void setLinkedEntityId(UUID linkedEntityId) { this.linkedEntityId = linkedEntityId; }
}
