import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:inner_kid/core/theme/theme.dart';
import 'package:video_player/video_player.dart';

import '../../components/social_proof_widget.dart';
import '../../viewmodels/onboarding_viewmodel.dart';
import 'question_card.dart';

class QuestionPageView extends ConsumerWidget {
  const QuestionPageView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(onboardingViewModelProvider);
    final questions = OnboardingViewModel.questions;
    final totalPages = questions.length + 1; // +1 for social proof section

    return PageView.builder(
      controller: state.pageController,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: totalPages,
      onPageChanged: (index) {
        // Page change is handled by the view model
      },
      itemBuilder: (context, index) {
        if (index == 4) {
          // Social proof section
          return SingleChildScrollView(
            child: SizedBox(
              height: MediaQuery.of(context).size.height * 0.7,
              child: Center(
                child: _buildSocialProofSection(1),
              ),
            ),
          );
        } else if (index < totalPages) {
          // Adjust index for social proof section
          int questionIndex = index;
          if (index > 4) questionIndex--;

          if (questionIndex < questions.length) {
            return SingleChildScrollView(
              child: SizedBox(
                height: MediaQuery.of(context).size.height * 0.7,
                child: Center(
                  child: QuestionCard(
                    question: questions[questionIndex],
                    questionIndex: questionIndex,
                  ),
                ),
              ),
            );
          }
        }
        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildSocialProofSection(int sectionNumber) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Video container
          ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: _buildVideoPlayer(),
          ),
          const SizedBox(height: 24),
          if (sectionNumber == 1)
            const SocialProofWidget(
              title:
                  'Ebeveynlerin %91\'i, analizlerinin çocuklarını daha iyi anlamalarına yardımcı olduğunu söyledi.',
              icon: Icons.trending_up,
              isPrimary: true,
            )
          else
            const SocialProofWidget(
              title:
                  '22.400 çocuk, çizimleriyle duygusal gelişim yolculuğunda.',
              icon: Icons.favorite_border,
              isPrimary: true,
            ),
          const SizedBox(height: 16),
          Text(
            sectionNumber == 1
                ? 'Join thousands of parents gaining deeper emotional insights into their children.'
                : 'Join our community of parents supporting their children\'s emotional growth.',
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: AppTheme.textSecondary,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVideoPlayer() {
    return Consumer(
      builder: (context, ref, child) {
        final state = ref.watch(onboardingViewModelProvider);
        final videoController = state.videoController;

        if (videoController != null && videoController.value.isInitialized) {
          return AspectRatio(
            aspectRatio: videoController.value.aspectRatio,
            child: VideoPlayer(videoController),
          );
        } else {
          return Container(
            color: AppTheme.primaryColor.withOpacity(0.1),
            child: const Center(
              child: CircularProgressIndicator(),
            ),
          );
        }
      },
    );
  }
}
