package main

import (
	"context"
	"log"
	"net/http"
	"time"

	"github.com/Khalil-Ravikson/Comanda_app/backend/internal/adapters/http/handlers"
	"github.com/Khalil-Ravikson/Comanda_app/backend/internal/adapters/repository/database"
	"github.com/Khalil-Ravikson/Comanda_app/backend/internal/adapters/websocket"
	"github.com/go-chi/chi/v5"
	"github.com/go-chi/chi/v5/middleware"
	"github.com/jackc/pgx/v5/pgxpool"
)

func main() {


	// Exemplo rápido no main.go (apenas para teste):
	
	// 1. Conecta ao PostgreSQL (usando pgxpool para alta concorrência)
	// A string de conexão aponta para o Docker que subimos no Passo 1 da infra
	dsn := "postgres://root:secretpassword@localhost:5432/bar_database?sslmode=disable"
	dbPool, err := pgxpool.New(context.Background(), dsn)
	if err != nil {
		log.Fatalf("Não foi possível conectar ao banco de dados: %v\n", err)
	}
	defer dbPool.Close()

	// 2. Instancia as queries geradas pelo sqlc
	queries := database.New(dbPool)

	// 3. Instancia os nossos Handlers
	syncHandler := handlers.NewSyncHandler(queries)

	// 4. Configura o Roteador Chi
    r := chi.NewRouter()

    // Middlewares essenciais para estabilidade e observabilidade
    r.Use(middleware.RequestID)
    r.Use(middleware.RealIP)
    r.Use(middleware.Logger)
    r.Use(middleware.Recoverer)
    r.Use(middleware.Timeout(10 * time.Second))

    // 5. Define as Rotas HTTP
    r.Route("/api/v1", func(r chi.Router) {
        r.Post("/sync/orders", syncHandler.HandleSyncOrders) // Rota de Ingestão
    })

    // ==========================================
    // 6. SETUP DO WEBSOCKET (ANTES DE LIGAR O SERVIDOR)
    // ==========================================
    hub := websocket.NewHub()
    go hub.Run() // Inicia o Hub em background
    
    // Teste para enviar mensagem após 5 segundos
    go func() {
        time.Sleep(5 * time.Second)
        hub.Broadcast <- []byte("Olá, sistema online!")
    }()

    // Define a rota /ws
    r.Get("/ws", func(w http.ResponseWriter, r *http.Request) {
        websocket.ServeWs(hub, w, r)
    })

    // ==========================================
    // 7. INICIA O SERVIDOR (ÚLTIMA COISA DA FUNÇÃO MAIN)
    // ==========================================
    log.Println("🚀 Servidor Backend iniciado na porta :8080")
    err = http.ListenAndServe(":8080", r) // <--- O programa "trava" aqui trabalhando
    if err != nil {
        log.Fatalf("Erro ao iniciar servidor: %v", err)
    }
}
