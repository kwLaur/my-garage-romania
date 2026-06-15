package ro.faget.garage.equipment;

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

import static ro.faget.garage.equipment.EquipmentDtos.*;

@RestController
@RequestMapping("/api")
public class EquipmentController {
    private final EquipmentService equipmentService;

    public EquipmentController(EquipmentService equipmentService) {
        this.equipmentService = equipmentService;
    }

    @GetMapping("/vehicles/{vehicleId}/equipment")
    List<EquipmentResponse> list(@PathVariable UUID vehicleId) { return equipmentService.list(vehicleId); }

    @PostMapping("/vehicles/{vehicleId}/equipment")
    EquipmentResponse create(@PathVariable UUID vehicleId, @Valid @RequestBody EquipmentRequest request) { return equipmentService.create(vehicleId, request); }

    @PutMapping("/equipment/{id}")
    EquipmentResponse update(@PathVariable UUID id, @Valid @RequestBody EquipmentRequest request) { return equipmentService.update(id, request); }

    @DeleteMapping("/equipment/{id}")
    void delete(@PathVariable UUID id) { equipmentService.delete(id); }
}
