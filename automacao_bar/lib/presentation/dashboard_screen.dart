import 'package:flutter/material.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Visão Geral', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 1.1,
        ),
        itemCount: 10, // Mesas de exemplo
        itemBuilder: (context, index) {
          // Lógica fake para visualização: Mesa par está ocupada, ímpar está livre
          final isOccupied = index % 2 == 0; 
          
          return Container(
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isOccupied ? colorScheme.secondary : Colors.grey.withOpacity(0.2),
                width: isOccupied ? 2 : 1,
              ),
              boxShadow: isOccupied 
                ? [BoxShadow(color: colorScheme.secondary.withOpacity(0.3), blurRadius: 8, spreadRadius: 1)]
                : [],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.table_restaurant, 
                  size: 40, 
                  color: isOccupied ? colorScheme.secondary : Colors.grey.shade600
                ),
                const SizedBox(height: 12),
                Text(
                  'Mesa ${index + 1}', 
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                ),
                const SizedBox(height: 8),
                if (isOccupied)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: colorScheme.secondary.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      'Ocupada', 
                      style: TextStyle(color: colorScheme.secondary, fontWeight: FontWeight.bold, fontSize: 12),
                    ),
                  )
                else
                  const Text('Livre', style: TextStyle(color: Colors.grey, fontSize: 12)),
              ],
            ),
          );
        },
      ),
    );
  }
}