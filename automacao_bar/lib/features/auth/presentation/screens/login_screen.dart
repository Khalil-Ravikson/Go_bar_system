import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:automacao_bar/features/auth/application/auth_provider.dart';
import 'package:automacao_bar/design_system/components/glass_container.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _pinController = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _nameController.dispose();
    _pinController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final name = _nameController.text.trim();
    final pin = _pinController.text.trim();

    HapticFeedback.lightImpact();

    final success = await ref.read(authProvider.notifier).login(name, pin);

    if (mounted) {
      setState(() {
        _isLoading = false;
      });

      if (success) {
        HapticFeedback.heavyImpact();
      } else {
        HapticFeedback.vibrate();
        setState(() {
          _errorMessage = 'CREDENCIAL INCORRETA_';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: const Color(0xFF020204),
      body: Stack(
        children: [
          // Cyberpunk Background Glows
          Positioned(
            top: size.height * 0.1,
            left: -100,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF00FFFF).withOpacity(0.15),
                    blurRadius: 100.0,
                    spreadRadius: 50.0,
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            bottom: size.height * 0.1,
            right: -100,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFFF007F).withOpacity(0.12),
                    blurRadius: 120.0,
                    spreadRadius: 60.0,
                  ),
                ],
              ),
            ),
          ),

          // Tech Grid Overlay Pattern
          Opacity(
            opacity: 0.03,
            child: Container(
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: NetworkImage('https://images.unsplash.com/photo-1618005182384-a83a8bd57fbe?q=80&w=256&auto=format&fit=crop'),
                  repeat: ImageRepeat.repeat,
                ),
              ),
            ),
          ),

          // Main Content Area
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Container(
                  constraints: const BoxConstraints(maxWidth: 420),
                  child: GlassContainer(
                    borderRadius: 24,
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 48),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Glow logo symbol
                          Center(
                            child: Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(color: const Color(0xFF00FFFF).withOpacity(0.3), width: 1.5),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(0xFF00FFFF).withOpacity(0.1),
                                    blurRadius: 12,
                                    spreadRadius: 2,
                                  ),
                                ],
                              ),
                              child: const Icon(
                                Icons.local_bar_rounded,
                                color: Color(0xFF00FFFF),
                                size: 36,
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),

                          // System Header
                          Text(
                            'GOBAR_OS v2.0',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.shareTechMono(
                              color: const Color(0xFF00FFFF),
                              fontSize: 28,
                              letterSpacing: 3,
                              fontWeight: FontWeight.bold,
                              shadows: [
                                const Shadow(
                                  color: Color(0xFF00FFFF),
                                  blurRadius: 12,
                                )
                              ],
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'AUTENTICAÇÃO DE TERMINAL MÓVEL',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.shareTechMono(
                              color: const Color(0xFF8B91B5),
                              fontSize: 10,
                              letterSpacing: 2,
                            ),
                          ),
                          const SizedBox(height: 40),

                          // Operator Name field
                          TextFormField(
                            controller: _nameController,
                            style: GoogleFonts.shareTechMono(color: Colors.white, fontSize: 16),
                            decoration: InputDecoration(
                              labelText: 'NOME DO OPERADOR',
                              labelStyle: GoogleFonts.shareTechMono(color: const Color(0xFF8B91B5), fontSize: 12),
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
                                val == null || val.trim().isEmpty ? 'NOME REQUERIDO_' : null,
                          ),
                          const SizedBox(height: 24),

                          // PIN Input field
                          TextFormField(
                            controller: _pinController,
                            obscureText: true,
                            keyboardType: TextInputType.number,
                            style: GoogleFonts.shareTechMono(
                              color: Colors.white,
                              letterSpacing: 12,
                              fontSize: 22,
                            ),
                            decoration: InputDecoration(
                              labelText: 'SENHA OU PIN RESTRITO',
                              labelStyle: GoogleFonts.shareTechMono(color: const Color(0xFF8B91B5), fontSize: 12, letterSpacing: 0),
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
                                val == null || val.trim().isEmpty ? 'SENHA REQUERIDA_' : null,
                          ),
                          const SizedBox(height: 24),

                          // Error text
                          if (_errorMessage != null) ...[
                            Text(
                              _errorMessage!,
                              textAlign: TextAlign.center,
                              style: GoogleFonts.shareTechMono(
                                color: const Color(0xFFFF007F),
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                                letterSpacing: 1,
                              ),
                            ),
                            const SizedBox(height: 20),
                          ],

                          // Login Button
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.transparent,
                              foregroundColor: const Color(0xFF39FF14),
                              surfaceTintColor: Colors.transparent,
                              shadowColor: const Color(0xFF39FF14).withOpacity(0.4),
                              elevation: 8,
                              padding: const EdgeInsets.symmetric(vertical: 18),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                                side: const BorderSide(color: Color(0xFF39FF14), width: 1.8),
                              ),
                            ),
                            onPressed: _isLoading ? null : _submit,
                            child: _isLoading
                                ? const SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF39FF14)),
                                    ),
                                  )
                                : Text(
                                    'ENTRAR NO SISTEMA',
                                    style: GoogleFonts.shareTechMono(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 2,
                                    ),
                                  ),
                          ),
                          const SizedBox(height: 24),

                          // Go to registration button
                          TextButton(
                            onPressed: () => context.push('/cadastro'),
                            style: TextButton.styleFrom(
                              foregroundColor: const Color(0xFF00FFFF),
                            ),
                            child: Text(
                              'CADASTRAR NOVO OPERADOR_ [SYS_REG]',
                              style: GoogleFonts.shareTechMono(
                                fontSize: 13,
                                decoration: TextDecoration.underline,
                                decorationColor: const Color(0xFF00FFFF),
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
          ),
        ],
      ),
    );
  }
}
