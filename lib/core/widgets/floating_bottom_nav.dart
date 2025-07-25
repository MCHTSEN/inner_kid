import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../../features/analysis_flow/viewmodels/analysis_viewmodel.dart';
import '../../features/analysis_flow/views/analysis_waiting_page.dart';

class FloatingBottomNav extends ConsumerWidget {
  final int currentIndex;
  final Function(int) onTap;

  const FloatingBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Positioned(
      left: 16,
      right: 16,
      bottom: 20,
      child: Container(
        height: 70,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(35),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Row(
          children: [
            _buildNavItem(
              context,
              icon: Icons.play_circle_outline,
              label: 'Canlandır',
              index: 0,
              isActive: currentIndex == 0,
            ),
            _buildNavItem(
              context,
              icon: Icons.person_outline,
              label: 'Profil',
              index: 1,
              isActive: currentIndex == 1,
            ),
            _buildAnalyzeButton(context, ref),
            _buildNavItem(
              context,
              icon: Icons.quiz_outlined,
              label: 'Testler',
              index: 3,
              isActive: currentIndex == 3,
            ),
            _buildNavItem(
              context,
              icon: Icons.home_outlined,
              label: 'Anasayfa',
              index: 4,
              isActive: currentIndex == 4,
            ),
          ],
        ),
      ),
    ).animate().slideY(begin: 1, duration: 600.ms, curve: Curves.easeOutBack);
  }

  /// Handle analyze button press - show image picker and start analysis
  void _onAnalyzeButtonPressed(BuildContext context, WidgetRef ref) async {
    try {
      // Show image picker
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 2048,
        maxHeight: 2048,
        imageQuality: 85,
      );

      if (image != null) {
        // Convert XFile to File
        final File imageFile = File(image.path);

        // Navigate to analysis waiting page
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => const AnalysisWaitingPage(),
          ),
        );

        // Start analysis
        await ref.read(analysisViewModelProvider.notifier).startAnalysis(
          imageFile: imageFile,
          questionnaire: {
            'source': 'floating_nav',
            'timestamp': DateTime.now().toIso8601String(),
          },
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Görsel seçilirken hata oluştu: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Widget _buildNavItem(
    BuildContext context, {
    required IconData icon,
    required String label,
    required int index,
    required bool isActive,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: () => onTap(index),
        child: Container(
          height: 70,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(35),
            color: isActive
                ? const Color(0xFF667EEA).withOpacity(0.1)
                : Colors.transparent,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                color: isActive
                    ? const Color(0xFF667EEA)
                    : const Color(0xFF9CA3AF),
                size: 24,
              ),
              const SizedBox(height: 2),
              Text(
                label,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
                  color: isActive
                      ? const Color(0xFF667EEA)
                      : const Color(0xFF9CA3AF),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAnalyzeButton(BuildContext context, WidgetRef ref) {
    return Container(
      width: 80,
      height: 80,
      margin: const EdgeInsets.symmetric(horizontal: 8),
      child: GestureDetector(
        onTap: () => _onAnalyzeButtonPressed(context, ref),
        child: Container(
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(40),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF667EEA).withOpacity(0.3),
                blurRadius: 15,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: const Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.add_a_photo,
                color: Colors.white,
                size: 28,
              ),
              SizedBox(height: 2),
              Text(
                'Analiz Et',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
