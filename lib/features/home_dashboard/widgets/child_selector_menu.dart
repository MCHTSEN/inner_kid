import 'dart:math';
import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

const itemHeight = 55.0;
const menuItemsMaxScale = 1.1;
const indicatorHeight = itemHeight * menuItemsMaxScale;
const maxDistance = itemHeight / 2 + indicatorHeight / 2;
const indicatorVPadding = -((itemHeight * menuItemsMaxScale - itemHeight) / 2);
const maxStretchDistance = 200;

// Mock children data
const children = [
  {'name': 'Ahmet', 'age': 8, 'gender': 'Erkek'},
  {'name': 'Ayşe', 'age': 6, 'gender': 'Kız'},
  {'name': 'Çocuk Ekle', 'age': null, 'gender': null}, // Add child option
];

class ChildSelectorMenu extends StatefulWidget {
  final Function(Map<String, dynamic>?)? onChildSelected;

  const ChildSelectorMenu({
    super.key,
    this.onChildSelected,
  });

  @override
  State<ChildSelectorMenu> createState() => _ChildSelectorMenuState();
}

class _ChildSelectorMenuState extends State<ChildSelectorMenu>
    with TickerProviderStateMixin {
  final OverlayPortalController _overlayController = OverlayPortalController();
  final GlobalKey widgetKey = GlobalKey();

  late final AnimationController _overlayAnimationController;
  late final Animation<double> _overlayScaleAnimation;
  late final Animation<double> _overlayFadeAnimation;
  late CurvedAnimation _overlayScaleAnimationCurve;

  late final AnimationController _buttonAnimationController;
  late final Animation<double> _buttonScaleAnimation;

  final _link = LayerLink();
  double indicatorOffset = indicatorVPadding; // Start at first item
  bool showIndicator = false;
  double stretchDistance = 0;
  double menuStretchScale = 1.0;
  double indicatorStretchScaleY = 1;
  int? selectedChildIndex;

  double get indicatorCenter => indicatorOffset + indicatorHeight / 2;

  double _getListItemScale(int index) {
    final itemCenter = (itemHeight * index) + (itemHeight / 2);
    final centersDistance = (indicatorCenter - itemCenter).abs();
    if (centersDistance <= maxDistance && showIndicator) {
      return lerpDouble(menuItemsMaxScale, 1, centersDistance / maxDistance) ??
          1;
    }
    return 1;
  }

  void _handlePointerUpOrCancel() {
    if (_overlayController.isShowing) {
      // Handle selection if there's an active indicator
      if (showIndicator) {
        final activeIndex = (indicatorOffset / itemHeight).round();
        if (activeIndex >= 0 && activeIndex < children.length) {
          selectedChildIndex = activeIndex;
          widget.onChildSelected?.call(children[activeIndex]);
          HapticFeedback.selectionClick();
        }
      }

      _overlayAnimationController.reverse().then((_) {
        _overlayController.hide();
        setState(() {
          indicatorOffset = indicatorVPadding; // Reset to first item
        });
      });
    }
    if (showIndicator) setState(() => showIndicator = false);
    setState(() {
      menuStretchScale = 1.0;
      indicatorStretchScaleY = 1;
      stretchDistance = 0;
    });
  }

  RenderBox? _getMenuRenderBox() {
    return widgetKey.currentContext?.findRenderObject() as RenderBox?;
  }

  void _handlePointerMove(PointerMoveEvent event) {
    // For downward opening menu, check for downward swipe
    if (event.delta.dy > 10) {
      if (!_overlayController.isShowing) {
        _overlayScaleAnimationCurve.curve = Curves.easeOut;
        _overlayController.show();
        _overlayAnimationController.forward();
      }
    }

    RenderBox? box = _getMenuRenderBox();
    if (box != null) {
      // Convert global position to local position relative to the menu
      final globalPosition = event.position;
      final menuGlobalPosition = box.localToGlobal(Offset.zero);
      final relativePosition = globalPosition - menuGlobalPosition;

      bool isInsideHeight =
          relativePosition.dy >= 0 && relativePosition.dy <= box.size.height;

      if (isInsideHeight) {
        if (!showIndicator) setState(() => showIndicator = true);
        final realtimeIndicatorOffset =
            (relativePosition.dy - (itemHeight * menuItemsMaxScale / 2)).clamp(
                indicatorVPadding,
                (itemHeight * (children.length - 1)) + indicatorVPadding);
        final activeIndex = (realtimeIndicatorOffset / itemHeight).round();
        setState(() {
          indicatorOffset = (itemHeight * activeIndex) - -indicatorVPadding;
        });
      } else {
        // Handle pull & stretch effect for downward menu
        stretchDistance = relativePosition.dy < 0
            ? relativePosition.dy
            : relativePosition.dy - box.size.height;
        if (showIndicator) {
          final mappedScale = (box.size.height +
                  stretchDistance.abs().clamp(0, maxStretchDistance)) /
              box.size.height;
          setState(() {
            menuStretchScale = 1 + 0.1 * log(mappedScale);
            indicatorStretchScaleY = 1 + 0.05 * log(mappedScale);
          });
        }
      }
    }
  }

  void _handleLongPressDown(details) {
    HapticFeedback.lightImpact();
    _buttonAnimationController.forward();
  }

  void _handleLongPressStart(details) {
    if (!_overlayController.isShowing) {
      _overlayController.show();
      _overlayScaleAnimationCurve.curve = Curves.easeOutBack;
      _overlayAnimationController.forward();
      _buttonAnimationController.reverse();
      HapticFeedback.mediumImpact();
    }
  }

  void _handleLongPressEndOrCancel() {
    if (_buttonScaleAnimation.status == AnimationStatus.forward ||
        _buttonScaleAnimation.status == AnimationStatus.completed) {
      _buttonAnimationController.reverse();
    }
  }

  @override
  void initState() {
    super.initState();
    _overlayAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );

    _overlayScaleAnimationCurve = CurvedAnimation(
      parent: _overlayAnimationController,
      curve: Curves.easeOutBack,
    );
    _overlayScaleAnimation = Tween<double>(begin: 0, end: 1).animate(
      _overlayScaleAnimationCurve,
    );
    _overlayFadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
          parent: _overlayAnimationController, curve: Curves.easeOut),
    );

    _buttonAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );

    _buttonScaleAnimation = Tween<double>(begin: 1, end: 0.9).animate(
      CurvedAnimation(
        parent: _buttonAnimationController,
        curve: Curves.easeInBack,
      ),
    );
  }

  @override
  void dispose() {
    _overlayAnimationController.dispose();
    _buttonAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return OverlayPortal(
      controller: _overlayController,
      overlayChildBuilder: (context) {
        return CompositedTransformFollower(
          link: _link,
          targetAnchor: Alignment.bottomCenter,
          followerAnchor: Alignment.topCenter,
          offset: const Offset(0, 20),
          child: Align(
            alignment: Alignment.topCenter,
            child: FadeTransition(
              opacity: _overlayFadeAnimation,
              child: ScaleTransition(
                scale: _overlayScaleAnimation,
                alignment: Alignment.topCenter,
                child: _buildOverlayMenu(),
              ),
            ),
          ),
        );
      },
      child: Listener(
        onPointerDown: (_) {
          // Show indicator immediately when user starts interacting
          if (_overlayController.isShowing && !showIndicator) {
            setState(() => showIndicator = true);
          }
        },
        onPointerUp: (_) => _handlePointerUpOrCancel(),
        onPointerCancel: (_) => _handlePointerUpOrCancel(),
        onPointerMove: _handlePointerMove,
        child: GestureDetector(
          onLongPressDown: _handleLongPressDown,
          onLongPressCancel: _handleLongPressEndOrCancel,
          onLongPressEnd: (_) => _handleLongPressEndOrCancel(),
          onLongPressStart: _handleLongPressStart,
          child: CompositedTransformTarget(
            link: _link,
            child: ScaleTransition(
              scale: _buttonScaleAnimation,
              child: const ChildSelectorButton(),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildOverlayMenu() {
    return TweenAnimationBuilder(
      tween: Tween<Alignment>(
        begin: Alignment.center,
        end: Alignment(0.0, -4 * stretchDistance.sign),
      ),
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOut,
      builder: (context, alignment, _) {
        return TweenAnimationBuilder(
          tween: Tween<double>(begin: 1.0, end: menuStretchScale),
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
          builder: (context, double value, _) {
            return Transform.scale(
              alignment: alignment,
              scaleY: value,
              scaleX: 1 - (value - 1),
              child: Container(
                key: widgetKey,
                decoration: BoxDecoration(
                  color: const Color.fromARGB(255, 220, 219, 219),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      blurRadius: 10,
                      color: Colors.grey,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                height: itemHeight * children.length,
                width: 280,
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    ChildMenuIndicator(
                      scaleY: indicatorStretchScaleY,
                      offset: indicatorOffset,
                      isVisible: showIndicator,
                      alignment: Alignment(
                        0.0,
                        -10 * stretchDistance.sign,
                      ),
                    ),
                    Positioned.fill(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: List.generate(
                          children.length,
                          (index) => ChildMenuListItem(
                            child: children[index],
                            index: index,
                            scale: _getListItemScale(index),
                            isSelected: selectedChildIndex == index,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}

class ChildSelectorButton extends StatelessWidget {
  const ChildSelectorButton({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFF667EEA),
        shape: BoxShape.circle,
      ),
      width: 36,
      height: 36,
      child: const Icon(
        Icons.person,
        color: Colors.white,
        size: 20,
      ),
    );
  }
}

class ChildMenuListItem extends StatelessWidget {
  const ChildMenuListItem({
    super.key,
    this.index = 0,
    required this.child,
    this.scale = 1.0,
    this.isSelected = false,
  });

  final int index;
  final Map<String, dynamic> child;
  final double scale;
  final bool isSelected;

  @override
  Widget build(BuildContext context) {
    final isAddOption = child['age'] == null;

    return AnimatedScale(
      scale: scale,
      curve: Curves.linearToEaseOut,
      duration: const Duration(milliseconds: 450),
      child: Container(
        height: itemHeight,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        alignment: Alignment.center,
        child: Row(
          children: [
            // Avatar
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isAddOption
                    ? const Color(0xFF667EEA).withOpacity(0.1)
                    : child['gender'] == 'Erkek'
                        ? Colors.blue.withOpacity(0.1)
                        : Colors.pink.withOpacity(0.1),
              ),
              child: Icon(
                isAddOption
                    ? Icons.add
                    : child['gender'] == 'Erkek'
                        ? Icons.boy
                        : Icons.girl,
                color: isAddOption
                    ? const Color(0xFF667EEA)
                    : child['gender'] == 'Erkek'
                        ? Colors.blue
                        : Colors.pink,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),

            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    child['name'],
                    style: GoogleFonts.nunito(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: isAddOption
                          ? const Color(0xFF667EEA)
                          : const Color(0xFF2D3748),
                    ),
                  ),
                  if (!isAddOption) ...[
                    const SizedBox(height: 2),
                    Text(
                      '${child['age']} yaş',
                      style: GoogleFonts.nunito(
                        fontSize: 12,
                        color: const Color(0xFF718096),
                      ),
                    ),
                  ],
                ],
              ),
            ),

            // Selection indicator
            if (isSelected)
              const Icon(
                Icons.check_circle,
                color: Color(0xFF667EEA),
                size: 20,
              ),
          ],
        ),
      ),
    );
  }
}

class ChildMenuIndicator extends StatelessWidget {
  const ChildMenuIndicator({
    super.key,
    this.scaleY = 1.0,
    this.offset = 0,
    this.isVisible = false,
    this.alignment = Alignment.center,
  });

  final double scaleY;
  final double offset;
  final bool isVisible;
  final AlignmentGeometry alignment;

  @override
  Widget build(BuildContext context) {
    return AnimatedPositioned(
      duration: const Duration(milliseconds: 300),
      curve: Curves.linearToEaseOut,
      top: offset,
      left: -8,
      right: -8,
      height: itemHeight * menuItemsMaxScale,
      child: AnimatedOpacity(
        opacity: isVisible ? 1 : 0,
        curve: Curves.easeIn,
        duration: const Duration(milliseconds: 300),
        child: Transform.scale(
          alignment: alignment,
          scaleY: scaleY,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  blurRadius: 10,
                  color: Colors.black.withOpacity(0.2),
                  offset: const Offset(0, 5),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

extension SizeExtension on Size {
  bool heightContains(Offset offset) {
    return offset.dy >= 0.0 && offset.dy < height;
  }
}
