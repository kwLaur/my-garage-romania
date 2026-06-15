package ro.faget.garage.dashboard;

import ro.faget.garage.fuel.FuelDtos.FuelReceiptResponse;
import ro.faget.garage.vehicle.VehicleDtos.VehicleResponse;

import java.math.BigDecimal;
import java.util.List;
import java.util.UUID;

public class DashboardDtos {
    public record OverviewResponse(long activeVehicles, BigDecimal totalCostCurrentMonth, BigDecimal totalCostCurrentYear,
                                   long urgentAlerts, FuelReceiptResponse latestFuelReceipt, List<VehicleSummaryCard> vehicles) {}

    public record VehicleSummaryCard(UUID id, String name, String licensePlate, Integer currentKm, String imageUrl, boolean active) {}

    public record AlertResponse(String severity, String category, UUID vehicleId, String vehicleName, UUID entityId, String title, String detail) {}

    public record MonthlyCost(int month, BigDecimal amount) {}

    public record YearlyCost(int year, BigDecimal amount) {}
}
