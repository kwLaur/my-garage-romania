package ro.faget.garage.config;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.boot.CommandLineRunner;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Component;
import ro.faget.garage.auth.AppUser;
import ro.faget.garage.auth.AppUserRepository;

@Component
public class DefaultUserInitializer implements CommandLineRunner {
    private final AppUserRepository users;
    private final PasswordEncoder passwordEncoder;
    private final String email;
    private final String password;

    public DefaultUserInitializer(AppUserRepository users, PasswordEncoder passwordEncoder,
                                  @Value("${app.default-user.email}") String email,
                                  @Value("${app.default-user.password}") String password) {
        this.users = users;
        this.passwordEncoder = passwordEncoder;
        this.email = email;
        this.password = password;
    }

    @Override
    public void run(String... args) {
        if (!users.existsByEmailIgnoreCase(email)) {
            AppUser user = new AppUser();
            user.setEmail(email);
            user.setDisplayName("Garage Owner");
            user.setPasswordHash(passwordEncoder.encode(password));
            users.save(user);
        }
    }
}
