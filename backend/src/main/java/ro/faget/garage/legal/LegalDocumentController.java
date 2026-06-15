package ro.faget.garage.legal;

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

import static ro.faget.garage.legal.LegalDtos.*;

@RestController
@RequestMapping("/api")
public class LegalDocumentController {
    private final LegalDocumentService legalDocumentService;

    public LegalDocumentController(LegalDocumentService legalDocumentService) {
        this.legalDocumentService = legalDocumentService;
    }

    @GetMapping("/vehicles/{vehicleId}/legal-documents")
    List<LegalDocumentResponse> list(@PathVariable UUID vehicleId) { return legalDocumentService.list(vehicleId); }

    @PostMapping("/vehicles/{vehicleId}/legal-documents")
    LegalDocumentResponse create(@PathVariable UUID vehicleId, @Valid @RequestBody LegalDocumentRequest request) { return legalDocumentService.create(vehicleId, request); }

    @PutMapping("/legal-documents/{id}")
    LegalDocumentResponse update(@PathVariable UUID id, @Valid @RequestBody LegalDocumentRequest request) { return legalDocumentService.update(id, request); }

    @DeleteMapping("/legal-documents/{id}")
    void delete(@PathVariable UUID id) { legalDocumentService.delete(id); }
}
