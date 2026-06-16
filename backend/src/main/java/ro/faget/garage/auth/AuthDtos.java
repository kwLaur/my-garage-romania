package ro.faget.garage.auth;

import jakarta.validation.constraints.Email;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;

import java.util.UUID;

public class AuthDtos {
    public record LoginRequest(@Email @NotBlank String email, @NotBlank String password) {}
    public record RegisterRequest(@Email @NotBlank String email, @NotBlank @Size(min = 8) String password, String displayName) {}
    public record LoginResponse(String token, UserResponse user) {}
    public record UserResponse(UUID id, String email, String displayName) {}
    public record ChangePasswordRequest(@NotBlank String currentPassword, @NotBlank @Size(min = 8) String newPassword) {}
}
