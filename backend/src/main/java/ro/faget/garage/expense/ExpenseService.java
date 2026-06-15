package ro.faget.garage.expense;

import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import ro.faget.garage.common.NotFoundException;
import ro.faget.garage.vehicle.Vehicle;
import ro.faget.garage.vehicle.VehicleService;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.util.List;
import java.util.UUID;

import static ro.faget.garage.expense.ExpenseDtos.*;

@Service
public class ExpenseService {
    private final ExpenseRepository expenses;
    private final VehicleService vehicles;

    public ExpenseService(ExpenseRepository expenses, VehicleService vehicles) {
        this.expenses = expenses;
        this.vehicles = vehicles;
    }

    @Transactional(readOnly = true)
    public List<ExpenseResponse> list(UUID vehicleId) {
        vehicles.getEntity(vehicleId);
        return expenses.findByVehicleIdOrderByDateDesc(vehicleId).stream().map(this::toResponse).toList();
    }

    @Transactional
    public ExpenseResponse create(UUID vehicleId, ExpenseRequest request) {
        Expense expense = new Expense();
        expense.setVehicle(vehicles.getEntity(vehicleId));
        apply(expense, request);
        return toResponse(expenses.save(expense));
    }

    @Transactional
    public ExpenseResponse update(UUID id, ExpenseRequest request) {
        Expense expense = expenses.findById(id).orElseThrow(() -> new NotFoundException("Expense not found"));
        apply(expense, request);
        return toResponse(expense);
    }

    @Transactional
    public void delete(UUID id) {
        expenses.delete(expenses.findById(id).orElseThrow(() -> new NotFoundException("Expense not found")));
    }

    @Transactional
    public void upsertLinked(Vehicle vehicle, LinkedEntityType linkedType, UUID linkedId, String title,
                             String description, BigDecimal amount, LocalDate date, ExpenseType type) {
        if (amount == null) {
            expenses.deleteByLinkedEntityTypeAndLinkedEntityId(linkedType, linkedId);
            return;
        }
        Expense expense = expenses.findByLinkedEntityTypeAndLinkedEntityId(linkedType, linkedId).orElseGet(Expense::new);
        expense.setVehicle(vehicle);
        expense.setLinkedEntityType(linkedType);
        expense.setLinkedEntityId(linkedId);
        expense.setTitle(title);
        expense.setDescription(description);
        expense.setAmount(amount);
        expense.setDate(date);
        expense.setType(type);
        expenses.save(expense);
    }

    @Transactional
    public void deleteLinked(LinkedEntityType linkedType, UUID linkedId) {
        expenses.deleteByLinkedEntityTypeAndLinkedEntityId(linkedType, linkedId);
    }

    private void apply(Expense expense, ExpenseRequest request) {
        expense.setTitle(request.title());
        expense.setDescription(request.description());
        expense.setAmount(request.amount());
        expense.setDate(request.date());
        expense.setType(request.type());
        expense.setLinkedEntityType(request.linkedEntityType());
        expense.setLinkedEntityId(request.linkedEntityId());
    }

    private ExpenseResponse toResponse(Expense expense) {
        return new ExpenseResponse(expense.getId(), expense.getVehicle().getId(), expense.getTitle(), expense.getDescription(),
                expense.getAmount(), expense.getDate(), expense.getType(), expense.getLinkedEntityType(), expense.getLinkedEntityId(),
                expense.getCreatedAt(), expense.getUpdatedAt());
    }
}
