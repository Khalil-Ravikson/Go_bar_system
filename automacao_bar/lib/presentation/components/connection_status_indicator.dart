import 'package:automacao_bar/design_system/theme/app_colors.dart';
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../../core/network/websocket_service.dart';
import 'jumping_dots.dart';

class ConnectionStatusIndicator extends StatelessWidget {
  final WebSocketStatus status;

  const ConnectionStatusIndicator({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    Color statusColor;
    String statusText;
    
    switch (status) {
      case WebSocketStatus.online:
        statusColor = AppColors.primaryNeon;
        statusText = "Online";
        break;
      case WebSocketStatus.connecting:
        statusColor = AppColors.primaryOrange;
        statusText = "Sincronizando"; // Tiramos os pontinhos estáticos do texto
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
        mainAxisSize: MainAxisSize.min,
        children: [
          if (status != WebSocketStatus.connecting) ...[
            Icon(Icons.circle, size: 8, color: statusColor),
            const SizedBox(width: 6),
          ],
          Text(
            statusText,
            style: TextStyle(
              color: statusColor,
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
          ),
          // Se estiver sincronizando, bota os pontinhos pulando logo após o texto
          if (status == WebSocketStatus.connecting) ...[
            const SizedBox(width: 2),
            JumpingDots(color: statusColor),
          ],
        ],
      ),
    );
  }
}