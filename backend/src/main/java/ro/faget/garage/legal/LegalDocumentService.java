package ro.faget.garage.legal;

import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import ro.faget.garage.common.NotFoundException;
import ro.faget.garage.expense.ExpenseService;
import ro.faget.garage.expense.ExpenseType;
import ro.faget.garage.expense.LinkedEntityType;
import ro.faget.garage.vehicle.Vehicle;
import ro.faget.garage.vehicle.VehicleService;

import java.util.List;
import java.util.UUID;

import static ro.faget.garage.legal.LegalDtos.*;

@Service
public class LegalDocumentService {
    private final LegalDocumentRepository documents;
    private final VehicleService vehicles;
    private final LegalStatusCalculator calculator;
    private final ExpenseService expenses;

    public LegalDocumentService(LegalDocumentRepository documents, VehicleService vehicles, LegalStatusCalculator calculator, ExpenseService expenses) {
        this.documents = documents;
        this.vehicles = vehicles;
        this.calculator = calculator;
        this.expenses = expenses;
    }

    @Transactional(readOnly = true)
    public List<LegalDocumentResponse> list(UUID vehicleId) {
        vehicles.getEntity(vehicleId);
        return documents.findByVehicleIdOrderByEndDateAsc(vehicleId).stream().map(this::toResponse).toList();
    }

    @Transactional
    public LegalDocumentResponse create(UUID vehicleId, LegalDocumentRequest request) {
        LegalDocument doc = new LegalDocument();
        doc.setVehicle(vehicles.getEntity(vehicleId));
        apply(doc, request);
        LegalDocument saved = documents.save(doc);
        syncExpense(saved);
        return toResponse(saved);
    }

    @Transactional
    public LegalDocumentResponse update(UUID id, LegalDocumentRequest request) {
        LegalDocument doc = documents.findById(id).orElseThrow(() -> new NotFoundException("Legal document not found"));
        apply(doc, request);
        syncExpense(doc);
        return toResponse(doc);
    }

    @Transactional
    public void delete(UUID id) {
        LegalDocument doc = documents.findById(id).orElseThrow(() -> new NotFoundException("Legal document not found"));
        expenses.deleteLinked(LinkedEntityType.LEGAL_DOCUMENT, id);
        documents.delete(doc);
    }

    public LegalDocumentResponse toResponse(LegalDocument doc) {
        LegalStatusProjection status = calculator.calculate(doc.getEndDate(), doc.isIgnored());
        return new LegalDocumentResponse(doc.getId(), doc.getVehicle().getId(), doc.getType(), doc.getStartDate(), doc.getEndDate(),
                doc.getProvider(), doc.getPolicyNumber(), doc.getDocumentUrl(), doc.getCost(), doc.getSource(), doc.isIgnored(),
                doc.getNotes(), status.daysRemaining(), status.status(), doc.getCreatedAt(), doc.getUpdatedAt());
    }

    private void apply(LegalDocument doc, LegalDocumentRequest request) {
        doc.setType(request.type());
        doc.setStartDate(request.startDate());
        doc.setEndDate(request.endDate());
        doc.setProvider(request.provider());
        doc.setPolicyNumber(request.policyNumber());
        doc.setDocumentUrl(request.documentUrl());
        doc.setCost(request.cost());
        doc.setSource(request.source() == null ? LegalDocumentSource.MANUAL : request.source());
        doc.setIgnored(Boolean.TRUE.equals(request.ignored()));
        doc.setNotes(request.notes());
    }

    private void syncExpense(LegalDocument doc) {
        Vehicle vehicle = doc.getVehicle();
        expenses.upsertLinked(vehicle, LinkedEntityType.LEGAL_DOCUMENT, doc.getId(), doc.getType().name() + " " + vehicle.getLicensePlate(),
                doc.getProvider(), doc.getCost(), doc.getStartDate() == null ? doc.getEndDate() : doc.getStartDate(), ExpenseType.LEGAL);
    }
}
