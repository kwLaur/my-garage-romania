package ro.faget.garage.expense;

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

import static ro.faget.garage.expense.ExpenseDtos.*;

@RestController
@RequestMapping("/api")
public class ExpenseController {
    private final ExpenseService expenseService;

    public ExpenseController(ExpenseService expenseService) {
        this.expenseService = expenseService;
    }

    @GetMapping("/vehicles/{vehicleId}/expenses")
    List<ExpenseResponse> list(@PathVariable UUID vehicleId) { return expenseService.list(vehicleId); }

    @PostMapping("/vehicles/{vehicleId}/expenses")
    ExpenseResponse create(@PathVariable UUID vehicleId, @Valid @RequestBody ExpenseRequest request) { return expenseService.create(vehicleId, request); }

    @PutMapping("/expenses/{id}")
    ExpenseResponse update(@PathVariable UUID id, @Valid @RequestBody ExpenseRequest request) { return expenseService.update(id, request); }

    @DeleteMapping("/expenses/{id}")
    void delete(@PathVariable UUID id) { expenseService.delete(id); }
}
