package ro.faget.garage.expense;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.util.List;
import java.util.Optional;
import java.util.UUID;

public interface ExpenseRepository extends JpaRepository<Expense, UUID> {
    List<Expense> findByVehicleIdOrderByDateDesc(UUID vehicleId);
    Optional<Expense> findByLinkedEntityTypeAndLinkedEntityId(LinkedEntityType linkedEntityType, UUID linkedEntityId);
    void deleteByLinkedEntityTypeAndLinkedEntityId(LinkedEntityType linkedEntityType, UUID linkedEntityId);

    @Query("select coalesce(sum(e.amount), 0) from Expense e where e.date between :start and :end")
    BigDecimal sumBetween(@Param("start") LocalDate start, @Param("end") LocalDate end);

    @Query("select year(e.date), month(e.date), coalesce(sum(e.amount), 0) from Expense e where year(e.date) = :year group by year(e.date), month(e.date) order by month(e.date)")
    List<Object[]> monthlyTotals(@Param("year") int year);

    @Query("select year(e.date), coalesce(sum(e.amount), 0) from Expense e group by year(e.date) order by year(e.date)")
    List<Object[]> yearlyTotals();
}
