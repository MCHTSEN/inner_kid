import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:inner_kid/core/theme/theme.dart';
import '../models/analysis_question.dart';

/// Widget for displaying questions with smooth animations
class QuestionWidget extends ConsumerStatefulWidget {
  final AnalysisQuestion question;
  final bool isActive;
  final bool isAnswered;
  final Function(String) onAnswerSelected;
  final int questionNumber;

  const QuestionWidget({
    super.key,
    required this.question,
    required this.isActive,
    required this.isAnswered,
    required this.onAnswerSelected,
    required this.questionNumber,
  });

  @override
  ConsumerState<QuestionWidget> createState() => _QuestionWidgetState();
}

class _QuestionWidgetState extends ConsumerState<QuestionWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _heightAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _initAnimations();

    // If the widget starts as active, trigger the animation
    if (widget.isActive) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _animationController.forward();
      });
    }
  }

  void _initAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _heightAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));

    _opacityAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.3, 1.0, curve: Curves.easeOut),
    ));
  }

  @override
  void didUpdateWidget(QuestionWidget oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.isActive && !oldWidget.isActive) {
      _animationController.forward();
    } else if (!widget.isActive && oldWidget.isActive) {
      _animationController.reverse();
    } else if (widget.isAnswered && !oldWidget.isAnswered) {
      // Animate closing when question is answered
      _animationController.reverse();
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.isAnswered && !widget.isActive) {
      return _buildAnsweredState();
    }

    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          decoration: AppStyles.cardDecoration.copyWith(
            boxShadow: widget.isActive
                ? [
                    BoxShadow(
                      color: AppTheme.primaryColor.withOpacity(0.15),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ]
                : AppStyles.cardDecoration.boxShadow,
          ),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildQuestionHeader(),
                if (widget.isActive) ...[
                  SizeTransition(
                    sizeFactor: _heightAnimation,
                    child: FadeTransition(
                      opacity: _opacityAnimation,
                      child: Column(
                        children: [
                          const SizedBox(height: 20),
                          _buildOptions(),
                        ],
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildQuestionHeader() {
    return Row(
      children: [
        // Question number badge
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            gradient: widget.isActive
                ? AppTheme.primaryGradient
                : LinearGradient(
                    colors: [
                      AppTheme.textTertiary.withOpacity(0.3),
                      AppTheme.textTertiary.withOpacity(0.2),
                    ],
                  ),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Center(
            child: Text(
              '${widget.questionNumber}',
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: widget.isActive ? Colors.white : AppTheme.textTertiary,
              ),
            ),
          ),
        ),
        const SizedBox(width: 16),

        // Question text
        Expanded(
          child: Text(
            widget.question.question,
            style: GoogleFonts.poppins(
              fontSize: widget.isActive ? 16 : 14,
              fontWeight: FontWeight.w600,
              color: widget.isActive
                  ? AppTheme.textPrimary
                  : AppTheme.textSecondary,
            ),
          ),
        ),

        // Status indicator
        if (widget.isAnswered)
          const Icon(
            Icons.check_circle,
            color: Colors.green,
            size: 24,
          )
        else if (widget.isActive)
          const Icon(
            Icons.radio_button_unchecked,
            color: AppTheme.primaryColor,
            size: 24,
          ),
      ],
    );
  }

  Widget _buildOptions() {
    return Column(
      children: widget.question.options.map((option) {
        final isSelected = widget.question.selectedAnswer == option;

        return GestureDetector(
          onTap: () => widget.onAnswerSelected(option),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isSelected
                  ? AppTheme.primaryColor.withOpacity(0.1)
                  : AppTheme.surfaceColor,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSelected
                    ? AppTheme.primaryColor
                    : AppTheme.textTertiary.withOpacity(0.2),
                width: isSelected ? 2 : 1,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  isSelected
                      ? Icons.radio_button_checked
                      : Icons.radio_button_unchecked,
                  color: isSelected
                      ? AppTheme.primaryColor
                      : AppTheme.textTertiary,
                  size: 20,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    option,
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight:
                          isSelected ? FontWeight.w600 : FontWeight.w400,
                      color: isSelected
                          ? AppTheme.primaryColor
                          : AppTheme.textPrimary,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildAnsweredState() {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.green.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.green.withOpacity(0.2),
        ),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.check_circle,
            color: Colors.green,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.question.question,
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: AppTheme.textSecondary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  widget.question.selectedAnswer!,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.green.shade700,
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
