package org.jevis.repository;

import org.jevis.model.MeterType;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;
import java.util.List;

@Repository
public interface MeterTypeRepository extends JpaRepository<MeterType, Long> {
    List<MeterType> findAllByOrderByDeviceTypeAsc();
}
