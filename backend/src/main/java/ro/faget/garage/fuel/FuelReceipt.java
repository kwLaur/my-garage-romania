package ro.faget.garage.fuel;

import ro.faget.garage.common.BaseEntity;
import ro.faget.garage.vehicle.Vehicle;
import jakarta.persistence.Column;
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
@Table(name = "fuel_receipts")
public class FuelReceipt extends BaseEntity {
    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    @JoinColumn(name = "vehicle_id", nullable = false)
    private Vehicle vehicle;
    private LocalDate receiptDate;
    private String stationName;
    @Enumerated(EnumType.STRING)
    private FuelType fuelType;
    private BigDecimal quantityLiters;
    private BigDecimal unitPrice;
    private BigDecimal totalAmount;
    private Integer odometerKm;
    private boolean fullTank;
    @Enumerated(EnumType.STRING)
    private FuelReceiptSource source = FuelReceiptSource.MANUAL;
    private BigDecimal confidenceScore;
    private String receiptImageUrl;
    @Column(columnDefinition = "text")
    private String rawOcrText;
    private String notes;

    public Vehicle getVehicle() { return vehicle; }
    public void setVehicle(Vehicle vehicle) { this.vehicle = vehicle; }
    public LocalDate getReceiptDate() { return receiptDate; }
    public void setReceiptDate(LocalDate receiptDate) { this.receiptDate = receiptDate; }
    public String getStationName() { return stationName; }
    public void setStationName(String stationName) { this.stationName = stationName; }
    public FuelType getFuelType() { return fuelType; }
    public void setFuelType(FuelType fuelType) { this.fuelType = fuelType; }
    public BigDecimal getQuantityLiters() { return quantityLiters; }
    public void setQuantityLiters(BigDecimal quantityLiters) { this.quantityLiters = quantityLiters; }
    public BigDecimal getUnitPrice() { return unitPrice; }
    public void setUnitPrice(BigDecimal unitPrice) { this.unitPrice = unitPrice; }
    public BigDecimal getTotalAmount() { return totalAmount; }
    public void setTotalAmount(BigDecimal totalAmount) { this.totalAmount = totalAmount; }
    public Integer getOdometerKm() { return odometerKm; }
    public void setOdometerKm(Integer odometerKm) { this.odometerKm = odometerKm; }
    public boolean isFullTank() { return fullTank; }
    public void setFullTank(boolean fullTank) { this.fullTank = fullTank; }
    public FuelReceiptSource getSource() { return source; }
    public void setSource(FuelReceiptSource source) { this.source = source; }
    public BigDecimal getConfidenceScore() { return confidenceScore; }
    public void setConfidenceScore(BigDecimal confidenceScore) { this.confidenceScore = confidenceScore; }
    public String getReceiptImageUrl() { return receiptImageUrl; }
    public void setReceiptImageUrl(String receiptImageUrl) { this.receiptImageUrl = receiptImageUrl; }
    public String getRawOcrText() { return rawOcrText; }
    public void setRawOcrText(String rawOcrText) { this.rawOcrText = rawOcrText; }
    public String getNotes() { return notes; }
    public void setNotes(String notes) { this.notes = notes; }
}
