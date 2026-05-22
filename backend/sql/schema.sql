-- Arquivo: backend/sql/schema.sql

CREATE TABLE orders (
    id UUID PRIMARY KEY,
    tenant_id UUID NOT NULL,
    table_number INT NOT NULL,
    status VARCHAR(50) NOT NULL,
    opened_at TIMESTAMPTZ NOT NULL,
    deleted_at TIMESTAMPTZ
);

CREATE TABLE order_items (
    id UUID PRIMARY KEY,
    order_id UUID NOT NULL REFERENCES orders(id),
    product_id TEXT NOT NULL,
    quantity INT NOT NULL,
    notes TEXT,
    deleted_at TIMESTAMPTZ
);

-- A tabela mais crítica do sistema
CREATE TABLE order_events (
    id UUID PRIMARY KEY,
    tenant_id UUID NOT NULL,
    order_id UUID NOT NULL,
    event_type VARCHAR(100) NOT NULL,
    payload JSONB NOT NULL,
    occurred_at TIMESTAMPTZ NOT NULL,
    processed_at TIMESTAMPTZ DEFAULT NOW()
);

-- Índices de performance para buscas futuras
CREATE INDEX idx_order_events_order_id ON order_events(order_id);
CREATE INDEX idx_orders_tenant_status ON orders(tenant_id, status);