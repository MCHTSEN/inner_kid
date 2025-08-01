import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:inner_kid/core/theme/theme.dart';
import 'dart:io';

import '../viewmodels/onboarding_viewmodel.dart';
import '../models/onboarding_state.dart';

class ImageUploadScreen extends ConsumerWidget {
  const ImageUploadScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(onboardingViewModelProvider);
    
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppTheme.backgroundGradient,
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                // Header with back button
                Row(
                  children: [
                    IconButton(
                      onPressed: () {
                        ref.read(onboardingViewModelProvider.notifier).previousStep();
                      },
                      icon: const Icon(Icons.arrow_back, color: AppTheme.textPrimary),
                    ),
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
                            ? '${state.childName}\'nin ilk çizimini yükle, iç dünyasına birlikte bakalım.'
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
                        state.imageUrl != null ? 'Yeniden Yükle' : 'Galeriden Seç',
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
