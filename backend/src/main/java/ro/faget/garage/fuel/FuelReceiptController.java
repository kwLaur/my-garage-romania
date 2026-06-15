package ro.faget.garage.fuel;

import jakarta.validation.Valid;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestPart;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.multipart.MultipartFile;

import java.util.List;
import java.util.UUID;

import static ro.faget.garage.fuel.FuelDtos.*;

@RestController
@RequestMapping("/api")
public class FuelReceiptController {
    private final FuelReceiptService fuelReceiptService;

    public FuelReceiptController(FuelReceiptService fuelReceiptService) {
        this.fuelReceiptService = fuelReceiptService;
    }

    @GetMapping("/vehicles/{vehicleId}/fuel-receipts")
    List<FuelReceiptResponse> list(@PathVariable UUID vehicleId) { return fuelReceiptService.list(vehicleId); }

    @PostMapping("/vehicles/{vehicleId}/fuel-receipts")
    FuelReceiptResponse create(@PathVariable UUID vehicleId, @Valid @RequestBody FuelReceiptRequest request) { return fuelReceiptService.create(vehicleId, request); }

    @PostMapping(value = "/vehicles/{vehicleId}/fuel-receipts/with-image", consumes = "multipart/form-data")
    FuelReceiptResponse createWithImage(@PathVariable UUID vehicleId, @Valid @RequestPart("metadata") FuelReceiptRequest request,
                                        @RequestPart("image") MultipartFile image) {
        return fuelReceiptService.createWithImage(vehicleId, request, image);
    }

    @PutMapping("/fuel-receipts/{id}")
    FuelReceiptResponse update(@PathVariable UUID id, @Valid @RequestBody FuelReceiptRequest request) { return fuelReceiptService.update(id, request); }

    @DeleteMapping("/fuel-receipts/{id}")
    void delete(@PathVariable UUID id) { fuelReceiptService.delete(id); }
}
