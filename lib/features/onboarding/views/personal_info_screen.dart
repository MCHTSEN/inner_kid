import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:inner_kid/core/theme/theme.dart';

import '../components/social_proof_widget.dart';
import '../models/onboarding_state.dart';
import '../viewmodels/onboarding_viewmodel.dart';

class PersonalInfoScreen extends ConsumerStatefulWidget {
  const PersonalInfoScreen({super.key});

  @override
  ConsumerState<PersonalInfoScreen> createState() => _PersonalInfoScreenState();
}

class _PersonalInfoScreenState extends ConsumerState<PersonalInfoScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<Map<String, dynamic>> _questions = [
    {
      'question': 'Çocuğunuzun adı nedir?',
      'type': 'text',
      'field': 'name',
    },
    {
      'question': 'Kaç yaşında?',
      'type': 'number',
      'field': 'age',
    },
    {
      'question': 'Cinsiyeti nedir?',
      'type': 'gender',
      'field': 'gender',
    },
    {
      'question': 'Kaç kardeşi var?',
      'type': 'number',
      'field': 'siblings',
    },
    {
      'question': 'Anaokuluna veya okula gidiyor mu?',
      'type': 'boolean',
      'field': 'school',
    },
  ];

  @override
  void initState() {
    super.initState();
    // Initialize with existing data if available
    final state = ref.read(onboardingViewModelProvider);
    if (state.childName != null) _currentPage = 1;
    if (state.childAge != null) _currentPage = 2;
    if (state.childGender != null) _currentPage = 3;
    if (state.siblingCount != null) _currentPage = 4;
    if (state.attendsSchool != null) _currentPage = 5;

    // Jump to the correct page
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_currentPage > 0) {
        _pageController.jumpToPage(_currentPage);
      }
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = ref.watch(onboardingViewModelProvider);

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.lightGreenAccent.withValues(alpha: 0.3),
              Colors.lightGreenAccent.withValues(alpha: 0.5),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header with progress indicator
              _buildHeader(viewModel),

              // Page view for questions
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount:
                      _questions.length + 2, // +2 for social proof sections
                  onPageChanged: (index) {
                    setState(() {
                      _currentPage = index;
                    });
                  },
                  itemBuilder: (context, index) {
                    if (index == 1) {
                      // First social proof
                      return _buildSocialProofSection(1);
                    } else if (index == 4) {
                      // Second social proof
                      return _buildSocialProofSection(2);
                    } else if (index < _questions.length + 2) {
                      // Adjust index for actual questions
                      int questionIndex = index;
                      if (index > 1) questionIndex--;
                      if (index > 4) questionIndex--;

                      if (questionIndex < _questions.length) {
                        return _buildQuestionPage(questionIndex, viewModel);
                      }
                    }
                    return const SizedBox.shrink();
                  },
                ),
              ),

              // Navigation buttons
              _buildNavigationButtons(viewModel),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(OnboardingState state) {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Row(
        children: [
          // Back button
          if (_currentPage > 0)
            IconButton(
              onPressed: () {
                if (_currentPage > 0) {
                  setState(() {
                    _currentPage--;
                    _pageController.previousPage(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                    );
                  });
                } else {
                  ref.read(onboardingViewModelProvider.notifier).previousStep();
                }
              },
              icon: const Icon(Icons.arrow_back, color: AppTheme.textPrimary),
            )
          else
            const SizedBox(width: 48), // Spacer for alignment

          // Progress indicator
          Expanded(
            child: Column(
              children: [
                Text(
                  'Kişisel Sorular',
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                LinearProgressIndicator(
                  value: _currentPage / (_questions.length + 2),
                  backgroundColor: AppTheme.surfaceColor,
                  valueColor:
                      AlwaysStoppedAnimation<Color>(AppTheme.primaryColor),
                ),
              ],
            ),
          ),

          // Spacer for alignment
          const SizedBox(width: 48),
        ],
      ),
    );
  }

  Widget _buildQuestionPage(int index, OnboardingState state) {
    final question = _questions[index];

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Question number
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Text(
              '${index + 1}',
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppTheme.primaryColor,
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Question text
          Text(
            question['question'],
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: AppTheme.textPrimary,
              height: 1.4,
            ),
          ),

          const SizedBox(height: 32),

          // Input field based on question type
          if (question['type'] == 'text')
            _buildNameInput(state)
          else if (question['type'] == 'number')
            _buildNumberInput(question['field'], state)
          else if (question['type'] == 'gender')
            _buildGenderSelection(state)
          else if (question['type'] == 'boolean')
            _buildBooleanSelection(state)
          else
            const SizedBox.shrink(),
        ],
      ),
    );
  }

  Widget _buildNameInput(OnboardingState state) {
    return TextField(
      decoration: const InputDecoration(
        hintText: 'Çocuğunuzun adını girin',
      ),
      style: GoogleFonts.poppins(
        fontSize: 16,
        color: AppTheme.textPrimary,
      ),
      textCapitalization: TextCapitalization.words,
      onChanged: (value) {
        ref.read(onboardingViewModelProvider.notifier).updateChildName(value);
      },
      onSubmitted: (_) {
        _nextQuestion();
      },
    );
  }

  Widget _buildNumberInput(String field, OnboardingState state) {
    return TextField(
      decoration: InputDecoration(
        hintText: field == 'age' ? 'Yaşını girin' : 'Kardeş sayısını girin',
      ),
      style: GoogleFonts.poppins(
        fontSize: 16,
        color: AppTheme.textPrimary,
      ),
      keyboardType: TextInputType.number,
      onChanged: (value) {
        if (field == 'age') {
          final age = int.tryParse(value);
          if (age != null) {
            ref.read(onboardingViewModelProvider.notifier).updateChildAge(age);
          }
        } else if (field == 'siblings') {
          final count = int.tryParse(value);
          if (count != null) {
            ref
                .read(onboardingViewModelProvider.notifier)
                .updateSiblingCount(count);
          }
        }
      },
      onSubmitted: (_) {
        _nextQuestion();
      },
    );
  }

  Widget _buildGenderSelection(OnboardingState state) {
    return Column(
      children: [
        _buildGenderOption('Kız', 'Kız', state),
        const SizedBox(height: 12),
        _buildGenderOption('Erkek', 'Erkek', state),
        const SizedBox(height: 12),
        _buildGenderOption('Diğer', 'Diğer', state),
      ],
    );
  }

  Widget _buildGenderOption(String label, String value, OnboardingState state) {
    final isSelected = state.childGender == value;

    return GestureDetector(
      onTap: () {
        ref.read(onboardingViewModelProvider.notifier).updateChildGender(value);
        _nextQuestion();
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected
              ? AppTheme.primaryColor.withOpacity(0.1)
              : AppTheme.surfaceColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? AppTheme.primaryColor : Colors.grey.shade200,
          ),
        ),
        child: Row(
          children: [
            Icon(
              isSelected ? Icons.check_circle : Icons.circle_outlined,
              color:
                  isSelected ? AppTheme.primaryColor : AppTheme.textSecondary,
            ),
            const SizedBox(width: 12),
            Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 16,
                color:
                    isSelected ? AppTheme.primaryColor : AppTheme.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBooleanSelection(OnboardingState state) {
    return Column(
      children: [
        _buildBooleanOption('Evet', true, state),
        const SizedBox(height: 12),
        _buildBooleanOption('Hayır', false, state),
      ],
    );
  }

  Widget _buildBooleanOption(String label, bool value, OnboardingState state) {
    final isSelected = state.attendsSchool == value;

    return GestureDetector(
      onTap: () {
        ref
            .read(onboardingViewModelProvider.notifier)
            .updateAttendsSchool(value);
        _nextQuestion();
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected
              ? AppTheme.primaryColor.withOpacity(0.1)
              : AppTheme.surfaceColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? AppTheme.primaryColor : Colors.grey.shade200,
          ),
        ),
        child: Row(
          children: [
            Icon(
              isSelected ? Icons.check_circle : Icons.circle_outlined,
              color:
                  isSelected ? AppTheme.primaryColor : AppTheme.textSecondary,
            ),
            const SizedBox(width: 12),
            Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 16,
                color:
                    isSelected ? AppTheme.primaryColor : AppTheme.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSocialProofSection(int sectionNumber) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.people_outline,
            size: 64,
            color: AppTheme.primaryColor,
          ),
          const SizedBox(height: 24),
          if (sectionNumber == 1)
            const SocialProofWidget(
              title: '12.000\'den fazla çocuk, duygularını çizerek anlatıyor.',
              icon: Icons.trending_up,
              isPrimary: true,
            )
          else
            const SocialProofWidget(
              title:
                  '12.000 çocuk, çizimleriyle duygusal gelişim yolculuğunda.',
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

  Widget _buildNavigationButtons(OnboardingState state) {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Row(
        children: [
          // Back button
          if (_currentPage > 0)
            TextButton(
              onPressed: () {
                if (_currentPage > 0) {
                  setState(() {
                    _currentPage--;
                    _pageController.previousPage(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                    );
                  });
                } else {
                  ref.read(onboardingViewModelProvider.notifier).previousStep();
                }
              },
              child: Text(
                'Geri',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  color: AppTheme.textSecondary,
                ),
              ),
            ),

          const Spacer(),

          // Next/Continue button
          SizedBox(
            width: 120,
            child: ElevatedButton(
              onPressed:
                  _isCurrentQuestionAnswered(state) ? _nextQuestion : null,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: Text(
                _currentPage >= _questions.length ? 'Devam' : 'İleri',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  bool _isCurrentQuestionAnswered(OnboardingState state) {
    // Social proof sections (index 1 and 4) don't require answers
    if (_currentPage == 1 || _currentPage == 4) {
      return true;
    }

    // Adjust index for social proof sections
    int questionIndex = _currentPage;
    if (questionIndex > 1) questionIndex--;
    if (questionIndex > 4) questionIndex--;

    if (questionIndex < 0 || questionIndex >= _questions.length) {
      return true; // Social proof sections don't require answers
    }

    final question = _questions[questionIndex];

    switch (question['field']) {
      case 'name':
        return state.childName != null && state.childName!.isNotEmpty;
      case 'age':
        return state.childAge != null && state.childAge! > 0;
      case 'gender':
        return state.childGender != null && state.childGender!.isNotEmpty;
      case 'siblings':
        return state.siblingCount != null;
      case 'school':
        return state.attendsSchool != null;
      default:
        return false;
    }
  }

  void _nextQuestion() {
    if (_currentPage < _questions.length + 2) {
      // +2 for social proof sections
      setState(() {
        _currentPage++;
        _pageController.nextPage(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      });
    } else {
      // All questions answered, move to next step
      if (ref.read(onboardingViewModelProvider).isPersonalInfoComplete) {
        ref.read(onboardingViewModelProvider.notifier).nextStep();
      }
    }
  }
}
