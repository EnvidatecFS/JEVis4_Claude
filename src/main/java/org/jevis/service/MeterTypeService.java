package org.jevis.service;

import org.jevis.model.MeterType;
import org.jevis.repository.MeterTypeRepository;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import java.util.List;

@Service
@Transactional(readOnly = true)
public class MeterTypeService {

    private static final Logger log = LoggerFactory.getLogger(MeterTypeService.class);
    private final MeterTypeRepository meterTypeRepository;

    public MeterTypeService(MeterTypeRepository meterTypeRepository) {
        this.meterTypeRepository = meterTypeRepository;
    }

    public List<MeterType> getAllMeterTypes() {
        return meterTypeRepository.findAllByOrderByDeviceTypeAsc();
    }

    public MeterType getMeterTypeById(Long id) {
        return meterTypeRepository.findById(id)
            .orElseThrow(() -> new IllegalArgumentException("MeterType not found: " + id));
    }

    @Transactional
    public MeterType createMeterType(MeterType meterType) {
        return meterTypeRepository.save(meterType);
    }

    @Transactional
    public MeterType updateMeterType(Long id, MeterType data) {
        MeterType existing = getMeterTypeById(id);
        existing.setDeviceType(data.getDeviceType());
        existing.setAccuracy(data.getAccuracy());
        existing.setDecimalPlaces(data.getDecimalPlaces());
        existing.setManufacturer(data.getManufacturer());
        existing.setManufacturerUrl(data.getManufacturerUrl());
        return meterTypeRepository.save(existing);
    }

    @Transactional
    public void deleteMeterType(Long id) {
        meterTypeRepository.deleteById(id);
    }
}
