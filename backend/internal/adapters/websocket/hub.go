package websocket

// Hub mantém o conjunto de clientes ativos e transmite mensagens para eles.
type Hub struct {
	// Clientes registrados (a "lista de presença"). 
	// O mapa usa o ponteiro do Cliente como chave para buscas super rápidas.
	Clients map[*Client]bool

	// Canal por onde chegam as mensagens que devem ser enviadas para todos os celulares (Broadcast).
	Broadcast chan []byte

	// Canal para registrar novos celulares que acabaram de abrir o app.
	Register chan *Client

	// Canal para remover celulares que fecharam o app ou perderam o sinal de internet.
	Unregister chan *Client
}

// NewHub inicializa o Hub e seus canais
func NewHub() *Hub {
	return &Hub{
		Broadcast:  make(chan []byte),
		Register:   make(chan *Client),
		Unregister: make(chan *Client),
		Clients:    make(map[*Client]bool),
	}
}

// Run é o motor do Hub. Ele roda em uma Goroutine separada e fica ouvindo os canais infinitamente.
func (h *Hub) Run() {
	for {
		select {
		case client := <-h.Register:
			// Um novo celular se conectou
			h.Clients[client] = true

		case client := <-h.Unregister:
			// Um celular desconectou
			if _, ok := h.Clients[client]; ok {
				delete(h.Clients, client) // Tira da lista de presença
				close(client.send)        // Fecha o canal de envio dele para não vazar memória
			}

		case message := <-h.Broadcast:
			// Chegou uma mensagem nova (ex: "Batata Frita Pronta")
			// O Hub pega essa mensagem e tenta enviar para TODOS os celulares da lista
			for client := range h.Clients {
				select {
				case client.send <- message:
					// Mensagem enviada para a fila deste celular
				default:
					// Se a fila do celular travou (celular muito lento ou rede ruim), 
					// nós o desconectamos para não travar o servidor inteiro.
					close(client.send)
					delete(h.Clients, client)
				}
			}
		}
	}
}