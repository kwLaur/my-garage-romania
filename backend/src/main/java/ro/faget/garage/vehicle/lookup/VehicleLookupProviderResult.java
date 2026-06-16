package ro.faget.garage.vehicle.lookup;

import java.util.ArrayList;
import java.util.List;

import static ro.faget.garage.vehicle.lookup.VehicleLookupDtos.*;

public class VehicleLookupProviderResult {
    private String brand;
    private String model;
    private Integer year;
    private String fuelProfile;
    private CnairRovinietaStatus rovinieta;
    private CnairRovinietaStatus itp;
    private RarAutoPassStatus rarAutoPass;
    private final List<String> warnings = new ArrayList<>();
    private final List<ExternalLink> externalLinks = new ArrayList<>();

    public String brand() {
        return brand;
    }

    public void brand(String brand) {
        this.brand = brand;
    }

    public String model() {
        return model;
    }

    public void model(String model) {
        this.model = model;
    }

    public Integer year() {
        return year;
    }

    public void year(Integer year) {
        this.year = year;
    }

    public String fuelProfile() {
        return fuelProfile;
    }

    public void fuelProfile(String fuelProfile) {
        this.fuelProfile = fuelProfile;
    }

    public CnairRovinietaStatus rovinieta() {
        return rovinieta;
    }

    public void rovinieta(CnairRovinietaStatus rovinieta) {
        this.rovinieta = rovinieta;
    }

    public CnairRovinietaStatus itp() {
        return itp;
    }

    public void itp(CnairRovinietaStatus itp) {
        this.itp = itp;
    }

    public RarAutoPassStatus rarAutoPass() {
        return rarAutoPass;
    }

    public void rarAutoPass(RarAutoPassStatus rarAutoPass) {
        this.rarAutoPass = rarAutoPass;
    }

    public List<String> warnings() {
        return warnings;
    }

    public List<ExternalLink> externalLinks() {
        return externalLinks;
    }
}
