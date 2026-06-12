import 'package:flutter/material.dart';
import 'package:automacao_bar/core/theme/app_colors.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _darkThemeEnabled = true;
  bool _notificationsEnabled = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Configurações'),
        backgroundColor: AppColors.surface,
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: ListView(
            padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 24.0),
            children: [
              _buildSectionHeader('Preferências Visuais'),
              
              // Dark Theme Toggle
              SwitchListTile.adaptive(
                title: const Text(
                  'Modo Escuro (Neon)',
                  style: TextStyle(color: AppColors.textMain, fontWeight: FontWeight.w600),
                ),
                subtitle: const Text(
                  'Ativar visual escuro com destaques neon',
                  style: TextStyle(color: AppColors.textMuted),
                ),
                value: _darkThemeEnabled,
                activeThumbColor: AppColors.neonGreen,
                activeTrackColor: AppColors.neonGreen.withValues(alpha: 0.2),
                onChanged: (bool value) {
                  setState(() {
                    _darkThemeEnabled = value;
                  });
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(value ? 'Tema escuro ativado!' : 'Tema padrão ativado!'),
                      duration: const Duration(seconds: 1),
                    ),
                  );
                },
              ),
              
              const Divider(),
              
              _buildSectionHeader('Sincronização & Dados'),
              
              // Sync Status
              ListTile(
                title: const Text(
                  'Status de Sincronização',
                  style: TextStyle(color: AppColors.textMain, fontWeight: FontWeight.w600),
                ),
                subtitle: const Text(
                  'Última sincronização: Há 2 minutos',
                  style: TextStyle(color: AppColors.textMuted),
                ),
                trailing: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.neonGreen.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppColors.neonGreen, width: 1),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.cloud_done, color: AppColors.neonGreen, size: 14),
                      SizedBox(width: 6),
                      Text(
                        'Sincronizado',
                        style: TextStyle(
                          color: AppColors.neonGreen,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Forçando sincronização de dados...'),
                      backgroundColor: AppColors.surfaceLight,
                    ),
                  );
                },
              ),
              
              // Clear Cache
              ListTile(
                title: const Text(
                  'Limpar Cache Local',
                  style: TextStyle(color: AppColors.textMain, fontWeight: FontWeight.w600),
                ),
                subtitle: const Text(
                  'Espaço ocupado: 12.4 MB',
                  style: TextStyle(color: AppColors.textMuted),
                ),
                trailing: IconButton(
                  icon: const Icon(Icons.delete_outline, color: AppColors.danger),
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        backgroundColor: AppColors.surface,
                        title: const Text(
                          'Limpar Cache?',
                          style: TextStyle(color: AppColors.textMain),
                        ),
                        content: const Text(
                          'Isso apagará logs de depuração locais e imagens em cache temporário. Dados da comanda offline não serão excluídos.',
                          style: TextStyle(color: AppColors.textMuted),
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(),
                            child: const Text('Cancelar', style: TextStyle(color: AppColors.textMuted)),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    'Cache local limpo com sucesso!',
                                    style: TextStyle(color: Colors.black),
                                  ),
                                  backgroundColor: AppColors.neonGreen,
                                ),
                              );
                            },
                            child: const Text('Confirmar', style: TextStyle(color: AppColors.danger, fontWeight: FontWeight.bold)),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
              
              const Divider(),
              
              _buildSectionHeader('Notificações'),
              
              // Toggle Notifications
              SwitchListTile.adaptive(
                title: const Text(
                  'Alertas de Pedido',
                  style: TextStyle(color: AppColors.textMain, fontWeight: FontWeight.w600),
                ),
                subtitle: const Text(
                  'Notificar quando novos pedidos forem entregues pela cozinha',
                  style: TextStyle(color: AppColors.textMuted),
                ),
                value: _notificationsEnabled,
                activeThumbColor: AppColors.neonGreen,
                activeTrackColor: AppColors.neonGreen.withValues(alpha: 0.2),
                onChanged: (bool value) {
                  setState(() {
                    _notificationsEnabled = value;
                  });
                },
              ),
              
              const Divider(),
              
              _buildSectionHeader('Sistema'),
              
              const ListTile(
                title: Text(
                  'Versão do Aplicativo',
                  style: TextStyle(color: AppColors.textMain, fontWeight: FontWeight.w600),
                ),
                subtitle: Text(
                  'v1.0.0 (Build 26)',
                  style: TextStyle(color: AppColors.textMuted),
                ),
                trailing: Text(
                  'GoBar System',
                  style: TextStyle(color: AppColors.neonGreen, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 16.0),
      child: Text(
        title.toUpperCase(),
        style: const TextStyle(
          color: AppColors.neonGreen,
          fontSize: 12,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.5,
        ),
      ),
    );
  }
}
