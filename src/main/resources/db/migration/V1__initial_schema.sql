-- =============================================================================
-- V1__initial_schema.sql
-- JEVis 4 - Initial database schema for PostgreSQL
-- =============================================================================

-- -----------------------------------------------------------------------------
-- sensors
-- -----------------------------------------------------------------------------
CREATE TABLE sensors (
    id                  BIGSERIAL PRIMARY KEY,
    sensor_code         VARCHAR(100)  NOT NULL UNIQUE,
    measurement_type    VARCHAR(100)  NOT NULL,
    unit                VARCHAR(50)   NOT NULL,
    is_active           BOOLEAN       NOT NULL DEFAULT TRUE,
    sensor_name         VARCHAR(255),
    location            VARCHAR(255),
    description         TEXT,
    manufacturer        VARCHAR(100),
    model               VARCHAR(100),
    calibration_date    DATE,
    logical_sensor_id   BIGINT,
    replaced_at         TIMESTAMPTZ,
    replaces_sensor_id  BIGINT REFERENCES sensors(id),
    metadata            TEXT,
    created_at          TIMESTAMPTZ   NOT NULL DEFAULT now(),
    updated_at          TIMESTAMPTZ   NOT NULL DEFAULT now()
);

CREATE INDEX idx_sensors_code       ON sensors (sensor_code);
CREATE INDEX idx_sensors_type       ON sensors (measurement_type);
CREATE INDEX idx_sensors_logical_id ON sensors (logical_sensor_id);

-- -----------------------------------------------------------------------------
-- measurements  (composite PK: sensor_id + measured_at + priority)
-- -----------------------------------------------------------------------------
CREATE TABLE measurements (
    sensor_id           BIGINT        NOT NULL REFERENCES sensors(id) ON DELETE CASCADE,
    measured_at         TIMESTAMPTZ   NOT NULL,
    priority            SMALLINT      NOT NULL CHECK (priority BETWEEN 0 AND 3),
    measurement_value   NUMERIC(15,6) NOT NULL,
    source_type         VARCHAR(50)   NOT NULL DEFAULT 'automatic'
                            CHECK (source_type IN ('automatic','manual','corrected','validated')),
    quality_flag        SMALLINT      DEFAULT 0,
    created_by          VARCHAR(100),
    comment             TEXT,
    imported_at         TIMESTAMPTZ   NOT NULL DEFAULT now(),
    PRIMARY KEY (sensor_id, measured_at, priority)
);

CREATE INDEX idx_measurements_sensor_time_prio ON measurements (sensor_id, measured_at DESC, priority DESC);
CREATE INDEX idx_measurements_time             ON measurements (measured_at DESC);
CREATE INDEX idx_measurements_imported         ON measurements (imported_at);
CREATE INDEX idx_measurements_created_by       ON measurements (created_by);

-- -----------------------------------------------------------------------------
-- worker_pools
-- -----------------------------------------------------------------------------
CREATE TABLE worker_pools (
    id                  BIGSERIAL PRIMARY KEY,
    pool_name           VARCHAR(100)  NOT NULL UNIQUE,
    description         TEXT,
    is_default          BOOLEAN       NOT NULL DEFAULT FALSE,
    max_concurrent_jobs INTEGER       NOT NULL DEFAULT 10,
    created_at          TIMESTAMPTZ   NOT NULL DEFAULT now(),
    updated_at          TIMESTAMPTZ   NOT NULL DEFAULT now()
);

CREATE INDEX idx_worker_pools_name ON worker_pools (pool_name);

-- -----------------------------------------------------------------------------
-- task_workers
-- -----------------------------------------------------------------------------
CREATE TABLE task_workers (
    id                  BIGSERIAL PRIMARY KEY,
    worker_identifier   VARCHAR(255)  NOT NULL UNIQUE,
    worker_name         VARCHAR(255),
    worker_pool_id      BIGINT REFERENCES worker_pools(id),
    status              VARCHAR(20)   NOT NULL DEFAULT 'IDLE'
                            CHECK (status IN ('IDLE','BUSY','OFFLINE')),
    capabilities        VARCHAR(500),
    host_name           VARCHAR(255),
    ip_address          VARCHAR(45),
    max_concurrent_jobs INTEGER       NOT NULL DEFAULT 1,
    current_job_count   INTEGER       NOT NULL DEFAULT 0,
    last_heartbeat_at   TIMESTAMPTZ,
    api_key             VARCHAR(255),
    created_at          TIMESTAMPTZ   NOT NULL DEFAULT now(),
    updated_at          TIMESTAMPTZ   NOT NULL DEFAULT now()
);

CREATE INDEX idx_task_workers_identifier ON task_workers (worker_identifier);
CREATE INDEX idx_task_workers_pool       ON task_workers (worker_pool_id);
CREATE INDEX idx_task_workers_status     ON task_workers (status);

-- -----------------------------------------------------------------------------
-- jobs
-- -----------------------------------------------------------------------------
CREATE TABLE jobs (
    id                      BIGSERIAL PRIMARY KEY,
    job_name                VARCHAR(255)  NOT NULL,
    job_type                VARCHAR(50)   NOT NULL
                                CHECK (job_type IN ('DATA_FETCH','CALCULATION','REPORT_GENERATION','DATA_CLEANUP','CUSTOM')),
    status                  VARCHAR(30)   NOT NULL DEFAULT 'CREATED'
                                CHECK (status IN ('CREATED','QUEUED','ASSIGNED','RUNNING','COMPLETED','FAILED','TIMED_OUT','RETRY_SCHEDULED','CANCELLED','ALARM')),
    priority                VARCHAR(20)   NOT NULL DEFAULT 'NORMAL'
                                CHECK (priority IN ('CRITICAL','HIGH','NORMAL','LOW','RETRY')),
    worker_pool_id          BIGINT REFERENCES worker_pools(id),
    cron_expression         VARCHAR(100),
    scheduled_for           TIMESTAMPTZ,
    is_recurring            BOOLEAN       NOT NULL DEFAULT FALSE,
    timeout_seconds         INTEGER       NOT NULL DEFAULT 3600,
    max_retry_attempts      INTEGER       NOT NULL DEFAULT 3,
    retry_count             INTEGER       NOT NULL DEFAULT 0,
    retry_backoff_seconds   INTEGER       NOT NULL DEFAULT 300,
    job_parameters          TEXT,
    created_by              VARCHAR(100),
    parent_job_id           BIGINT,
    on_success_job_type     VARCHAR(50)
                                CHECK (on_success_job_type IN ('DATA_FETCH','CALCULATION','REPORT_GENERATION','DATA_CLEANUP','CUSTOM') OR on_success_job_type IS NULL),
    on_success_job_params   TEXT,
    created_at              TIMESTAMPTZ   NOT NULL DEFAULT now(),
    updated_at              TIMESTAMPTZ   NOT NULL DEFAULT now()
);

CREATE INDEX idx_jobs_status            ON jobs (status);
CREATE INDEX idx_jobs_type              ON jobs (job_type);
CREATE INDEX idx_jobs_priority_scheduled ON jobs (priority, scheduled_for);
CREATE INDEX idx_jobs_worker_pool       ON jobs (worker_pool_id);
CREATE INDEX idx_jobs_parent            ON jobs (parent_job_id);

-- -----------------------------------------------------------------------------
-- job_executions
-- -----------------------------------------------------------------------------
CREATE TABLE job_executions (
    id                  BIGSERIAL PRIMARY KEY,
    job_id              BIGINT        NOT NULL REFERENCES jobs(id),
    execution_number    INTEGER       NOT NULL DEFAULT 1,
    status              VARCHAR(30)   NOT NULL DEFAULT 'RUNNING'
                            CHECK (status IN ('CREATED','QUEUED','ASSIGNED','RUNNING','COMPLETED','FAILED','TIMED_OUT','RETRY_SCHEDULED','CANCELLED','ALARM')),
    worker_id           BIGINT REFERENCES task_workers(id),
    started_at          TIMESTAMPTZ,
    finished_at         TIMESTAMPTZ,
    duration_ms         BIGINT,
    result              TEXT,
    error_message       TEXT,
    stack_trace         TEXT,
    progress_percent    INTEGER       DEFAULT 0,
    progress_message    VARCHAR(500),
    created_at          TIMESTAMPTZ   NOT NULL DEFAULT now()
);

CREATE INDEX idx_job_executions_job    ON job_executions (job_id);
CREATE INDEX idx_job_executions_worker ON job_executions (worker_id);
CREATE INDEX idx_job_executions_status ON job_executions (status);

-- -----------------------------------------------------------------------------
-- job_events
-- -----------------------------------------------------------------------------
CREATE TABLE job_events (
    id                  BIGSERIAL PRIMARY KEY,
    job_id              BIGINT        NOT NULL REFERENCES jobs(id),
    event_type          VARCHAR(30)   NOT NULL
                            CHECK (event_type IN ('JOB_CREATED','JOB_QUEUED','JOB_ASSIGNED','JOB_STARTED','JOB_COMPLETED','JOB_FAILED','JOB_TIMEOUT','JOB_RETRY_SCHEDULED','JOB_CANCELLED','JOB_ALARM')),
    event_message       VARCHAR(500),
    event_data          TEXT,
    notified_user       VARCHAR(100),
    notification_read   BOOLEAN       NOT NULL DEFAULT FALSE,
    created_at          TIMESTAMPTZ   NOT NULL DEFAULT now()
);

CREATE INDEX idx_job_events_job       ON job_events (job_id);
CREATE INDEX idx_job_events_type      ON job_events (event_type);
CREATE INDEX idx_job_events_user_read ON job_events (notified_user, notification_read);

-- -----------------------------------------------------------------------------
-- dashboard_views
-- -----------------------------------------------------------------------------
CREATE TABLE dashboard_views (
    id          BIGSERIAL PRIMARY KEY,
    name        VARCHAR(255)  NOT NULL,
    username    VARCHAR(255)  NOT NULL,
    layout_json TEXT,
    is_default  BOOLEAN       NOT NULL DEFAULT FALSE,
    created_at  TIMESTAMPTZ   NOT NULL DEFAULT now(),
    updated_at  TIMESTAMPTZ   NOT NULL DEFAULT now()
);

CREATE INDEX idx_dashboard_views_username         ON dashboard_views (username);
CREATE INDEX idx_dashboard_views_username_default ON dashboard_views (username, is_default);

-- -----------------------------------------------------------------------------
-- nodered_devices
-- -----------------------------------------------------------------------------
CREATE TABLE nodered_devices (
    id                  BIGSERIAL PRIMARY KEY,
    device_name         VARCHAR(255)  NOT NULL,
    api_url             VARCHAR(500)  NOT NULL,
    username            VARCHAR(255),
    password            VARCHAR(255),
    default_limit       INTEGER       NOT NULL DEFAULT 1000,
    is_active           BOOLEAN       NOT NULL DEFAULT TRUE,
    last_reached_at     TIMESTAMPTZ,
    last_data_import_at TIMESTAMPTZ,
    created_at          TIMESTAMPTZ   NOT NULL DEFAULT now(),
    updated_at          TIMESTAMPTZ   NOT NULL DEFAULT now()
);

CREATE INDEX idx_nodered_devices_active ON nodered_devices (is_active);

-- -----------------------------------------------------------------------------
-- nodered_datapoints
-- -----------------------------------------------------------------------------
CREATE TABLE nodered_datapoints (
    id                  BIGSERIAL PRIMARY KEY,
    device_id           BIGINT        NOT NULL REFERENCES nodered_devices(id) ON DELETE CASCADE,
    sensor_id           BIGINT        NOT NULL REFERENCES sensors(id) ON DELETE CASCADE,
    remote_id           VARCHAR(255)  NOT NULL,
    remote_name         VARCHAR(255),
    is_active           BOOLEAN       NOT NULL DEFAULT TRUE,
    last_success_at     TIMESTAMPTZ,
    last_data_timestamp TIMESTAMPTZ,
    last_import_count   INTEGER,
    created_at          TIMESTAMPTZ   NOT NULL DEFAULT now(),
    updated_at          TIMESTAMPTZ   NOT NULL DEFAULT now()
);

CREATE INDEX idx_nodered_dp_device    ON nodered_datapoints (device_id);
CREATE INDEX idx_nodered_dp_sensor    ON nodered_datapoints (sensor_id);
CREATE INDEX idx_nodered_dp_remote_id ON nodered_datapoints (remote_id);

-- -----------------------------------------------------------------------------
-- csr_actions
-- -----------------------------------------------------------------------------
CREATE TABLE csr_actions (
    id                  BIGSERIAL PRIMARY KEY,
    title               VARCHAR(255)  NOT NULL,
    description         TEXT,
    category            VARCHAR(50)   NOT NULL
                            CHECK (category IN ('ENVIRONMENTAL','SOCIAL','GOVERNANCE','ECONOMIC')),
    status              VARCHAR(50)   NOT NULL DEFAULT 'PLANNED'
                            CHECK (status IN ('PLANNED','IN_PROGRESS','ON_HOLD','COMPLETED','CANCELLED')),
    responsible_person  VARCHAR(255),
    deadline            DATE,
    progress_percent    INTEGER       DEFAULT 0 CHECK (progress_percent BETWEEN 0 AND 100),
    priority            VARCHAR(20)   DEFAULT 'MEDIUM',
    estimated_impact    TEXT,
    created_at          TIMESTAMPTZ   NOT NULL DEFAULT now(),
    updated_at          TIMESTAMPTZ   NOT NULL DEFAULT now(),
    created_by          VARCHAR(255)
);

CREATE INDEX idx_csr_actions_category ON csr_actions (category);
CREATE INDEX idx_csr_actions_status   ON csr_actions (status);
CREATE INDEX idx_csr_actions_deadline ON csr_actions (deadline);
