import 'package:material_ui/material_ui.dart';
import '../../../../core/constants/app_colors.dart';

class PrecisionProgressBar extends StatefulWidget {
  final double width;
  final double height;

  const PrecisionProgressBar({
    super.key,
    this.width = 144.0,
    this.height = 3.0,
  });

  @override
  State<PrecisionProgressBar> createState() => _PrecisionProgressBarState();
}

class _PrecisionProgressBarState extends State<PrecisionProgressBar>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    )..repeat();

    _animation = Tween<double>(begin: -1.0, end: 1.5).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOutCubic,
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: widget.width,
      height: widget.height,
      decoration: BoxDecoration(
        color: AppColors.progressTrack,
        borderRadius: BorderRadius.circular(widget.height),
      ),
      clipBehavior: Clip.antiAlias,
      child: AnimatedBuilder(
        animation: _animation,
        builder: (context, child) {
          final indicatorWidth = widget.width * 0.55;
          final leftPosition = _animation.value * widget.width;

          return Stack(
            children: [
              Positioned(
                left: leftPosition,
                top: 0,
                bottom: 0,
                width: indicatorWidth,
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(widget.height),
                    gradient: const LinearGradient(
                      colors: [
                        Colors.transparent,
                        AppColors.primaryOrange,
                        AppColors.orangeGlow,
                      ],
                      stops: [0.0, 0.65, 1.0],
                    ),
                    boxShadow: const [
                      BoxShadow(
                        color: AppColors.primaryOrange,
                        blurRadius: 8,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
