import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../../core/network/websocket_service.dart';

class ConnectionStatusIndicator extends StatelessWidget {
  final WebSocketStatus status; // Agora recebe o Enum!

  const ConnectionStatusIndicator({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    Color statusColor;
    String statusText;
    
    // Lógica da Máquina de Estados
    switch (status) {
      case WebSocketStatus.online:
        statusColor = AppColors.primaryNeon;
        statusText = "Online";
        break;
      case WebSocketStatus.connecting:
        statusColor = AppColors.primaryOrange;
        statusText = "Sincronizando...";
        break;
      case WebSocketStatus.offline:
        statusColor = AppColors.error;
        statusText = "Offline";
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: statusColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          // Se estiver conectando, mostra um ícone de "carregando" pequeno
          if (status == WebSocketStatus.connecting)
            SizedBox(
              width: 10,
              height: 10,
              child: CircularProgressIndicator(strokeWidth: 2, color: statusColor),
            )
          else
            Icon(Icons.circle, size: 8, color: statusColor),
            
          const SizedBox(width: 6),
          Text(
            statusText,
            style: TextStyle(
              color: statusColor,
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}