package ro.faget.garage.dashboard;

import jakarta.validation.constraints.Min;
import org.springframework.validation.annotation.Validated;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;

import static ro.faget.garage.dashboard.DashboardDtos.*;

@Validated
@RestController
@RequestMapping("/api/dashboard")
public class DashboardController {
    private final DashboardService dashboardService;

    public DashboardController(DashboardService dashboardService) {
        this.dashboardService = dashboardService;
    }

    @GetMapping("/overview")
    OverviewResponse overview() { return dashboardService.overview(); }

    @GetMapping("/alerts")
    List<AlertResponse> alerts() { return dashboardService.alerts(); }

    @GetMapping("/costs/monthly")
    List<MonthlyCost> monthly(@RequestParam(required = false) @Min(2000) Integer year) {
        return dashboardService.monthlyCosts(year == null ? java.time.Year.now().getValue() : year);
    }

    @GetMapping("/costs/yearly")
    List<YearlyCost> yearly() { return dashboardService.yearlyCosts(); }
}
