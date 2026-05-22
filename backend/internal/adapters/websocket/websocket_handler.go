package websocket

import (
	"log"
	"net/http"

	"github.com/gorilla/websocket"
)

// Upgrader configura as opções do WebSocket (ex: permitir conexões de qualquer origem)
var upgrader = websocket.Upgrader{
	ReadBufferSize:  1024,
	WriteBufferSize: 1024,
	CheckOrigin: func(r *http.Request) bool {
		return true // Em produção, aqui você restringiria para o domínio do seu app
	},
}

// ServeWs gerencia a requisição de upgrade de HTTP para WebSocket
func ServeWs(hub *Hub, w http.ResponseWriter, r *http.Request) {
	conn, err := upgrader.Upgrade(w, r, nil)
	if err != nil {
		log.Println(err)
		return
	}

	// Cria o novo cliente e registra no Hub
	client := &Client{hub: hub, conn: conn, send: make(chan []byte, 256)}
	client.hub.Register <- client

	// Executa o ReadPump e o WritePump em Goroutines separadas
	// Isso permite que um celular leia e escreva ao mesmo tempo
	go client.WritePump()
	go client.ReadPump()
}
