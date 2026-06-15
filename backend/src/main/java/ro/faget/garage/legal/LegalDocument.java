package ro.faget.garage.legal;

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
@Table(name = "legal_documents")
public class LegalDocument extends BaseEntity {
    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    @JoinColumn(name = "vehicle_id", nullable = false)
    private Vehicle vehicle;
    @Enumerated(EnumType.STRING)
    private LegalDocumentType type;
    private LocalDate startDate;
    private LocalDate endDate;
    private String provider;
    private String policyNumber;
    private String documentUrl;
    private BigDecimal cost;
    @Enumerated(EnumType.STRING)
    private LegalDocumentSource source = LegalDocumentSource.MANUAL;
    private boolean ignored;
    private String notes;

    public Vehicle getVehicle() { return vehicle; }
    public void setVehicle(Vehicle vehicle) { this.vehicle = vehicle; }
    public LegalDocumentType getType() { return type; }
    public void setType(LegalDocumentType type) { this.type = type; }
    public LocalDate getStartDate() { return startDate; }
    public void setStartDate(LocalDate startDate) { this.startDate = startDate; }
    public LocalDate getEndDate() { return endDate; }
    public void setEndDate(LocalDate endDate) { this.endDate = endDate; }
    public String getProvider() { return provider; }
    public void setProvider(String provider) { this.provider = provider; }
    public String getPolicyNumber() { return policyNumber; }
    public void setPolicyNumber(String policyNumber) { this.policyNumber = policyNumber; }
    public String getDocumentUrl() { return documentUrl; }
    public void setDocumentUrl(String documentUrl) { this.documentUrl = documentUrl; }
    public BigDecimal getCost() { return cost; }
    public void setCost(BigDecimal cost) { this.cost = cost; }
    public LegalDocumentSource getSource() { return source; }
    public void setSource(LegalDocumentSource source) { this.source = source; }
    public boolean isIgnored() { return ignored; }
    public void setIgnored(boolean ignored) { this.ignored = ignored; }
    public String getNotes() { return notes; }
    public void setNotes(String notes) { this.notes = notes; }
}
