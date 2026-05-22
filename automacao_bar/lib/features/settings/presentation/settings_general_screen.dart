import 'package:flutter/material.dart';
import '../../../presentation/theme/app_colors.dart';

class SettingsGeneralScreen extends StatelessWidget {
  const SettingsGeneralScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text("Configurações Gerais"),
        backgroundColor: AppColors.surface,
      ),
      body: ListView(
        children: [
          _buildSectionTitle("Preferências de Interface"),
          ListTile(
            leading: const Icon(Icons.tune, color: AppColors.primaryNeon),
            title: const Text("Ajustes de Grid", style: TextStyle(color: Colors.white)),
            subtitle: const Text("Defina o tamanho dos cards das mesas", style: TextStyle(color: AppColors.textSecondary)),
            onTap: () {
              // Aqui você chamaria a tela do Slider que fizemos antes
            },
          ),
          
          _buildSectionTitle("Conta e Segurança"),
          ListTile(
            leading: const Icon(Icons.person_outline, color: Colors.white),
            title: const Text("Perfil do Operador", style: TextStyle(color: Colors.white)),
            onTap: () {},
          ),
          ListTile(
            leading: const Icon(Icons.security, color: Colors.white),
            title: const Text("Segurança e Tokens", style: TextStyle(color: Colors.white)),
            onTap: () {},
          ),
          
          _buildSectionTitle("Sistema"),
          ListTile(
            leading: const Icon(Icons.info_outline, color: Colors.white),
            title: const Text("Sobre o Sistema", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
      child: Text(title, style: const TextStyle(color: AppColors.primaryOrange, fontWeight: FontWeight.bold)),
    );
  }
}