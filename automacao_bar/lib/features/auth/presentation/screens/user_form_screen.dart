import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:uuid/uuid.dart';
import 'package:automacao_bar/core/theme/app_colors.dart';
import 'package:automacao_bar/core/providers/repository_providers.dart';
import 'package:automacao_bar/core/database/app_database.dart';
import 'package:automacao_bar/design_system/components/glass_container.dart';

class UserFormScreen extends ConsumerStatefulWidget {
  final String? userId;

  const UserFormScreen({super.key, this.userId});

  @override
  ConsumerState<UserFormScreen> createState() => _UserFormScreenState();
}

class _UserFormScreenState extends ConsumerState<UserFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _pinController = TextEditingController();
  String _selectedRole = 'waiter';
  bool _isEditing = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.userId != null) {
      _isEditing = true;
      _loadUser();
    }
  }

  Future<void> _loadUser() async {
    setState(() => _isLoading = true);
    final repo = ref.read(userRepositoryProvider);
    final user = await repo.getUserById(widget.userId!);
    if (user != null) {
      _nameController.text = user.name;
      _pinController.text = user.pinHash;
      setState(() {
        _selectedRole = user.role;
      });
    }
    setState(() => _isLoading = false);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _pinController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    try {
      final repo = ref.read(userRepositoryProvider);
      final name = _nameController.text.trim();
      final pin = _pinController.text.trim();

      if (_isEditing) {
        final updated = User(
          id: widget.userId!,
          name: name,
          pinHash: pin,
          role: _selectedRole,
          isActive: true,
          updatedAt: DateTime.now().millisecondsSinceEpoch,
        );
        await repo.updateUser(updated);
      } else {
        final inserted = User(
          id: const Uuid().v7(),
          name: name,
          pinHash: pin,
          role: _selectedRole,
          isActive: true,
          updatedAt: DateTime.now().millisecondsSinceEpoch,
        );
        await repo.insertUser(inserted);
      }

      if (mounted) {
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: const Color(0xFFFF007F),
            content: Text(
              'ERRO AO SALVAR USUÁRIO: $e',
              style: GoogleFonts.shareTechMono(color: Colors.white),
            ),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: const Color(0xFF020204),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0A0A0F),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF00FFFF)),
          onPressed: () => context.pop(),
        ),
        title: Text(
          _isEditing ? 'EDITAR CREDENCIAIS' : 'NOVO OPERADOR',
          style: GoogleFonts.shareTechMono(
            color: const Color(0xFF00FFFF),
            fontWeight: FontWeight.bold,
            letterSpacing: 2,
          ),
        ),
      ),
      body: Stack(
        children: [
          // Cyberpunk Background Glows
          Positioned(
            top: size.height * 0.1,
            right: -100,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF00FFFF).withOpacity(0.12),
                    blurRadius: 110.0,
                    spreadRadius: 55.0,
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            bottom: size.height * 0.1,
            left: -100,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFFF007F).withOpacity(0.12),
                    blurRadius: 110.0,
                    spreadRadius: 55.0,
                  ),
                ],
              ),
            ),
          ),

          _isLoading
              ? const Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF39FF14)),
                  ),
                )
              : Center(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                    child: Container(
                      constraints: const BoxConstraints(maxWidth: 420),
                      child: GlassContainer(
                        borderRadius: 24,
                        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 36),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Text(
                                _isEditing ? 'ATUALIZAÇÃO DE REGISTROS' : 'NOVA CREDENCIAL DE SISTEMA',
                                style: GoogleFonts.shareTechMono(
                                  color: const Color(0xFF8B91B5),
                                  fontSize: 11,
                                  letterSpacing: 1.5,
                                ),
                              ),
                              const SizedBox(height: 32),

                              // Name input
                              TextFormField(
                                controller: _nameController,
                                style: GoogleFonts.shareTechMono(color: Colors.white, fontSize: 16),
                                decoration: InputDecoration(
                                  labelText: 'Nome do Usuário',
                                  labelStyle: GoogleFonts.shareTechMono(color: const Color(0xFF8B91B5), fontSize: 13),
                                  prefixIcon: const Icon(Icons.person_outline, color: Color(0xFF00FFFF), size: 20),
                                  enabledBorder: OutlineInputBorder(
                                    borderSide: BorderSide(color: const Color(0xFF00FFFF).withOpacity(0.2)),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderSide: const BorderSide(color: Color(0xFF00FFFF), width: 1.5),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  errorBorder: OutlineInputBorder(
                                    borderSide: const BorderSide(color: Color(0xFFFF007F)),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  focusedErrorBorder: OutlineInputBorder(
                                    borderSide: const BorderSide(color: Color(0xFFFF007F), width: 1.5),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                validator: (val) =>
                                    val == null || val.trim().isEmpty ? 'Insira o nome' : null,
                              ),
                              const SizedBox(height: 24),

                              // PIN input
                              TextFormField(
                                controller: _pinController,
                                obscureText: true,
                                keyboardType: TextInputType.number,
                                style: GoogleFonts.shareTechMono(
                                  color: Colors.white,
                                  letterSpacing: 8,
                                  fontSize: 20,
                                ),
                                decoration: InputDecoration(
                                  labelText: 'Senha ou PIN',
                                  labelStyle: GoogleFonts.shareTechMono(color: const Color(0xFF8B91B5), fontSize: 13, letterSpacing: 0),
                                  prefixIcon: const Icon(Icons.lock_outline, color: Color(0xFF00FFFF), size: 20),
                                  enabledBorder: OutlineInputBorder(
                                    borderSide: BorderSide(color: const Color(0xFF00FFFF).withOpacity(0.2)),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderSide: const BorderSide(color: Color(0xFF00FFFF), width: 1.5),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  errorBorder: OutlineInputBorder(
                                    borderSide: const BorderSide(color: Color(0xFFFF007F)),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  focusedErrorBorder: OutlineInputBorder(
                                    borderSide: const BorderSide(color: Color(0xFFFF007F), width: 1.5),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                validator: (val) =>
                                    val == null || val.trim().isEmpty ? 'Insira a senha ou PIN' : null,
                              ),
                              const SizedBox(height: 24),

                              // Role dropdown
                              DropdownButtonFormField<String>(
                                initialValue: _selectedRole,
                                dropdownColor: const Color(0xFF0A0A0F),
                                decoration: InputDecoration(
                                  labelText: 'Função (Role)',
                                  labelStyle: GoogleFonts.shareTechMono(color: const Color(0xFF8B91B5), fontSize: 13),
                                  prefixIcon: const Icon(Icons.badge_outlined, color: Color(0xFF00FFFF), size: 20),
                                  enabledBorder: OutlineInputBorder(
                                    borderSide: BorderSide(color: const Color(0xFF00FFFF).withOpacity(0.2)),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderSide: const BorderSide(color: Color(0xFF00FFFF), width: 1.5),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                items: const [
                                  DropdownMenuItem(value: 'admin', child: Text('Administrador (admin)')),
                                  DropdownMenuItem(value: 'waiter', child: Text('Garçom (waiter)')),
                                  DropdownMenuItem(value: 'caixa', child: Text('Caixa (caixa)')),
                                  DropdownMenuItem(value: 'chef', child: Text('Cozinheiro (chef)')),
                                ],
                                onChanged: (val) {
                                  if (val != null) {
                                    setState(() => _selectedRole = val);
                                  }
                                },
                                style: GoogleFonts.shareTechMono(color: Colors.white, fontSize: 15),
                              ),
                              const SizedBox(height: 40),

                              // Save Button
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.transparent,
                                  foregroundColor: const Color(0xFF39FF14),
                                  shadowColor: const Color(0xFF39FF14).withOpacity(0.4),
                                  elevation: 8,
                                  padding: const EdgeInsets.symmetric(vertical: 18),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    side: const BorderSide(color: Color(0xFF39FF14), width: 1.8),
                                  ),
                                ),
                                onPressed: _save,
                                child: Text(
                                  'GRAVAR OPERADOR',
                                  style: GoogleFonts.shareTechMono(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 2,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
        ],
      ),
    );
  }
}
