import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:automacao_bar/core/theme/app_colors.dart';
import 'package:automacao_bar/core/providers/repository_providers.dart';
import 'package:automacao_bar/core/database/app_database.dart';

final usersListProvider = StreamProvider.autoDispose<List<User>>((ref) {
  return ref.watch(userRepositoryProvider).watchUsers();
});

class UserListScreen extends ConsumerWidget {
  const UserListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final usersAsync = ref.watch(usersListProvider);

    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0F),
      appBar: AppBar(
        backgroundColor: const Color(0xFF12121A),
        title: Text(
          'CONTROLE DE ACESSO (CRUD)',
          style: GoogleFonts.shareTechMono(
            color: const Color(0xFF00FFFF),
            fontWeight: FontWeight.bold,
            letterSpacing: 1.5,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add, color: Color(0xFF39FF14)),
            onPressed: () => context.push('/cadastro'),
          )
        ],
      ),
      body: usersAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF39FF14)),
          ),
        ),
        error: (err, stack) => Center(
          child: Text(
            'Erro ao carregar: $err',
            style: GoogleFonts.shareTechMono(color: const Color(0xFFFF007F)),
          ),
        ),
        data: (users) {
          if (users.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Nenhum usuário cadastrado.',
                    style: GoogleFonts.shareTechMono(color: AppColors.textMuted),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF12121A),
                      foregroundColor: const Color(0xFF39FF14),
                      side: const BorderSide(color: Color(0xFF39FF14)),
                    ),
                    onPressed: () => context.push('/cadastro'),
                    child: Text('CADASTRAR PRIMEIRO', style: GoogleFonts.shareTechMono()),
                  )
                ],
              ),
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: users.length,
            separatorBuilder: (context, _) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final user = users[index];
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: const Color(0xFF12121A),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFF2A2A35)),
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: const Color(0xFF0A0A0F),
                      child: Text(
                        user.name.isNotEmpty ? user.name[0].toUpperCase() : 'U',
                        style: GoogleFonts.shareTechMono(color: const Color(0xFF00FFFF)),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            user.name,
                            style: GoogleFonts.shareTechMono(
                              color: AppColors.textMain,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: const Color(0xFF0A0A0F),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              user.role.toUpperCase(),
                              style: GoogleFonts.shareTechMono(
                                color: user.role == 'admin' ? const Color(0xFF39FF14) : const Color(0xFF8B91B5),
                                fontSize: 11,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.edit, color: Color(0xFF00FFFF)),
                      onPressed: () => context.push('/cadastro?id=${user.id}'),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete, color: Color(0xFFFF007F)),
                      onPressed: () async {
                        final confirm = await showDialog<bool>(
                          context: context,
                          builder: (ctx) => AlertDialog(
                            backgroundColor: const Color(0xFF12121A),
                            title: Text(
                              'DELETAR OPERADOR?',
                              style: GoogleFonts.shareTechMono(color: const Color(0xFFFF007F)),
                            ),
                            content: Text(
                              'Confirma a exclusão permanente de ${user.name}?',
                              style: GoogleFonts.shareTechMono(color: AppColors.textMain),
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(ctx, false),
                                child: Text('CANCELAR', style: GoogleFonts.shareTechMono(color: AppColors.textMuted)),
                              ),
                              TextButton(
                                onPressed: () => Navigator.pop(ctx, true),
                                child: Text('EXCLUIR', style: GoogleFonts.shareTechMono(color: const Color(0xFFFF007F))),
                              ),
                            ],
                          ),
                        );
                        if (confirm == true) {
                          await ref.read(userRepositoryProvider).deleteUser(user.id);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              backgroundColor: const Color(0xFF12121A),
                              content: Text(
                                'Usuário removido da base.',
                                style: GoogleFonts.shareTechMono(color: const Color(0xFFFF007F)),
                              ),
                            ),
                          );
                        }
                      },
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
