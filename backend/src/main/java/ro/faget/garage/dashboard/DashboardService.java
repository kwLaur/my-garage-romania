package ro.faget.garage.dashboard;

import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import ro.faget.garage.equipment.EquipmentItem;
import ro.faget.garage.equipment.EquipmentRepository;
import ro.faget.garage.expense.ExpenseRepository;
import ro.faget.garage.fuel.FuelReceiptRepository;
import ro.faget.garage.fuel.FuelReceiptService;
import ro.faget.garage.legal.LegalDocument;
import ro.faget.garage.legal.LegalDocumentRepository;
import ro.faget.garage.legal.LegalDocumentService;
import ro.faget.garage.legal.LegalDocumentStatus;
import ro.faget.garage.maintenance.MaintenanceItem;
import ro.faget.garage.maintenance.MaintenanceRepository;
import ro.faget.garage.maintenance.MaintenanceService;
import ro.faget.garage.maintenance.MaintenanceStatus;
import ro.faget.garage.vehicle.VehicleRepository;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.time.YearMonth;
import java.time.temporal.ChronoUnit;
import java.util.ArrayList;
import java.util.List;

import static ro.faget.garage.dashboard.DashboardDtos.*;

@Service
public class DashboardService {
    private final VehicleRepository vehicles;
    private final ExpenseRepository expenses;
    private final FuelReceiptRepository fuelReceipts;
    private final FuelReceiptService fuelReceiptService;
    private final MaintenanceRepository maintenance;
    private final MaintenanceService maintenanceService;
    private final LegalDocumentRepository legalDocuments;
    private final LegalDocumentService legalDocumentService;
    private final EquipmentRepository equipment;

    public DashboardService(VehicleRepository vehicles, ExpenseRepository expenses, FuelReceiptRepository fuelReceipts,
                            FuelReceiptService fuelReceiptService, MaintenanceRepository maintenance,
                            MaintenanceService maintenanceService, LegalDocumentRepository legalDocuments,
                            LegalDocumentService legalDocumentService, EquipmentRepository equipment) {
        this.vehicles = vehicles;
        this.expenses = expenses;
        this.fuelReceipts = fuelReceipts;
        this.fuelReceiptService = fuelReceiptService;
        this.maintenance = maintenance;
        this.maintenanceService = maintenanceService;
        this.legalDocuments = legalDocuments;
        this.legalDocumentService = legalDocumentService;
        this.equipment = equipment;
    }

    @Transactional(readOnly = true)
    public OverviewResponse overview() {
        LocalDate today = LocalDate.now();
        YearMonth month = YearMonth.from(today);
        List<AlertResponse> alerts = alerts();
        List<VehicleSummaryCard> cards = vehicles.findAllByOrderByCreatedAtDesc().stream()
                .map(v -> new VehicleSummaryCard(v.getId(), v.getName(), v.getLicensePlate(), v.getCurrentKm(), v.getImageUrl(), v.isActive()))
                .toList();
        return new OverviewResponse(
                vehicles.countByActiveTrue(),
                expenses.sumBetween(month.atDay(1), month.atEndOfMonth()),
                expenses.sumBetween(LocalDate.of(today.getYear(), 1, 1), LocalDate.of(today.getYear(), 12, 31)),
                alerts.stream().filter(a -> "URGENT".equals(a.severity())).count(),
                fuelReceipts.findFirstByOrderByReceiptDateDescCreatedAtDesc().map(fuelReceiptService::toResponse).orElse(null),
                cards
        );
    }

    @Transactional(readOnly = true)
    public List<AlertResponse> alerts() {
        List<AlertResponse> result = new ArrayList<>();
        for (MaintenanceItem item : maintenance.findAllByOrderByCreatedAtDesc()) {
            var response = maintenanceService.toResponse(item);
            if (response.status() == MaintenanceStatus.OVERDUE || response.status() == MaintenanceStatus.SOON) {
                result.add(new AlertResponse(response.status() == MaintenanceStatus.OVERDUE ? "URGENT" : "SOON", "MAINTENANCE",
                        response.vehicleId(), item.getVehicle().getName(), response.id(), item.getType().name(),
                        response.status() + " - km remaining: " + response.kmRemaining() + ", days remaining: " + response.daysRemaining()));
            }
        }
        for (LegalDocument doc : legalDocuments.findAllByOrderByEndDateAsc()) {
            var response = legalDocumentService.toResponse(doc);
            if (response.status() == LegalDocumentStatus.EXPIRED || response.status() == LegalDocumentStatus.EXPIRING_SOON) {
                result.add(new AlertResponse(response.status() == LegalDocumentStatus.EXPIRED ? "URGENT" : "SOON", "LEGAL",
                        response.vehicleId(), doc.getVehicle().getName(), response.id(), doc.getType().name(),
                        response.status() + " - days remaining: " + response.daysRemaining()));
            }
        }
        LocalDate today = LocalDate.now();
        for (EquipmentItem item : equipment.findAllByOrderByCreatedAtDesc()) {
            if (!item.isPresent()) {
                result.add(new AlertResponse("URGENT", "EQUIPMENT", item.getVehicle().getId(), item.getVehicle().getName(), item.getId(),
                        item.getType().name(), "Missing from vehicle"));
            } else if (item.getExpiryDate() != null) {
                long days = ChronoUnit.DAYS.between(today, item.getExpiryDate());
                if (item.getExpiryDate().isBefore(today) || days <= 30) {
                    result.add(new AlertResponse(item.getExpiryDate().isBefore(today) ? "URGENT" : "SOON", "EQUIPMENT",
                            item.getVehicle().getId(), item.getVehicle().getName(), item.getId(), item.getType().name(),
                            "Expiry days remaining: " + days));
                }
            }
        }
        return result;
    }

    @Transactional(readOnly = true)
    public List<MonthlyCost> monthlyCosts(int year) {
        var totals = expenses.monthlyTotals(year).stream()
                .collect(java.util.stream.Collectors.toMap(row -> ((Number) row[1]).intValue(), row -> (BigDecimal) row[2]));
        List<MonthlyCost> result = new ArrayList<>();
        for (int month = 1; month <= 12; month++) {
            result.add(new MonthlyCost(month, totals.getOrDefault(month, BigDecimal.ZERO)));
        }
        return result;
    }

    @Transactional(readOnly = true)
    public List<YearlyCost> yearlyCosts() {
        return expenses.yearlyTotals().stream()
                .map(row -> new YearlyCost(((Number) row[0]).intValue(), (BigDecimal) row[1]))
                .toList();
    }
}
