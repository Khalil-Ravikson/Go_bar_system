-- Arquivo: backend/sql/query.sql

-- name: InsertOrderEvent :exec
INSERT INTO order_events (
    id, tenant_id, order_id, event_type, payload, occurred_at
) VALUES (
    $1, $2, $3, $4, $5, $6
)
ON CONFLICT (id) DO NOTHING;

-- name: GetOrderEvents :many
SELECT * FROM order_events 
WHERE order_id = $1 
ORDER BY occurred_at ASC;