import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:inner_kid/core/theme/theme.dart';

import '../models/onboarding_state.dart';
import '../viewmodels/onboarding_viewmodel.dart';

class ImageUploadScreen extends ConsumerStatefulWidget {
  const ImageUploadScreen({super.key});

  @override
  ConsumerState<ImageUploadScreen> createState() => _ImageUploadScreenState();
}

class _ImageUploadScreenState extends ConsumerState<ImageUploadScreen>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(-1.0, 0.0), // Slide from left
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));

    // Start animation when screen loads
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(onboardingViewModelProvider);

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppTheme.backgroundGradient,
        ),
        child: SafeArea(
          child: SlideTransition(
            position: _slideAnimation,
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  // Header without back button
                  Row(
                    children: [
                      const SizedBox(width: 48), // For alignment
                      const Spacer(),
                      const SizedBox(width: 48), // For alignment
                    ],
                  ),

                  // Main content
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Illustration or uploaded image
                        _buildImageSection(state),

                        const SizedBox(height: 32),

                        // Title
                        Text(
                          state.childName != null
                              ? '${state.childName} için ilk çizimi yükle, iç dünyasına birlikte bakalım.'
                              : 'Çocuğunuzun ilk çizimini yükle, iç dünyasına birlikte bakalım.',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.poppins(
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.textPrimary,
                            height: 1.4,
                          ),
                        ),

                        const SizedBox(height: 16),

                        // Description
                        Text(
                          'Çocuğunuzun duygusal gelişimini anlamak için çizimini yükleyin',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            color: AppTheme.textSecondary,
                            height: 1.5,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Action buttons
                  _buildActionButtons(ref, state),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildImageSection(OnboardingState state) {
    if (state.imageUrl != null) {
      // Show uploaded image
      return Container(
        height: 200,
        width: 200,
        decoration: BoxDecoration(
          image: DecorationImage(
            image: FileImage(File(state.imageUrl!)),
            fit: BoxFit.cover,
          ),
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
      );
    } else {
      // Show upload placeholder
      return Container(
        height: 200,
        width: 200,
        decoration: BoxDecoration(
          color: AppTheme.surfaceColor,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: AppTheme.primaryColor.withOpacity(0.3),
            width: 2,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.add_a_photo_outlined,
              size: 48,
              color: AppTheme.primaryColor,
            ),
            const SizedBox(height: 16),
            Text(
              'Çizim Yükle',
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppTheme.primaryColor,
              ),
            ),
          ],
        ),
      );
    }
  }

  Widget _buildActionButtons(WidgetRef ref, OnboardingState state) {
    return Column(
      children: [
        // Upload button
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: state.isLoading
                ? null
                : () {
                    ref.read(onboardingViewModelProvider.notifier).pickImage();
                  },
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: state.isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.upload_file, color: Colors.white),
                      const SizedBox(width: 8),
                      Text(
                        state.imageUrl != null
                            ? 'Yeniden Yükle'
                            : 'Galeriden Seç',
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
          ),
        ),

        const SizedBox(height: 16),

        // Camera button
        SizedBox(
          width: double.infinity,
          child: OutlinedButton(
            onPressed: state.isLoading
                ? null
                : () {
                    // TODO: Implement camera capture
                    // For now, we'll just show a message
                    ScaffoldMessenger.of(ref.context).showSnackBar(
                      const SnackBar(
                        content: Text('Kamera özelliği yakında eklenecek'),
                        duration: Duration(seconds: 2),
                      ),
                    );
                  },
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              side: BorderSide(color: AppTheme.primaryColor),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.camera_alt, color: AppTheme.primaryColor),
                const SizedBox(width: 8),
                Text(
                  'Fotoğraf Çek',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.primaryColor,
                  ),
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 24),

        // Skip option (if image already uploaded)
        if (state.imageUrl != null)
          TextButton(
            onPressed: () {
              ref.read(onboardingViewModelProvider.notifier).nextStep();
            },
            child: Text(
              'Şimdi Değil, Sonra Yükle',
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: AppTheme.textSecondary,
              ),
            ),
          ),
      ],
    );
  }
}
