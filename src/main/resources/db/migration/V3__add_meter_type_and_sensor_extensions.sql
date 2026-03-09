CREATE TABLE meter_types (
    id                  BIGSERIAL PRIMARY KEY,
    device_type         VARCHAR(255),
    accuracy            VARCHAR(100),
    datasheet_path      VARCHAR(500),
    image_path          VARCHAR(500),
    decimal_places      INTEGER,
    manufacturer        VARCHAR(255),
    manufacturer_url    VARCHAR(500),
    created_at          TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at          TIMESTAMPTZ NOT NULL DEFAULT now()
);

ALTER TABLE sensors ADD COLUMN IF NOT EXISTS parent_sensor_id   BIGINT REFERENCES sensors(id);
ALTER TABLE sensors ADD COLUMN IF NOT EXISTS sensor_tag          VARCHAR(100);
ALTER TABLE sensors ADD COLUMN IF NOT EXISTS medium              VARCHAR(50);
ALTER TABLE sensors ADD COLUMN IF NOT EXISTS device_number       VARCHAR(255);
ALTER TABLE sensors ADD COLUMN IF NOT EXISTS gps_lat             DECIMAL(10,7);
ALTER TABLE sensors ADD COLUMN IF NOT EXISTS gps_lon             DECIMAL(10,7);
ALTER TABLE sensors ADD COLUMN IF NOT EXISTS installation_location_lat  DECIMAL(10,7);
ALTER TABLE sensors ADD COLUMN IF NOT EXISTS installation_location_lon  DECIMAL(10,7);
ALTER TABLE sensors ADD COLUMN IF NOT EXISTS cost_center         VARCHAR(255);
ALTER TABLE sensors ADD COLUMN IF NOT EXISTS meter_type_id       BIGINT REFERENCES meter_types(id);
ALTER TABLE sensors ADD COLUMN IF NOT EXISTS serial_number       VARCHAR(255);
ALTER TABLE sensors ADD COLUMN IF NOT EXISTS ip_address          VARCHAR(45);
ALTER TABLE sensors ADD COLUMN IF NOT EXISTS verification_document_path VARCHAR(500);
ALTER TABLE sensors ADD COLUMN IF NOT EXISTS sensor_image_path   VARCHAR(500);
ALTER TABLE sensors ADD COLUMN IF NOT EXISTS installation_date   DATE;
ALTER TABLE sensors ADD COLUMN IF NOT EXISTS last_inspection_date DATE;
ALTER TABLE sensors ADD COLUMN IF NOT EXISTS current_transformer VARCHAR(255);
ALTER TABLE sensors ADD COLUMN IF NOT EXISTS current_transformer_ratio VARCHAR(100);
ALTER TABLE sensors ADD COLUMN IF NOT EXISTS voltage_transformer_ratio VARCHAR(100);
ALTER TABLE sensors ADD COLUMN IF NOT EXISTS voltage_transformer VARCHAR(255);
ALTER TABLE sensors ADD COLUMN IF NOT EXISTS notes               TEXT;

CREATE INDEX IF NOT EXISTS idx_sensors_parent      ON sensors (parent_sensor_id);
CREATE INDEX IF NOT EXISTS idx_sensors_tag         ON sensors (sensor_tag);
CREATE INDEX IF NOT EXISTS idx_sensors_meter_type  ON sensors (meter_type_id);
