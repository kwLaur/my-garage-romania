package ro.faget.garage.vehicle;

import jakarta.validation.Valid;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;
import java.util.UUID;

import static ro.faget.garage.vehicle.VehicleDtos.*;

@RestController
@RequestMapping("/api/vehicles")
public class VehicleController {
    private final VehicleService vehicleService;

    public VehicleController(VehicleService vehicleService) {
        this.vehicleService = vehicleService;
    }

    @GetMapping
    List<VehicleResponse> list() { return vehicleService.list(); }

    @PostMapping
    VehicleResponse create(@Valid @RequestBody VehicleRequest request) { return vehicleService.create(request); }

    @GetMapping("/{id}")
    VehicleResponse get(@PathVariable UUID id) { return vehicleService.get(id); }

    @PutMapping("/{id}")
    VehicleResponse update(@PathVariable UUID id, @Valid @RequestBody VehicleRequest request) { return vehicleService.update(id, request); }

    @DeleteMapping("/{id}")
    void delete(@PathVariable UUID id) { vehicleService.delete(id); }

    @PutMapping("/{id}/odometer")
    VehicleResponse odometer(@PathVariable UUID id, @Valid @RequestBody OdometerRequest request) { return vehicleService.updateOdometer(id, request); }
}
