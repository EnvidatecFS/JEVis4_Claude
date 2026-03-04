package org.jevis.repository;

import org.jevis.model.DashboardView;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Modifying;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface DashboardViewRepository extends JpaRepository<DashboardView, Long> {

    List<DashboardView> findByUsernameOrderByNameAsc(String username);

    Optional<DashboardView> findByIdAndUsername(Long id, String username);

    Optional<DashboardView> findByUsernameAndIsDefaultTrue(String username);

    long countByUsername(String username);

    @Modifying
    @Query("UPDATE DashboardView v SET v.isDefault = false WHERE v.username = :username")
    void clearDefaultForUser(@Param("username") String username);
}
