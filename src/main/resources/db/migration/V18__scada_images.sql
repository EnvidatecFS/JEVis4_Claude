CREATE TABLE scada_images (
    id            BIGSERIAL PRIMARY KEY,
    tenant_id     BIGINT       NOT NULL REFERENCES tenants(id) ON DELETE CASCADE,
    file_path     VARCHAR(500) NOT NULL,
    original_name VARCHAR(255),
    created_at    TIMESTAMPTZ  NOT NULL DEFAULT now()
);

CREATE INDEX idx_scada_images_tenant ON scada_images(tenant_id);
