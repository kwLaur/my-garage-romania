package ro.faget.garage.auth;

import jakarta.validation.constraints.Email;
import jakarta.validation.constraints.NotBlank;

import java.util.UUID;

public class AuthDtos {
    public record LoginRequest(@Email @NotBlank String email, @NotBlank String password) {}
    public record LoginResponse(String token, UserResponse user) {}
    public record UserResponse(UUID id, String email, String displayName) {}
}
