package org.jevis.repository;

import org.jevis.model.JobEvent;
import org.jevis.model.JobEventType;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Modifying;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.util.List;

public interface JobEventRepository extends JpaRepository<JobEvent, Long> {

    List<JobEvent> findByJobIdOrderByCreatedAtDesc(Long jobId);

    @Query("SELECT e FROM JobEvent e WHERE e.notifiedUser = :username AND e.notificationRead = false " +
           "ORDER BY e.createdAt DESC")
    List<JobEvent> findUnreadNotifications(@Param("username") String username);

    @Query("SELECT COUNT(e) FROM JobEvent e WHERE e.notifiedUser = :username AND e.notificationRead = false")
    long countUnreadNotifications(@Param("username") String username);

    @Query("SELECT e FROM JobEvent e WHERE e.notifiedUser = :username ORDER BY e.createdAt DESC")
    List<JobEvent> findNotificationsForUser(@Param("username") String username);

    @Modifying
    @Query("UPDATE JobEvent e SET e.notificationRead = true WHERE e.id = :id AND e.notifiedUser = :username")
    int markAsRead(@Param("id") Long id, @Param("username") String username);
}
