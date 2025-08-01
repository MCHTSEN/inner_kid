import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:inner_kid/core/theme/theme.dart';

import '../viewmodels/onboarding_viewmodel.dart';

class PersonalInfoForm extends ConsumerStatefulWidget {
  const PersonalInfoForm({super.key});

  @override
  ConsumerState<PersonalInfoForm> createState() => _PersonalInfoFormState();
}

class _PersonalInfoFormState extends ConsumerState<PersonalInfoForm> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _ageController = TextEditingController();
  String? _selectedGender;
  int? _siblingCount;
  bool? _attendsSchool;

  @override
  void initState() {
    super.initState();
    _loadExistingData();
  }

  void _loadExistingData() {
    final state = ref.read(onboardingViewModelProvider);
    if (state.childName != null) {
      _nameController.text = state.childName!;
    }
    if (state.childAge != null) {
      _ageController.text = state.childAge.toString();
    }
    _selectedGender = state.childGender;
    _siblingCount = state.siblingCount;
    _attendsSchool = state.attendsSchool;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _ageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Child Name
          _buildTextField(
            controller: _nameController,
            label: 'Çocuğunuzun Adı',
            hint: 'Örn: Ahmet',
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Lütfen çocuğunuzun adını girin';
              }
              return null;
            },
            onChanged: (value) {
              ref
                  .read(onboardingViewModelProvider.notifier)
                  .updateChildName(value);
            },
          ),

          const SizedBox(height: 24),

          // Child Age
          _buildTextField(
            controller: _ageController,
            label: 'Yaşı',
            hint: 'Örn: 5',
            keyboardType: TextInputType.number,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Lütfen yaşını girin';
              }
              final age = int.tryParse(value);
              if (age == null || age < 1 || age > 18) {
                return 'Geçerli bir yaş girin (1-18)';
              }
              return null;
            },
            onChanged: (value) {
              final age = int.tryParse(value);
              if (age != null) {
                ref
                    .read(onboardingViewModelProvider.notifier)
                    .updateChildAge(age);
              }
            },
          ),

          const SizedBox(height: 24),

          // Gender Selection
          Text(
            'Cinsiyeti',
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: _buildGenderOption('Erkek', 'male'),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildGenderOption('Kız', 'female'),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Sibling Count
          Text(
            'Kardeş Sayısı',
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          _buildSiblingCountSelector(),

          const SizedBox(height: 24),

          // School Attendance
          Text(
            'Okula Gidiyor mu?',
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: _buildSchoolOption('Evet', true),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildSchoolOption('Hayır', false),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
    void Function(String)? onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppTheme.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          validator: validator,
          onChanged: onChanged,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: GoogleFonts.poppins(
              color: AppTheme.textSecondary,
            ),
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildGenderOption(String label, String value) {
    final isSelected = _selectedGender == value;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedGender = value;
        });
        ref.read(onboardingViewModelProvider.notifier).updateChildGender(value);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.primaryColor : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppTheme.primaryColor : AppTheme.textTertiary,
          ),
        ),
        child: Center(
          child: Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: isSelected ? Colors.white : AppTheme.textPrimary,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSiblingCountSelector() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.textTertiary),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<int>(
          value: _siblingCount,
          isExpanded: true,
          hint: Text(
            'Seçiniz',
            style: GoogleFonts.poppins(color: AppTheme.textSecondary),
          ),
          items: List.generate(6, (index) {
            return DropdownMenuItem(
              value: index,
              child: Text(
                index.toString(),
                style: GoogleFonts.poppins(color: AppTheme.textPrimary),
              ),
            );
          }),
          onChanged: (value) {
            setState(() {
              _siblingCount = value;
            });
            if (value != null) {
              ref
                  .read(onboardingViewModelProvider.notifier)
                  .updateSiblingCount(value);
            }
          },
        ),
      ),
    );
  }

  Widget _buildSchoolOption(String label, bool value) {
    final isSelected = _attendsSchool == value;

    return GestureDetector(
      onTap: () {
        setState(() {
          _attendsSchool = value;
        });
        ref
            .read(onboardingViewModelProvider.notifier)
            .updateAttendsSchool(value);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.primaryColor : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppTheme.primaryColor : AppTheme.textTertiary,
          ),
        ),
        child: Center(
          child: Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: isSelected ? Colors.white : AppTheme.textPrimary,
            ),
          ),
        ),
      ),
    );
  }
}
