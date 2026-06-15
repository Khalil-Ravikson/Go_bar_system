import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:automacao_bar/core/theme/app_colors.dart';
import 'package:automacao_bar/features/auth/application/auth_provider.dart';
import 'package:automacao_bar/features/sync/application/sync_provider.dart';
import 'package:automacao_bar/features/printer/application/printer_provider.dart';
import 'package:automacao_bar/features/printer/presentation/widgets/thermal_receipt_preview.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  bool _darkThemeEnabled = true;
  bool _notificationsEnabled = true;

  String _formatTime(DateTime dateTime) {
    final hours = dateTime.hour.toString().padLeft(2, '0');
    final minutes = dateTime.minute.toString().padLeft(2, '0');
    final seconds = dateTime.second.toString().padLeft(2, '0');
    return '$hours:$minutes:$seconds';
  }

  Widget _buildSyncStatusBadge(SyncState syncState) {
    if (syncState.isSyncing) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.blue.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.blue, width: 1),
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 10,
              height: 10,
              child: CircularProgressIndicator(
                strokeWidth: 1.5,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
              ),
            ),
            SizedBox(width: 6),
            Text(
              'Enviando...',
              style: TextStyle(
                color: Colors.blue,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      );
    }
    
    if (!syncState.isOnline) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: AppColors.danger.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.danger, width: 1),
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.cloud_off, color: AppColors.danger, size: 14),
            SizedBox(width: 6),
            Text(
              'Offline',
              style: TextStyle(
                color: AppColors.danger,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      );
    }

    return Container(
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
    );
  }

  @override
  Widget build(BuildContext context) {
    final session = ref.watch(authProvider);
    final syncState = ref.watch(syncProvider);
    final printerState = ref.watch(printerProvider);

    if (session == null) return const Center(child: CircularProgressIndicator());
    final isGuest = session.role == UserRole.guest;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: CustomScrollView(
            slivers: [
              SliverAppBar(
                pinned: true,
                expandedHeight: 120,
                backgroundColor: AppColors.surface,
                elevation: 0,
                flexibleSpace: const FlexibleSpaceBar(
                  titlePadding: EdgeInsetsDirectional.only(start: 24, bottom: 16),
                  title: Text(
                    'Configurações',
                    style: TextStyle(
                      color: AppColors.textMain,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([

              _buildSectionHeader('Controle de Acesso (RBAC)'),
              
              if (isGuest) ...[
                ListTile(
                  title: const Text(
                    'Fazer Login para Backup na Nuvem',
                    style: TextStyle(color: AppColors.neonGreen, fontWeight: FontWeight.bold),
                  ),
                  subtitle: const Text(
                    'Você está navegando localmente. Faça login para habilitar sincronização.',
                    style: TextStyle(color: AppColors.textMuted),
                  ),
                  trailing: const Icon(Icons.cloud_upload_outlined, color: AppColors.neonGreen),
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (ctx) {
                        final pinController = TextEditingController();
                        return AlertDialog(
                          backgroundColor: AppColors.surface,
                          title: const Text('Identifique-se', style: TextStyle(color: AppColors.textMain)),
                          content: TextField(
                            controller: pinController,
                            keyboardType: TextInputType.number,
                            obscureText: true,
                            maxLength: 4,
                            textAlign: TextAlign.center,
                            style: const TextStyle(color: AppColors.textMain, fontSize: 24, letterSpacing: 8),
                            decoration: const InputDecoration(
                              hintText: '••••',
                              counterText: '',
                            ),
                            onChanged: (val) async {
                              if (val.length == 4) {
                                final success = await ref.read(authProvider.notifier).loginByPin(val);
                                if (success) {
                                  if (ctx.mounted) Navigator.pop(ctx);
                                } else {
                                  if (ctx.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(content: Text('PIN inválido'), backgroundColor: AppColors.danger),
                                    );
                                    pinController.clear();
                                  }
                                }
                              }
                            },
                          ),
                        );
                      },
                    );
                  },
                ),
              ] else ...[
                // Role Selection
                ListTile(
                  title: const Text(
                    'Perfil / Cargo de Usuário',
                    style: TextStyle(color: AppColors.textMain, fontWeight: FontWeight.w600),
                  ),
                  subtitle: Text(
                    'Nome: ${session.name}\nCargo: ${session.role.name.toUpperCase()}',
                    style: const TextStyle(color: AppColors.textMuted),
                  ),
                  trailing: DropdownButton<UserRole>(
                    value: session.role,
                    dropdownColor: AppColors.surfaceLight,
                    style: const TextStyle(color: AppColors.textMain),
                    underline: Container(),
                    icon: const Icon(Icons.arrow_drop_down, color: AppColors.neonGreen),
                    onChanged: (UserRole? newRole) {
                      if (newRole != null) {
                        ref.read(authProvider.notifier).changeRole(newRole);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'Cargo alterado para ${newRole.name.toUpperCase()}!',
                              style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
                            ),
                            backgroundColor: AppColors.neonGreen,
                            duration: const Duration(seconds: 2),
                          ),
                        );
                      }
                    },
                    items: const [
                      DropdownMenuItem(
                        value: UserRole.admin,
                        child: Text('Administrador'),
                      ),
                      DropdownMenuItem(
                        value: UserRole.waiter,
                        child: Text('Garçom'),
                      ),
                      DropdownMenuItem(
                        value: UserRole.chef,
                        child: Text('Cozinheiro'),
                      ),
                    ],
                  ),
                ),
              ],

              const Divider(color: AppColors.surfaceLight),

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
              
              const Divider(color: AppColors.surfaceLight),
              
              if (!isGuest) ...[
                _buildSectionHeader('Sincronização & Dados'),

                // Simulated Connectivity Switch
                SwitchListTile.adaptive(
                  title: const Text(
                    'Modo Conectado (Online)',
                    style: TextStyle(color: AppColors.textMain, fontWeight: FontWeight.w600),
                  ),
                  subtitle: Text(
                    syncState.isOnline
                        ? 'Conexão ativa com o servidor Go'
                        : 'Modo Offline (eventos acumulando no Outbox)',
                    style: const TextStyle(color: AppColors.textMuted),
                  ),
                  value: syncState.isOnline,
                  activeThumbColor: AppColors.neonGreen,
                  activeTrackColor: AppColors.neonGreen.withValues(alpha: 0.2),
                  onChanged: (bool value) {
                    ref.read(syncProvider.notifier).toggleConnectivity();
                  },
                ),
                
                // Sync Status
                ListTile(
                  title: const Text(
                    'Fila de Sincronização (Outbox)',
                    style: TextStyle(color: AppColors.textMain, fontWeight: FontWeight.w600),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Eventos pendentes: ${syncState.pendingCount}',
                        style: const TextStyle(color: AppColors.textMuted),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        syncState.lastSyncedTime != null
                            ? 'Última sincronização: ${_formatTime(syncState.lastSyncedTime!)}'
                            : 'Última sincronização: Nunca',
                        style: const TextStyle(color: AppColors.textMuted, fontSize: 12),
                      ),
                    ],
                  ),
                  trailing: _buildSyncStatusBadge(syncState),
                  onTap: syncState.isOnline && syncState.pendingCount > 0 && !syncState.isSyncing
                      ? () {
                          ref.read(syncProvider.notifier).triggerManualSync();
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Iniciando sincronização forçada...'),
                              backgroundColor: AppColors.surfaceLight,
                            ),
                          );
                        }
                      : null,
                ),
                const Divider(color: AppColors.surfaceLight),
              ],
              
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

              const Divider(color: AppColors.surfaceLight),

              _buildSectionHeader('Impressão & Periféricos'),

              // Default Printer selection
              ListTile(
                title: const Text(
                  'Impressora Bluetooth Ativa',
                  style: TextStyle(color: AppColors.textMain, fontWeight: FontWeight.w600),
                ),
                subtitle: Text(
                  printerState.selectedPrinter ?? 'Nenhuma impressora selecionada',
                  style: const TextStyle(color: AppColors.textMuted),
                ),
                trailing: printerState.isScanning
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.0,
                          valueColor: AlwaysStoppedAnimation<Color>(AppColors.neonGreen),
                        ),
                      )
                    : DropdownButton<String>(
                        value: printerState.selectedPrinter,
                        dropdownColor: AppColors.surfaceLight,
                        style: const TextStyle(color: AppColors.textMain),
                        underline: Container(),
                        icon: const Icon(Icons.arrow_drop_down, color: AppColors.neonGreen),
                        onChanged: (String? name) {
                          if (name != null) {
                            ref.read(printerProvider.notifier).connectPrinter(name);
                          }
                        },
                        items: printerState.availablePrinters.map((name) {
                          return DropdownMenuItem(
                            value: name,
                            child: Text(name.split(' ')[0]),
                          );
                        }).toList(),
                      ),
              ),

              // Scan button
              ListTile(
                title: const Text(
                  'Buscar Novas Impressoras',
                  style: TextStyle(color: AppColors.textMain, fontSize: 14),
                ),
                trailing: const Icon(Icons.refresh, color: AppColors.neonGreen),
                onTap: printerState.isScanning
                    ? null
                    : () {
                        ref.read(printerProvider.notifier).scanPrinters();
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Buscando dispositivos Bluetooth próximos...'),
                            duration: Duration(seconds: 1),
                          ),
                        );
                      },
              ),

              // Paper Width setting
              ListTile(
                title: const Text(
                  'Tamanho do Papel (Largura)',
                  style: TextStyle(color: AppColors.textMain, fontWeight: FontWeight.w600),
                ),
                subtitle: Text(
                  printerState.paperWidth == PaperWidth.width80mm ? '80mm (Padrão Caixa)' : '58mm (Portátil)',
                  style: const TextStyle(color: AppColors.textMuted),
                ),
                trailing: Switch(
                  value: printerState.paperWidth == PaperWidth.width80mm,
                  activeThumbColor: AppColors.neonGreen,
                  activeTrackColor: AppColors.neonGreen.withValues(alpha: 0.2),
                  onChanged: (bool is80mm) {
                    ref.read(printerProvider.notifier).setPaperWidth(
                          is80mm ? PaperWidth.width80mm : PaperWidth.width58mm,
                        );
                  },
                ),
              ),

              // Print Test Cupom
              ListTile(
                title: const Text(
                  'Imprimir Cupom de Teste',
                  style: TextStyle(color: AppColors.textMain, fontWeight: FontWeight.w600),
                ),
                subtitle: const Text(
                  'Simular via de conferência de teste na impressora ativa',
                  style: TextStyle(color: AppColors.textMuted),
                ),
                trailing: const Icon(Icons.print_outlined, color: AppColors.neonGreen),
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (context) => ThermalReceiptPreview(
                      tableNumber: 'TESTE',
                      preparingItems: const [
                        {'name': 'Item Teste 58/80mm', 'quantity': 1, 'price': 10.0}
                      ],
                      deliveredItems: const [],
                      subtotal: 10.0,
                      serviceTax: 1.0,
                      total: 11.0,
                      paperWidth: printerState.paperWidth,
                    ),
                  );
                },
              ),
              
              const Divider(color: AppColors.surfaceLight),
              
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
              
              const Divider(color: AppColors.surfaceLight),
              
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
              const Divider(color: AppColors.surfaceLight),
              ListTile(
                title: const Text(
                  'Encerrar Sessão',
                  style: TextStyle(color: AppColors.danger, fontWeight: FontWeight.w600),
                ),
                subtitle: const Text(
                  'Fazer logout do usuário atual',
                  style: TextStyle(color: AppColors.textMuted),
                ),
                trailing: const Icon(Icons.logout, color: AppColors.danger),
                onTap: () {
                  ref.read(authProvider.notifier).logout();
                },
              ),
                  ]),
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
