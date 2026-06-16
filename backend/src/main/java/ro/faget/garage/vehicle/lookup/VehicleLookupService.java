package ro.faget.garage.vehicle.lookup;

import org.springframework.stereotype.Service;
import ro.faget.garage.common.BadRequestException;

import java.util.ArrayList;
import java.util.List;

import static ro.faget.garage.vehicle.lookup.VehicleLookupDtos.*;

@Service
public class VehicleLookupService {
    private final List<VehicleLookupProvider> providers;

    public VehicleLookupService(List<VehicleLookupProvider> providers) {
        this.providers = providers;
    }

    public VehicleLookupResponse lookup(VehicleLookupRequest request) {
        String vin = VinNormalizer.normalize(request.vin());
        String licensePlate = LicensePlateNormalizer.normalize(request.licensePlate());
        if (vin == null && licensePlate == null) {
            throw new BadRequestException("VIN or license plate is required");
        }

        VehicleLookupInput input = new VehicleLookupInput(vin, licensePlate);
        String brand = null;
        String model = null;
        Integer year = null;
        String fuelProfile = null;
        CnairRovinietaStatus rovinieta = null;
        CnairRovinietaStatus itp = null;
        RarAutoPassStatus rarAutoPass = null;
        List<String> warnings = new ArrayList<>();
        List<ExternalLink> externalLinks = new ArrayList<>();

        for (VehicleLookupProvider provider : providers) {
            VehicleLookupProviderResult result = provider.lookup(input);
            brand = firstNonBlank(brand, result.brand());
            model = firstNonBlank(model, result.model());
            year = year != null ? year : result.year();
            fuelProfile = firstNonBlank(fuelProfile, result.fuelProfile());
            rovinieta = rovinieta != null ? rovinieta : result.rovinieta();
            itp = itp != null ? itp : result.itp();
            rarAutoPass = rarAutoPass != null ? rarAutoPass : result.rarAutoPass();
            warnings.addAll(result.warnings());
            addUniqueLinks(externalLinks, result.externalLinks());
        }

        if (warnings.isEmpty() && brand == null && model == null && year == null && fuelProfile == null) {
            warnings.add("No external provider configured yet");
        }

        return new VehicleLookupResponse(
                vin,
                licensePlate,
                brand,
                model,
                year,
                fuelProfile,
                rovinieta,
                itp,
                rarAutoPass,
                List.copyOf(warnings),
                List.copyOf(externalLinks)
        );
    }

    private String firstNonBlank(String current, String candidate) {
        if (current != null && !current.isBlank()) {
            return current;
        }
        return candidate == null || candidate.isBlank() ? null : candidate;
    }

    private void addUniqueLinks(List<ExternalLink> target, List<ExternalLink> links) {
        for (ExternalLink link : links) {
            boolean alreadyPresent = target.stream().anyMatch(existing -> existing.type().equals(link.type()));
            if (!alreadyPresent) {
                target.add(link);
            }
        }
    }
}
