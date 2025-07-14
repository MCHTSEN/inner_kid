import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AppleLockButton extends StatefulWidget {
  final VoidCallback? onLongPress;
  final VoidCallback? onLongPressEnd;
  final Widget child;
  final double size;
  final Color normalColor;
  final Color pressedColor;

  const AppleLockButton({
    Key? key,
    this.onLongPress,
    this.onLongPressEnd,
    required this.child,
    this.size = 60.0,
    this.normalColor = Colors.grey,
    this.pressedColor = Colors.white,
  }) : super(key: key);

  @override
  State<AppleLockButton> createState() => _AppleLockButtonState();
}

class _AppleLockButtonState extends State<AppleLockButton>
    with TickerProviderStateMixin {
  late AnimationController _scaleController;
  late AnimationController _bounceController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _bounceAnimation;
  late Animation<Color?> _colorAnimation;
  
  bool _isPressed = false;
  bool _isLongPressed = false;
  static const Duration _longPressThreshold = Duration(milliseconds: 500);

  @override
  void initState() {
    super.initState();
    
    // Main scale controller for the initial scale up
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    
    // Bounce controller for the debounce effect
    _bounceController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    
    // Scale animation from 1.0 to 1.1 (initial press), then to 1.5 (long press)
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.1,
    ).animate(CurvedAnimation(
      parent: _scaleController,
      curve: Curves.easeOut,
    ));
    
    // Bounce animation from 1.5 to 1.3 and back to 1.5 (smooth single bounce)
    _bounceAnimation = Tween<double>(
      begin: 1.5,
      end: 1.3,
    ).animate(CurvedAnimation(
      parent: _bounceController,
      curve: Curves.easeInOut,
    ));
    
    // Color animation - only active during long press
    _colorAnimation = ColorTween(
      begin: widget.normalColor,
      end: widget.pressedColor,
    ).animate(CurvedAnimation(
      parent: _scaleController,
      curve: Curves.easeOut,
    ));
  }

  @override
  void dispose() {
    _scaleController.dispose();
    _bounceController.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails details) {
    setState(() {
      _isPressed = true;
    });
    
    // Immediate scale up to 1.1x
    _scaleController.forward();
    
    // Start timer for long press detection
    Future.delayed(_longPressThreshold, () {
      if (_isPressed) {
        _activateLongPress();
      }
    });
  }

  void _onTapUp(TapUpDetails details) {
    _resetButton();
  }

  void _onTapCancel() {
    _resetButton();
  }

  void _activateLongPress() {
    setState(() {
      _isLongPressed = true;
    });
    
    // Trigger haptic feedback
    HapticFeedback.mediumImpact();
    
    // Scale up to 1.5x and change color
    _scaleAnimation = Tween<double>(
      begin: 1.1,
      end: 1.5,
    ).animate(CurvedAnimation(
      parent: _scaleController,
      curve: Curves.easeOut,
    ));
    
    _scaleController.reset();
    _scaleController.forward().then((_) {
      if (_isLongPressed) {
        _startBounceAnimation();
      }
    });
    
    // Call the callback
    widget.onLongPress?.call();
  }

  void _startBounceAnimation() {
    // Single smooth bounce: 1.5 -> 1.3 -> 1.5
    _bounceController.forward().then((_) {
      if (_isLongPressed) {
        _bounceController.reverse();
      }
    });
  }

  void _resetButton() {
    setState(() {
      _isPressed = false;
      _isLongPressed = false;
    });
    
    // Stop bounce animation and reset to normal state
    _bounceController.stop();
    _bounceController.reset();
    
    // Reset scale animation to normal
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.1,
    ).animate(CurvedAnimation(
      parent: _scaleController,
      curve: Curves.easeOut,
    ));
    
    _scaleController.reverse();
    
    // Call the callback if it was a long press
    if (_isLongPressed) {
      widget.onLongPressEnd?.call();
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      child: AnimatedBuilder(
        animation: Listenable.merge([_scaleAnimation, _bounceAnimation, _colorAnimation]),
        builder: (context, child) {
          double currentScale = _scaleAnimation.value;
          Color currentColor = _isLongPressed ? _colorAnimation.value! : widget.normalColor;
          
          // Apply bounce effect when bounce animation is active during long press
          if (_isLongPressed && (_bounceController.isAnimating || _bounceController.isCompleted)) {
            currentScale = _bounceAnimation.value;
          }
          
          return Transform.scale(
            scale: currentScale,
            child: Container(
              width: widget.size,
              height: widget.size,
              decoration: BoxDecoration(
                color: currentColor,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: widget.child,
            ),
          );
        },
      ),
    );
  }
}
