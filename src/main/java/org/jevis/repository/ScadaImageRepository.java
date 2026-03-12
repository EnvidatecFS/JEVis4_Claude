package org.jevis.repository;

import org.jevis.model.ScadaImage;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;
import java.util.Optional;

public interface ScadaImageRepository extends JpaRepository<ScadaImage, Long> {
    List<ScadaImage> findByTenantIdOrderByCreatedAtDesc(Long tenantId);
    Optional<ScadaImage> findByIdAndTenantId(Long id, Long tenantId);
}
