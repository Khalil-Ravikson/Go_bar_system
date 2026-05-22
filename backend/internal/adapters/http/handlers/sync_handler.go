package handlers

import (
	"context"
	"encoding/json"
	"net/http"
	"time"

	"github.com/google/uuid"
	"github.com/jackc/pgx/v5/pgtype"

	// IMPORTS ATUALIZADOS COM SEU REPOSITÓRIO:
	"github.com/Khalil-Ravikson/Comanda_app/backend/internal/adapters/http/dtos"
	"github.com/Khalil-Ravikson/Comanda_app/backend/internal/adapters/repository/database"
)

type SyncHandler struct {
	db *database.Queries
}

func NewSyncHandler(db *database.Queries) *SyncHandler {
	return &SyncHandler{db: db}
}

func (h *SyncHandler) HandleSyncOrders(w http.ResponseWriter, r *http.Request) {
	var req dtos.SyncRequestDTO

	if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
		http.Error(w, "JSON inválido", http.StatusBadRequest)
		return
	}

	var syncedIDs []string

	for _, event := range req.Events {
		// 1. Gera os UUIDs do Google (array de bytes)
		eventID, _ := uuid.Parse(event.ID)
		orderID, _ := uuid.Parse(event.AggregateID)
		tenantID, _ := uuid.Parse("00000000-0000-0000-0000-000000000001")

		occurredAt := time.UnixMilli(event.OccurredAt)

		// 2. CORREÇÃO AQUI: Converte para o pgtype.UUID que o sqlc espera
		err := h.db.InsertOrderEvent(context.Background(), database.InsertOrderEventParams{
			ID:         pgtype.UUID{Bytes: eventID, Valid: true},
			TenantID:   pgtype.UUID{Bytes: tenantID, Valid: true},
			OrderID:    pgtype.UUID{Bytes: orderID, Valid: true},
			EventType:  event.EventType,
			Payload:    []byte(event.Payload),
			OccurredAt: pgtype.Timestamptz{Time: occurredAt, Valid: true},
		})

		if err != nil {
			http.Error(w, "Erro ao salvar evento: "+err.Error(), http.StatusInternalServerError)
			return
		}

		syncedIDs = append(syncedIDs, event.ID)
	}

	w.Header().Set("Content-Type", "application/json")
	w.WriteHeader(http.StatusOK)
	json.NewEncoder(w).Encode(dtos.SyncResponseDTO{
		SyncedIDs: syncedIDs,
	})
}
