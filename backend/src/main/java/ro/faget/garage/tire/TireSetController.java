package ro.faget.garage.tire;

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

import static ro.faget.garage.tire.TireDtos.*;

@RestController
@RequestMapping("/api")
public class TireSetController {
    private final TireSetService tireSetService;

    public TireSetController(TireSetService tireSetService) {
        this.tireSetService = tireSetService;
    }

    @GetMapping("/vehicles/{vehicleId}/tire-sets")
    List<TireSetResponse> list(@PathVariable UUID vehicleId) { return tireSetService.list(vehicleId); }

    @PostMapping("/vehicles/{vehicleId}/tire-sets")
    TireSetResponse create(@PathVariable UUID vehicleId, @Valid @RequestBody TireSetRequest request) { return tireSetService.create(vehicleId, request); }

    @PutMapping("/tire-sets/{id}")
    TireSetResponse update(@PathVariable UUID id, @Valid @RequestBody TireSetRequest request) { return tireSetService.update(id, request); }

    @DeleteMapping("/tire-sets/{id}")
    void delete(@PathVariable UUID id) { tireSetService.delete(id); }
}
