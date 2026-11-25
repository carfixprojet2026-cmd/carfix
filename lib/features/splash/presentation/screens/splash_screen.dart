import 'dart:async';
import 'package:material_ui/material_ui.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/firebase_constants.dart';
import '../widgets/precision_progress_bar.dart';

class SplashScreen extends StatefulWidget {
  final VoidCallback? onInitialized;

  const SplashScreen({
    super.key,
    this.onInitialized,
  });

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _fadeController;
  late final Animation<double> _fadeAnimation;
  late final Animation<double> _scaleAnimation;
  Timer? _navigationTimer;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOutCubic,
    );

    _scaleAnimation = Tween<double>(begin: 0.95, end: 1.0).animate(
      CurvedAnimation(
        parent: _fadeController,
        curve: Curves.easeOutBack,
      ),
    );

    _fadeController.forward();

    // Trigger next step if callback is provided
    if (widget.onInitialized != null) {
      _navigationTimer = Timer(const Duration(milliseconds: 3200), () {
        if (mounted) {
          widget.onInitialized!();
        }
      });
    }
  }

  @override
  void dispose() {
    _navigationTimer?.cancel();
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // Background Gradient Layer
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  AppColors.surfaceObsidian,
                  AppColors.surfaceCharcoal,
                  AppColors.surfaceDark,
                ],
              ),
            ),
          ),

          // Precision Engineering Grid Overlay
          CustomPaint(
            size: Size.infinite,
            painter: _PrecisionGridPainter(),
          ),

          // Central Ambient Orange Glow
          Center(
            child: Container(
              width: 320,
              height: 320,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppColors.primaryOrange.withValues(alpha: 0.08),
                    AppColors.surfaceObsidian.withValues(alpha: 0.0),
                  ],
                  stops: const [0.0, 0.7],
                ),
              ),
            ),
          ),

          // Main Content
          SafeArea(
            child: Column(
              children: [
                const Spacer(flex: 3),

                // Hero Logo Presentation with Fade & Subtle Scale Animation
                FadeTransition(
                  opacity: _fadeAnimation,
                  child: ScaleTransition(
                    scale: _scaleAnimation,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Luxury Glassmorphism Card
                          Container(
                            width: double.infinity,
                            constraints: const BoxConstraints(maxWidth: 340),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 28.0,
                              vertical: 24.0,
                            ),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(22.0),
                              gradient: const LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  Color(0x0DFFFFFF), // 5% white top specular
                                  Color(0x66000000), // 40% black center
                                  Color(0x99000000), // 60% black bottom
                                ],
                              ),
                              border: Border.all(
                                color: const Color(0x1AFFFFFF), // 10% white
                                width: 1.0,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.85),
                                  blurRadius: 40,
                                  offset: const Offset(0, 16),
                                ),
                                BoxShadow(
                                  color: AppColors.primaryOrange.withValues(alpha: 0.04),
                                  blurRadius: 20,
                                  spreadRadius: 2,
                                ),
                              ],
                            ),
                            child: Image.asset(
                              'assets/images/carfix_logo_light.png',
                              fit: BoxFit.contain,
                              height: 95,
                            ),
                          ),

                          const SizedBox(height: 32.0),

                          // Brand Tagline
                          const Text(
                            FirebaseConstants.appTagline,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: AppColors.textMuted,
                              fontSize: 11.5,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 4.0,
                            ),
                          ),

                          const SizedBox(height: 8.0),

                          // Subtagline
                          const Text(
                            FirebaseConstants.appSubtagline,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: AppColors.textSubtle,
                              fontSize: 10.0,
                              fontWeight: FontWeight.w500,
                              letterSpacing: 2.8,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                const Spacer(flex: 4),

                // Bottom Indicator & Launch Status
                FadeTransition(
                  opacity: _fadeAnimation,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Animated Glow Progress Bar
                        const PrecisionProgressBar(
                          width: 144.0,
                          height: 3.0,
                        ),

                        const SizedBox(height: 24.0),

                        // Certified Network Trust Label
                        const Text(
                          FirebaseConstants.certifiedNetworkText,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Color(0x66FFFFFF),
                            fontSize: 10.0,
                            fontWeight: FontWeight.w500,
                            letterSpacing: 1.8,
                          ),
                        ),

                        const SizedBox(height: 6.0),

                        // Version Identifier
                        Text(
                          'VERSION ${FirebaseConstants.appVersion}',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: AppColors.textFaint,
                            fontSize: 9.0,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 2.5,
                            fontFamily: 'monospace',
                          ),
                        ),

                        const SizedBox(height: 18.0),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Subtle grid pattern matching precision engineering look
class _PrecisionGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0x06FFFFFF) // very faint 2.5% opacity
      ..strokeWidth = 1.0;

    const step = 32.0;

    for (double x = 0; x < size.width; x += step) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }

    for (double y = 0; y < size.height; y += step) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
