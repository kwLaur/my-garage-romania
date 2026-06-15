package ro.faget.garage.fuel;

import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.multipart.MultipartFile;
import ro.faget.garage.common.NotFoundException;
import ro.faget.garage.expense.ExpenseService;
import ro.faget.garage.expense.ExpenseType;
import ro.faget.garage.expense.LinkedEntityType;
import ro.faget.garage.vehicle.Vehicle;
import ro.faget.garage.vehicle.VehicleService;

import java.util.List;
import java.util.UUID;

import static ro.faget.garage.fuel.FuelDtos.*;

@Service
public class FuelReceiptService {
    private final FuelReceiptRepository fuelReceipts;
    private final VehicleService vehicles;
    private final ReceiptStorageService storage;
    private final ExpenseService expenses;

    public FuelReceiptService(FuelReceiptRepository fuelReceipts, VehicleService vehicles, ReceiptStorageService storage, ExpenseService expenses) {
        this.fuelReceipts = fuelReceipts;
        this.vehicles = vehicles;
        this.storage = storage;
        this.expenses = expenses;
    }

    @Transactional(readOnly = true)
    public List<FuelReceiptResponse> list(UUID vehicleId) {
        vehicles.getEntity(vehicleId);
        return fuelReceipts.findByVehicleIdOrderByReceiptDateDescCreatedAtDesc(vehicleId).stream().map(this::toResponse).toList();
    }

    @Transactional
    public FuelReceiptResponse create(UUID vehicleId, FuelReceiptRequest request) {
        FuelReceipt receipt = new FuelReceipt();
        receipt.setVehicle(vehicles.getEntity(vehicleId));
        apply(receipt, request);
        FuelReceipt saved = fuelReceipts.save(receipt);
        syncExpense(saved);
        return toResponse(saved);
    }

    @Transactional
    public FuelReceiptResponse createWithImage(UUID vehicleId, FuelReceiptRequest request, MultipartFile image) {
        FuelReceiptRequest withImage = new FuelReceiptRequest(request.receiptDate(), request.stationName(), request.fuelType(),
                request.quantityLiters(), request.unitPrice(), request.totalAmount(), request.odometerKm(), request.fullTank(),
                request.source() == null ? FuelReceiptSource.IOS_SCAN : request.source(), request.confidenceScore(), storage.store(image),
                request.rawOcrText(), request.notes());
        return create(vehicleId, withImage);
    }

    @Transactional
    public FuelReceiptResponse update(UUID id, FuelReceiptRequest request) {
        FuelReceipt receipt = fuelReceipts.findById(id).orElseThrow(() -> new NotFoundException("Fuel receipt not found"));
        apply(receipt, request);
        syncExpense(receipt);
        return toResponse(receipt);
    }

    @Transactional
    public void delete(UUID id) {
        FuelReceipt receipt = fuelReceipts.findById(id).orElseThrow(() -> new NotFoundException("Fuel receipt not found"));
        expenses.deleteLinked(LinkedEntityType.FUEL_RECEIPT, id);
        fuelReceipts.delete(receipt);
    }

    public FuelReceiptResponse toResponse(FuelReceipt receipt) {
        return new FuelReceiptResponse(receipt.getId(), receipt.getVehicle().getId(), receipt.getReceiptDate(), receipt.getStationName(),
                receipt.getFuelType(), receipt.getQuantityLiters(), receipt.getUnitPrice(), receipt.getTotalAmount(), receipt.getOdometerKm(),
                receipt.isFullTank(), receipt.getSource(), receipt.getConfidenceScore(), receipt.getReceiptImageUrl(), receipt.getRawOcrText(),
                receipt.getNotes(), receipt.getCreatedAt(), receipt.getUpdatedAt());
    }

    private void apply(FuelReceipt receipt, FuelReceiptRequest request) {
        receipt.setReceiptDate(request.receiptDate());
        receipt.setStationName(request.stationName());
        receipt.setFuelType(request.fuelType());
        receipt.setQuantityLiters(request.quantityLiters());
        receipt.setUnitPrice(request.unitPrice());
        receipt.setTotalAmount(request.totalAmount());
        receipt.setOdometerKm(request.odometerKm());
        receipt.setFullTank(Boolean.TRUE.equals(request.fullTank()));
        receipt.setSource(request.source() == null ? FuelReceiptSource.MANUAL : request.source());
        receipt.setConfidenceScore(request.confidenceScore());
        receipt.setReceiptImageUrl(request.receiptImageUrl());
        receipt.setRawOcrText(request.rawOcrText());
        receipt.setNotes(request.notes());
    }

    private void syncExpense(FuelReceipt receipt) {
        Vehicle vehicle = receipt.getVehicle();
        expenses.upsertLinked(vehicle, LinkedEntityType.FUEL_RECEIPT, receipt.getId(), "Fuel " + vehicle.getLicensePlate(),
                receipt.getStationName(), receipt.getTotalAmount(), receipt.getReceiptDate(), ExpenseType.FUEL);
    }
}
