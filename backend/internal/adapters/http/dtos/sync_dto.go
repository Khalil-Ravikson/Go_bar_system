package dtos

// SyncEventDTO representa uma linha da tabela sync_outbox do mobile
type SyncEventDTO struct {
	ID          string `json:"id"`
	EventType   string `json:"event_type"`
	AggregateID string `json:"aggregate_id"`
	Payload     string `json:"payload"`
	OccurredAt  int64  `json:"occurred_at"` // Timestamp em milissegundos
}

// SyncRequestDTO é o array de eventos que o mobile envia de uma vez
type SyncRequestDTO struct {
	Events []SyncEventDTO `json:"events"`
}

// SyncResponseDTO é a resposta de sucesso com os IDs processados
type SyncResponseDTO struct {
	SyncedIDs []string `json:"synced_ids"`
}