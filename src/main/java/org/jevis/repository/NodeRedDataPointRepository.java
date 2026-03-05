package org.jevis.repository;

import org.jevis.model.NodeRedDataPoint;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface NodeRedDataPointRepository extends JpaRepository<NodeRedDataPoint, Long> {

    List<NodeRedDataPoint> findByDeviceId(Long deviceId);

    List<NodeRedDataPoint> findByDeviceIdAndIsActiveTrue(Long deviceId);

    List<NodeRedDataPoint> findBySensorId(Long sensorId);
}
