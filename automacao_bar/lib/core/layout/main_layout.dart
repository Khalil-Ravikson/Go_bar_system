import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';
import '../../features/auth/application/auth_provider.dart';
import '../../core/database/app_database.dart';
import '../../core/database/database_provider.dart';
import '../../core/providers/repository_providers.dart';
import '../../features/cash_register/application/cash_register_provider.dart';
import '../../core/theme/app_colors.dart' as theme_colors;

import '../../design_system/colors.dart';
import '../../design_system/components/premium_bottom_app_bar.dart';

class NavigationItem {
  final String path;
  final IconData icon;
  final IconData selectedIcon;
  final String label;

  const NavigationItem({
    required this.path,
    required this.icon,
    required this.selectedIcon,
    required this.label,
  });
}

// Maximum 3 visible tabs on bottom nav as per spec:
// Admin: Início (Dashboard), Mesas (PDV), Perfil (Config)
// Waiter: Mesas (PDV), Perfil (Config)
// Caixa: Mesas (PDV), Perfil (Config)
const List<NavigationItem> _adminNavItems = [
  NavigationItem(
    path: '/home/dashboard',
    icon: Icons.analytics_outlined,
    selectedIcon: Icons.analytics,
    label: 'Início',
  ),
  NavigationItem(
    path: '/home/pdv',
    icon: Icons.table_restaurant_outlined,
    selectedIcon: Icons.table_restaurant,
    label: 'Mesas',
  ),
  NavigationItem(
    path: '/home/config',
    icon: Icons.settings_outlined,
    selectedIcon: Icons.settings,
    label: 'Configurações',
  ),
];

const List<NavigationItem> _waiterNavItems = [
  NavigationItem(
    path: '/home/pdv',
    icon: Icons.table_restaurant_outlined,
    selectedIcon: Icons.table_restaurant,
    label: 'Mesas',
  ),
  NavigationItem(
    path: '/home/config',
    icon: Icons.settings_outlined,
    selectedIcon: Icons.settings,
    label: 'Configurações',
  ),
];

class MainLayout extends ConsumerWidget {
  final Widget child;

  const MainLayout({super.key, required this.child});

  void _showNovaComandaDialog(BuildContext context, WidgetRef ref) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: theme_colors.AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Nova Comanda', style: TextStyle(color: theme_colors.AppColors.textMain, fontWeight: FontWeight.bold)),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          style: const TextStyle(color: theme_colors.AppColors.textMain),
          decoration: const InputDecoration(
            labelText: 'Número da Mesa',
            labelStyle: TextStyle(color: theme_colors.AppColors.textMuted),
            enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: theme_colors.AppColors.surfaceLight)),
            focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: theme_colors.AppColors.neonGreen)),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar', style: TextStyle(color: theme_colors.AppColors.textMuted)),
          ),
          TextButton(
            onPressed: () async {
              final number = int.tryParse(controller.text.trim());
              if (number == null || number <= 0) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Insira um número de mesa válido.')),
                );
                return;
              }
              Navigator.pop(context);

              try {
                final tableRepo = ref.read(tableRepositoryProvider);
                final tablesList = await tableRepo.watchTables().first;
                final exists = tablesList.any((t) => t.number == number);
                if (!exists) {
                  await tableRepo.insertTable(
                    RestaurantTable(
                      id: const Uuid().v7(),
                      number: number,
                      status: 'livre',
                      x: 120.0,
                      y: 120.0,
                      capacity: 4,
                      updatedAt: DateTime.now().millisecondsSinceEpoch,
                    ),
                  );
                }

                if (context.mounted) {
                  context.push('/table-details?table=$number');
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Erro ao criar comanda: $e'), backgroundColor: Colors.red),
                  );
                }
              }
            },
            child: const Text('Criar', style: TextStyle(color: theme_colors.AppColors.neonGreen, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  void _showNovoUsuarioDialog(BuildContext context, WidgetRef ref) {
    final nameController = TextEditingController();
    final pinController = TextEditingController();
    UserRole selectedRole = UserRole.waiter;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          backgroundColor: theme_colors.AppColors.surface,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text('Novo Usuário', style: TextStyle(color: theme_colors.AppColors.textMain, fontWeight: FontWeight.bold)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  style: const TextStyle(color: theme_colors.AppColors.textMain),
                  decoration: const InputDecoration(
                    labelText: 'Nome do Funcionário',
                    labelStyle: TextStyle(color: theme_colors.AppColors.textMuted),
                    enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: theme_colors.AppColors.surfaceLight)),
                    focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: theme_colors.AppColors.neonGreen)),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: pinController,
                  keyboardType: TextInputType.number,
                  obscureText: true,
                  style: const TextStyle(color: theme_colors.AppColors.textMain),
                  decoration: const InputDecoration(
                    labelText: 'Código PIN (4 dígitos)',
                    labelStyle: TextStyle(color: theme_colors.AppColors.textMuted),
                    enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: theme_colors.AppColors.surfaceLight)),
                    focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: theme_colors.AppColors.neonGreen)),
                  ),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<UserRole>(
                  initialValue: selectedRole,
                  dropdownColor: theme_colors.AppColors.surface,
                  style: const TextStyle(color: theme_colors.AppColors.textMain),
                  decoration: const InputDecoration(
                    labelText: 'Cargo',
                    labelStyle: TextStyle(color: theme_colors.AppColors.textMuted),
                  ),
                  items: UserRole.values.map((role) {
                    return DropdownMenuItem<UserRole>(
                      value: role,
                      child: Text(role.name.toUpperCase(), style: const TextStyle(color: theme_colors.AppColors.textMain)),
                    );
                  }).toList(),
                  onChanged: (val) {
                    if (val != null) setState(() => selectedRole = val);
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar', style: TextStyle(color: theme_colors.AppColors.textMuted)),
            ),
            TextButton(
              onPressed: () async {
                final name = nameController.text.trim();
                final pin = pinController.text.trim();
                if (name.isEmpty || pin.length < 4) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Insira o nome e um PIN de 4 dígitos.')),
                  );
                  return;
                }
                Navigator.pop(context);

                try {
                  final db = ref.read(databaseProvider);
                  await db.into(db.users).insert(
                    User(
                      id: const Uuid().v7(),
                      name: name,
                      pinHash: pin,
                      role: selectedRole.name,
                      isActive: true,
                      updatedAt: DateTime.now().millisecondsSinceEpoch,
                    ),
                  );

                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Usuário $name cadastrado com sucesso!'),
                        backgroundColor: theme_colors.AppColors.neonGreen,
                      ),
                    );
                  }
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Erro ao criar usuário: $e'), backgroundColor: Colors.red),
                    );
                  }
                }
              },
              child: const Text('Cadastrar', style: TextStyle(color: theme_colors.AppColors.neonGreen, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }

  void _showRegistrarDespesaDialog(BuildContext context, WidgetRef ref) {
    final amountController = TextEditingController();
    final reasonController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: theme_colors.AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Registrar Despesa', style: TextStyle(color: theme_colors.AppColors.textMain, fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: amountController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              style: const TextStyle(color: theme_colors.AppColors.textMain),
              decoration: const InputDecoration(
                labelText: 'Valor (R\$)',
                labelStyle: TextStyle(color: theme_colors.AppColors.textMuted),
                enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: theme_colors.AppColors.surfaceLight)),
                focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: theme_colors.AppColors.neonGreen)),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: reasonController,
              style: const TextStyle(color: theme_colors.AppColors.textMain),
              decoration: const InputDecoration(
                labelText: 'Motivo / Descrição',
                labelStyle: TextStyle(color: theme_colors.AppColors.textMuted),
                enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: theme_colors.AppColors.surfaceLight)),
                focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: theme_colors.AppColors.neonGreen)),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar', style: TextStyle(color: theme_colors.AppColors.textMuted)),
          ),
          TextButton(
            onPressed: () {
              final amount = double.tryParse(amountController.text.trim()) ?? 0.0;
              final reason = reasonController.text.trim();
              if (amount <= 0 || reason.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Insira um valor e motivo válidos.')),
                );
                return;
              }
              Navigator.pop(context);

              try {
                final session = ref.read(authProvider);
                if (session == null) return;
                final cashNotifier = ref.read(cashRegisterProvider.notifier);
                final cashState = ref.read(cashRegisterProvider);

                if (!cashState.isOpen) {
                  cashNotifier.openRegister(0.0, 'Abertura automática para despesa', session.name);
                }

                cashNotifier.addTransaction(
                  amount: amount,
                  type: CashTransactionType.sangria,
                  reason: reason,
                  user: session.name,
                );

                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Despesa de R\$ ${amount.toStringAsFixed(2)} registrada com sucesso!'),
                      backgroundColor: theme_colors.AppColors.neonGreen,
                    ),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Erro ao registrar despesa: $e'), backgroundColor: Colors.red),
                  );
                }
              }
            },
            child: const Text('Registrar', style: TextStyle(color: theme_colors.AppColors.neonGreen, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(authProvider);
    final userRole = session?.role;

    final isAdmin = userRole == UserRole.admin;
    final isCaixa = userRole == UserRole.caixa;
    final isWaiter = userRole == UserRole.waiter;
    final isGuest = userRole == UserRole.guest;
    
    final visibleItems = (isAdmin || isGuest) ? _adminNavItems : _waiterNavItems;

    // Determine current index
    final String location = GoRouterState.of(context).uri.toString();
    int selectedIndex = 0;
    for (int i = 0; i < visibleItems.length; i++) {
      if (location.startsWith(visibleItems[i].path)) {
        selectedIndex = i;
        break;
      }
    }

    final isDesktop = MediaQuery.of(context).size.width > 800;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Actions for the Central FAB based on Role
    List<PremiumSpeedDialAction> getSpeedDialActions() {
      if (isAdmin || isGuest) {
        return [
          PremiumSpeedDialAction(
            icon: Icons.receipt,
            label: 'Nova Comanda',
            onPressed: () => _showNovaComandaDialog(context, ref),
          ),
          PremiumSpeedDialAction(
            icon: Icons.person_add,
            label: 'Novo Usuário',
            onPressed: () => _showNovoUsuarioDialog(context, ref),
          ),
          PremiumSpeedDialAction(
            icon: Icons.trending_down,
            label: 'Registrar Despesa',
            onPressed: () => _showRegistrarDespesaDialog(context, ref),
          ),
        ];
      } else if (isWaiter) {
        return [
          PremiumSpeedDialAction(
            icon: Icons.receipt,
            label: 'Nova Comanda',
            onPressed: () => _showNovaComandaDialog(context, ref),
          ),
        ];
      } else if (isCaixa) {
        return [
          PremiumSpeedDialAction(
            icon: Icons.monetization_on,
            label: 'Receber Pagamento',
            onPressed: () {},
          ),
        ];
      }
      return [];
    }

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      appBar: AppBar(
        title: const Text('BarSystem SaaS'),
        actions: [
          IconButton(
            icon: const Icon(Icons.cloud_done, color: Colors.green),
            onPressed: () {},
          ),
        ],
      ),
      drawer: (isAdmin || isGuest)
          ? Drawer(
              backgroundColor: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  DrawerHeader(
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.15),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        CircleAvatar(
                          backgroundColor: AppColors.primary,
                          radius: 28,
                          child: const Icon(Icons.admin_panel_settings, color: Colors.black, size: 28),
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          'Painel de Gestão',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                        Text(
                          'Administrador',
                          style: TextStyle(
                            fontSize: 12,
                            color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                          ),
                        ),
                      ],
                    ),
                  ),
                   ListTile(
                    leading: const Icon(Icons.restaurant_menu),
                    title: const Text('Gestão de Cardápio'),
                    onTap: () {
                      Navigator.pop(context);
                      context.push('/drawer/cardapio');
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.inventory_2_outlined),
                    title: const Text('Controle de Estoque'),
                    onTap: () {
                      Navigator.pop(context);
                      context.push('/drawer/estoque');
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.people_outline),
                    title: const Text('Gestão de Usuários'),
                    onTap: () {
                      Navigator.pop(context);
                      context.push('/usuarios');
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.analytics_outlined),
                    title: const Text('Relatórios de Fechamento'),
                    onTap: () {
                      Navigator.pop(context);
                      context.push('/drawer/relatorio');
                    },
                  ),
                ],
              ),
            )
          : null,
      body: Row(
        children: [
          if (isDesktop)
            NavigationRail(
              backgroundColor: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
              selectedIndex: selectedIndex,
              onDestinationSelected: (idx) {
                context.go(visibleItems[idx].path);
              },
              selectedIconTheme: const IconThemeData(color: AppColors.primary),
              unselectedIconTheme: IconThemeData(color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight),
              selectedLabelTextStyle: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold),
              unselectedLabelTextStyle: TextStyle(color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight),
              labelType: NavigationRailLabelType.all,
              destinations: visibleItems.map((item) {
                return NavigationRailDestination(
                  icon: Icon(item.icon),
                  selectedIcon: Icon(item.selectedIcon),
                  label: Text(item.label),
                );
              }).toList(),
            ),
          
          if (isDesktop) VerticalDivider(thickness: 1, width: 1, color: isDark ? AppColors.borderDark : AppColors.borderLight),
          
          Expanded(child: child),
        ],
      ),
      bottomNavigationBar: isDesktop 
        ? null 
        : PremiumBottomAppBar(
            currentIndex: selectedIndex,
            onTap: (idx) => context.go(visibleItems[idx].path),
            items: visibleItems.map((item) {
              return PremiumNavItem(
                icon: item.icon,
                selectedIcon: item.selectedIcon,
                label: item.label,
              );
            }).toList(),
            speedDialActions: getSpeedDialActions(),
          ),
    );
  }
}