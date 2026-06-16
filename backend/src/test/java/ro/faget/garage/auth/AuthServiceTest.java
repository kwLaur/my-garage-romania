package ro.faget.garage.auth;

import org.junit.jupiter.api.Test;
import org.springframework.security.authentication.BadCredentialsException;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import ro.faget.garage.common.BadRequestException;

import java.util.Optional;
import java.util.UUID;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;
import static ro.faget.garage.auth.AuthDtos.ChangePasswordRequest;
import static ro.faget.garage.auth.AuthDtos.RegisterRequest;

class AuthServiceTest {
    private final AppUserRepository users = mock(AppUserRepository.class);
    private final BCryptPasswordEncoder passwordEncoder = new BCryptPasswordEncoder();
    private final JwtService jwtService = mock(JwtService.class);
    private final AuthService authService = new AuthService(users, passwordEncoder, jwtService);

    @Test
    void rejectsDuplicateEmailOnRegister() {
        when(users.existsByEmailIgnoreCase("owner@example.com")).thenReturn(true);

        assertThatThrownBy(() -> authService.register(new RegisterRequest(" Owner@Example.com ", "password123", "Owner")))
                .isInstanceOf(BadRequestException.class)
                .hasMessageContaining("already registered");
    }

    @Test
    void registersUserWithBcryptPasswordAndTokenResponse() {
        when(users.existsByEmailIgnoreCase("owner@example.com")).thenReturn(false);
        when(users.save(any(AppUser.class))).thenAnswer(invocation -> {
            AppUser user = invocation.getArgument(0);
            user.setId(UUID.randomUUID());
            return user;
        });
        when(jwtService.createToken(any(AppUser.class))).thenReturn("jwt-token");

        var response = authService.register(new RegisterRequest(" Owner@Example.com ", "password123", " Owner "));

        assertThat(response.token()).isEqualTo("jwt-token");
        assertThat(response.user().email()).isEqualTo("owner@example.com");
        assertThat(response.user().displayName()).isEqualTo("Owner");
        verify(users).save(any(AppUser.class));
    }

    @Test
    void changesPasswordWhenCurrentPasswordMatches() {
        AppUser user = new AppUser();
        user.setEmail("owner@example.com");
        user.setPasswordHash(passwordEncoder.encode("old-password"));
        when(users.findByEmailIgnoreCase("owner@example.com")).thenReturn(Optional.of(user));

        authService.changePassword("owner@example.com", new ChangePasswordRequest("old-password", "new-password"));

        assertThat(passwordEncoder.matches("new-password", user.getPasswordHash())).isTrue();
        verify(users).save(user);
    }

    @Test
    void rejectsChangePasswordWhenCurrentPasswordDoesNotMatch() {
        AppUser user = new AppUser();
        user.setEmail("owner@example.com");
        user.setPasswordHash(passwordEncoder.encode("old-password"));
        when(users.findByEmailIgnoreCase("owner@example.com")).thenReturn(Optional.of(user));

        assertThatThrownBy(() -> authService.changePassword("owner@example.com", new ChangePasswordRequest("wrong-password", "new-password")))
                .isInstanceOf(BadCredentialsException.class);
    }
}
