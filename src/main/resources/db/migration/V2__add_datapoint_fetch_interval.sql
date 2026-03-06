ALTER TABLE nodered_datapoints
    ADD COLUMN fetch_interval_minutes INTEGER NOT NULL DEFAULT 15;
