import 'package:flutter/material.dart';

class JumpingDots extends StatefulWidget {
  final Color color;
  const JumpingDots({super.key, required this.color});

  @override
  State<JumpingDots> createState() => _JumpingDotsState();
}

class _JumpingDotsState extends State<JumpingDots> with TickerProviderStateMixin {
  late List<AnimationController> _controllers;
  final List<Animation<double>> _animations = [];
  final int _dotCount = 3;

  @override
  void initState() {
    super.initState();
    _controllers = List.generate(
      _dotCount,
      (index) => AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 300),
      ),
    );

    for (int i = 0; i < _dotCount; i++) {
      _animations.add(
        Tween<double>(begin: 0, end: -4).animate(
          CurvedAnimation(parent: _controllers[i], curve: Curves.easeInOut),
        ),
      );

      // Cria o efeito cascata (sequência de pulo)
      Future.delayed(Duration(milliseconds: i * 150), () {
        if (mounted) {
          _controllers[i].repeat(reverse: true);
        }
      });
    }
  }

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(_dotCount, (index) {
        return AnimatedBuilder(
          animation: _controllers[index],
          builder: (context, child) {
            return Transform.translate(
              offset: Offset(0, _animations[index].value),
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 1.5),
                width: 3,
                height: 3,
                decoration: BoxDecoration(
                  color: widget.color,
                  shape: BoxShape.circle,
                ),
              ),
            );
          },
        );
      }),
    );
  }
}