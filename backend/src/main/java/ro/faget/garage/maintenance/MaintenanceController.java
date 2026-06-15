package ro.faget.garage.maintenance;

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

import static ro.faget.garage.maintenance.MaintenanceDtos.*;

@RestController
@RequestMapping("/api")
public class MaintenanceController {
    private final MaintenanceService maintenanceService;

    public MaintenanceController(MaintenanceService maintenanceService) {
        this.maintenanceService = maintenanceService;
    }

    @GetMapping("/vehicles/{vehicleId}/maintenance")
    List<MaintenanceResponse> list(@PathVariable UUID vehicleId) { return maintenanceService.list(vehicleId); }

    @PostMapping("/vehicles/{vehicleId}/maintenance")
    MaintenanceResponse create(@PathVariable UUID vehicleId, @Valid @RequestBody MaintenanceRequest request) { return maintenanceService.create(vehicleId, request); }

    @PutMapping("/maintenance/{id}")
    MaintenanceResponse update(@PathVariable UUID id, @Valid @RequestBody MaintenanceRequest request) { return maintenanceService.update(id, request); }

    @DeleteMapping("/maintenance/{id}")
    void delete(@PathVariable UUID id) { maintenanceService.delete(id); }
}
