package ro.faget.garage.vehicle;

import ro.faget.garage.common.BaseEntity;
import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.Table;

@Entity
@Table(name = "vehicles")
public class Vehicle extends BaseEntity {
    @Column(nullable = false)
    private String name;
    @Column(nullable = false)
    private String licensePlate;
    private String vin;
    private String brand;
    private String model;
    private Integer year;
    @Column(nullable = false)
    private Integer currentKm;
    private String fuelProfile;
    private String imageUrl;
    @Column(nullable = false)
    private boolean active = true;

    public String getName() { return name; }
    public void setName(String name) { this.name = name; }
    public String getLicensePlate() { return licensePlate; }
    public void setLicensePlate(String licensePlate) { this.licensePlate = licensePlate; }
    public String getVin() { return vin; }
    public void setVin(String vin) { this.vin = vin; }
    public String getBrand() { return brand; }
    public void setBrand(String brand) { this.brand = brand; }
    public String getModel() { return model; }
    public void setModel(String model) { this.model = model; }
    public Integer getYear() { return year; }
    public void setYear(Integer year) { this.year = year; }
    public Integer getCurrentKm() { return currentKm; }
    public void setCurrentKm(Integer currentKm) { this.currentKm = currentKm; }
    public String getFuelProfile() { return fuelProfile; }
    public void setFuelProfile(String fuelProfile) { this.fuelProfile = fuelProfile; }
    public String getImageUrl() { return imageUrl; }
    public void setImageUrl(String imageUrl) { this.imageUrl = imageUrl; }
    public boolean isActive() { return active; }
    public void setActive(boolean active) { this.active = active; }
}
