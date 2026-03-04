package org.jevis.repository;

import org.jevis.model.CsrAction;
import org.jevis.model.CsrCategory;
import org.jevis.model.CsrStatus;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.time.LocalDate;
import java.util.List;

/**
 * Repository for CsrAction entity providing query methods for CSR action management.
 */
@Repository
public interface CsrActionRepository extends JpaRepository<CsrAction, Long> {

    // Find by category
    List<CsrAction> findByCategory(CsrCategory category);

    // Find by status
    List<CsrAction> findByStatus(CsrStatus status);

    // Find by responsible person
    List<CsrAction> findByResponsiblePerson(String responsiblePerson);

    // Find actions with deadline before date
    List<CsrAction> findByDeadlineBefore(LocalDate date);

    // Find actions with deadline between dates
    List<CsrAction> findByDeadlineBetween(LocalDate start, LocalDate end);

    // Find overdue actions (deadline passed and not completed)
    @Query("SELECT a FROM CsrAction a WHERE a.deadline < :today AND a.status NOT IN ('COMPLETED', 'CANCELLED')")
    List<CsrAction> findOverdueActions(@Param("today") LocalDate today);

    // Find actions by priority
    List<CsrAction> findByPriority(String priority);

    /**
     * Search actions with filters (paginated).
     * @param search Search term (matches title, description, or responsible person)
     * @param category Category filter
     * @param status Status filter
     * @param pageable Pagination parameters
     * @return Page of matching actions
     */
    @Query("""
        SELECT a FROM CsrAction a
        WHERE (:search IS NULL OR LOWER(a.title) LIKE :search OR LOWER(a.description) LIKE :search OR LOWER(a.responsiblePerson) LIKE :search)
        AND (:category IS NULL OR a.category = :category)
        AND (:status IS NULL OR a.status = :status)
    """)
    Page<CsrAction> searchActions(
        @Param("search") String search,
        @Param("category") CsrCategory category,
        @Param("status") CsrStatus status,
        Pageable pageable
    );

    // Count actions by category
    @Query("SELECT a.category, COUNT(a) FROM CsrAction a GROUP BY a.category")
    List<Object[]> countByCategory();

    // Count actions by status
    @Query("SELECT a.status, COUNT(a) FROM CsrAction a GROUP BY a.status")
    List<Object[]> countByStatus();
}
