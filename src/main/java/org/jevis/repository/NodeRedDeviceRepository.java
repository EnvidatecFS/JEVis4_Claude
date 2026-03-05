package org.jevis.repository;

import org.jevis.model.NodeRedDevice;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface NodeRedDeviceRepository extends JpaRepository<NodeRedDevice, Long> {

    List<NodeRedDevice> findByIsActiveTrue();

    List<NodeRedDevice> findByIsActiveTrueOrderByDeviceNameAsc();
}
