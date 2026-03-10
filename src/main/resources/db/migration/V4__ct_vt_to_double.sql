ALTER TABLE sensors
    ALTER COLUMN current_transformer TYPE DOUBLE PRECISION
        USING CASE WHEN current_transformer ~ '^[0-9]*\.?[0-9]+$'
                   THEN current_transformer::DOUBLE PRECISION ELSE NULL END,
    ALTER COLUMN voltage_transformer TYPE DOUBLE PRECISION
        USING CASE WHEN voltage_transformer ~ '^[0-9]*\.?[0-9]+$'
                   THEN voltage_transformer::DOUBLE PRECISION ELSE NULL END;
