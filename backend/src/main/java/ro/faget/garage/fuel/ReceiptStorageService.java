package ro.faget.garage.fuel;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;
import org.springframework.web.multipart.MultipartFile;
import ro.faget.garage.common.BadRequestException;

import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.util.Map;
import java.util.UUID;

@Service
public class ReceiptStorageService {
    private static final Map<String, String> EXTENSIONS = Map.of(
            "image/jpeg", ".jpg",
            "image/png", ".png",
            "image/webp", ".webp"
    );
    private final Path receiptsPath;
    private final long maxSizeBytes;

    public ReceiptStorageService(@Value("${app.uploads.receipts-path}") String receiptsPath,
                                 @Value("${app.uploads.max-size-bytes}") long maxSizeBytes) {
        this.receiptsPath = Path.of(receiptsPath).toAbsolutePath().normalize();
        this.maxSizeBytes = maxSizeBytes;
    }

    public String store(MultipartFile file) {
        if (file == null || file.isEmpty()) {
            throw new BadRequestException("Receipt image is required");
        }
        if (file.getSize() > maxSizeBytes) {
            throw new BadRequestException("Receipt image exceeds maximum size");
        }
        String extension = EXTENSIONS.get(file.getContentType());
        if (extension == null) {
            throw new BadRequestException("Receipt image must be JPEG, PNG, or WEBP");
        }
        try {
            Files.createDirectories(receiptsPath);
            String filename = UUID.randomUUID() + extension;
            Path destination = receiptsPath.resolve(filename).normalize();
            if (!destination.startsWith(receiptsPath)) {
                throw new BadRequestException("Invalid upload path");
            }
            file.transferTo(destination);
            return "/uploads/receipts/" + filename;
        } catch (IOException ex) {
            throw new BadRequestException("Could not store receipt image");
        }
    }
}
