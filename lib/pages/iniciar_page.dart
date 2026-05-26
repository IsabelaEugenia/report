import 'package:flutter/material.dart';
import '/main.dart';  

class LoadingScreen extends StatefulWidget {
  const LoadingScreen({super.key});

  @override
  State<LoadingScreen> createState() => _LoadingScreenState();
}

class _LoadingScreenState extends State<LoadingScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);

    _fadeAnimation = Tween<double>(begin: 0.4, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    _scaleAnimation = Tween<double>(begin: 0.9, end: 1.1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    // após 3 segundos vai para o Login
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const LoginPage()),  // ← troca aqui
        );
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

@override
Widget build(BuildContext context) {
  return Scaffold(
    body: Container(
      width: double.infinity,
      height: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.white,
            Color(0xFFFFE5E5),
            Color(0xffa61d2d),
          ],
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return FadeTransition(
                opacity: _fadeAnimation,
                child: ScaleTransition(
                  scale: _scaleAnimation,
                  child: Container(
                    width: 110,
                    height: 110,
                    decoration: BoxDecoration(
                      color: const Color(0xffa61d2d),
                      borderRadius: BorderRadius.circular(28),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xffa61d2d).withValues(alpha: 0.4),
                          blurRadius: 30,
                          spreadRadius: 5,
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.warning_amber_rounded,
                      color: Colors.white,
                      size: 60,
                    ),
                  ),
                ),
              );
            },
          ),

          const SizedBox(height: 40),

          const Text(
            'Report+',
            style: TextStyle(
              color: Color(0xffa61d2d),
              fontSize: 36,
              fontWeight: FontWeight.bold,
              letterSpacing: 2,
            ),
          ),

          const SizedBox(height: 8),

          const Text(
            'Sistema de reporte de problemas',
            style: TextStyle(
              color: Color(0xff7a7a7a),
              fontSize: 14,
              letterSpacing: 1.2,
            ),
          ),

          const SizedBox(height: 60),

          SizedBox(
            width: 200,
            child: LinearProgressIndicator(
              backgroundColor: const Color(0xFFFFCCCC),
              valueColor: const AlwaysStoppedAnimation<Color>(
                Color(0xffa61d2d),
              ),
              borderRadius: BorderRadius.circular(8),
              minHeight: 4,
            ),
          ),

          const SizedBox(height: 16),

          const Text(
            'Carregando...',
            style: TextStyle(
              color: Color(0xffa61d2d),
              fontSize: 13,
            ),
          ),
        ],
      ),
    ),
  );
  }
 }