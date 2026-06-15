package ro.faget.garage.tire;

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
@Table(name = "tire_sets")
public class TireSet extends BaseEntity {
    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    @JoinColumn(name = "vehicle_id", nullable = false)
    private Vehicle vehicle;
    @Enumerated(EnumType.STRING)
    private TireType tireType;
    @Enumerated(EnumType.STRING)
    private TireMountType mountType;
    private String brandModel;
    private String size;
    private String dot;
    private LocalDate purchaseDate;
    private Integer totalKm;
    private BigDecimal cost;
    private boolean installed;
    private String storageLocation;
    private BigDecimal pressureFront;
    private BigDecimal pressureRear;
    private String notes;

    public Vehicle getVehicle() { return vehicle; }
    public void setVehicle(Vehicle vehicle) { this.vehicle = vehicle; }
    public TireType getTireType() { return tireType; }
    public void setTireType(TireType tireType) { this.tireType = tireType; }
    public TireMountType getMountType() { return mountType; }
    public void setMountType(TireMountType mountType) { this.mountType = mountType; }
    public String getBrandModel() { return brandModel; }
    public void setBrandModel(String brandModel) { this.brandModel = brandModel; }
    public String getSize() { return size; }
    public void setSize(String size) { this.size = size; }
    public String getDot() { return dot; }
    public void setDot(String dot) { this.dot = dot; }
    public LocalDate getPurchaseDate() { return purchaseDate; }
    public void setPurchaseDate(LocalDate purchaseDate) { this.purchaseDate = purchaseDate; }
    public Integer getTotalKm() { return totalKm; }
    public void setTotalKm(Integer totalKm) { this.totalKm = totalKm; }
    public BigDecimal getCost() { return cost; }
    public void setCost(BigDecimal cost) { this.cost = cost; }
    public boolean isInstalled() { return installed; }
    public void setInstalled(boolean installed) { this.installed = installed; }
    public String getStorageLocation() { return storageLocation; }
    public void setStorageLocation(String storageLocation) { this.storageLocation = storageLocation; }
    public BigDecimal getPressureFront() { return pressureFront; }
    public void setPressureFront(BigDecimal pressureFront) { this.pressureFront = pressureFront; }
    public BigDecimal getPressureRear() { return pressureRear; }
    public void setPressureRear(BigDecimal pressureRear) { this.pressureRear = pressureRear; }
    public String getNotes() { return notes; }
    public void setNotes(String notes) { this.notes = notes; }
}
