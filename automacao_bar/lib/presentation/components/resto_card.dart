import 'package:automacao_bar/core/theme/app_colors.dart';
import 'package:flutter/material.dart';

class RestoCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String status;
  final String syncStatus;
  final Color statusColor;
  final VoidCallback onTap;

  const RestoCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.status,
    required this.syncStatus, // 1. Erro corrigido: Adicionado ao construtor
    required this.statusColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface, // Cinza Escuro Premium
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.surfaceHighlight), // Borda sutil
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(color: AppColors.textPrimary, fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text(subtitle, style: const TextStyle(color: AppColors.textSecondary, fontSize: 14)),
                ],
              ),
            ),
            
            // 2. Erro corrigido: O ícone agora vive DENTRO do Row
            Icon(
              syncStatus == 'SYNCED' ? Icons.cloud_done : Icons.cloud_upload,
              color: syncStatus == 'SYNCED' ? AppColors.primaryNeon : AppColors.orange,
              size: 20,
            ),
            
            const SizedBox(width: 12), // Espaçamento elegante entre a nuvem e o status
            
            // Badge de Status com borda neon ou laranja
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: statusColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: statusColor),
              ),
              child: Text(
                status,
                style: TextStyle(color: statusColor, fontWeight: FontWeight.bold, fontSize: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }
}