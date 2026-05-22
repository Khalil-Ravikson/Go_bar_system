package websocket

import (
	"log"

	"github.com/gorilla/websocket"
)

// Client é um garçom (ou caixa) conectado ao nosso sistema.
type Client struct {
	hub *Hub

	// A conexão WebSocket real
	conn *websocket.Conn

	// Canal de saída (Buffered channel) para enviar mensagens para este celular específico
	send chan []byte
}

// ReadPump bombeia mensagens do WebSocket do celular para o Hub.
// Deve rodar em uma Goroutine separada.
func (c *Client) ReadPump() {
	defer func() {
		c.hub.Unregister <- c
		c.conn.Close()
	}()

	for {
		// Lê a mensagem vinda do celular
		_, _, err := c.conn.ReadMessage()
		if err != nil {
			log.Printf("Erro ao ler WebSocket: %v", err)
			break
		}
		// Se precisássemos processar comandos vindos do celular, seria aqui.
		// Por enquanto, apenas mantemos a conexão viva.
	}
}

// WritePump bombeia mensagens do Hub para o WebSocket do celular.
// WritePump bombeia mensagens do Hub para o WebSocket do celular.
func (c *Client) WritePump() {
	defer func() {
		c.conn.Close()
	}()

	// O loop infinito é o padrão correto aqui, pois ele deve durar 
	// enquanto o cliente estiver conectado.
	for {
		select {
		case message, ok := <-c.send:
			if !ok {
				// Hub fechou o canal
				c.conn.WriteMessage(websocket.CloseMessage, []byte{})
				return
			}

			// Envia a mensagem para o celular
			err := c.conn.WriteMessage(websocket.TextMessage, message)
			if err != nil {
				return
			}
		}
	}
}