import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/di/providers.dart';
import '../../../core/models/child_profile.dart';
import '../../auth/models/auth_state.dart';
import '../../auth/viewmodels/auth_viewmodel.dart';

class ProfilePage extends ConsumerWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authViewModelProvider);
    final authViewModel = ref.read(authViewModelProvider.notifier);
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          'Profil',
          style: GoogleFonts.nunito(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF2D3748),
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {
              // Settings
            },
            icon: const Icon(
              Icons.settings_outlined,
              color: Color(0xFF4A5568),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // User Profile Card
            _buildUserProfileCard(authState, authViewModel),

            const SizedBox(height: 24),

            // Children Section
            _buildSectionHeader('Çocuk Profilleri'),
            const SizedBox(height: 12),
            _buildChildrenSection(authState, ref),

            const SizedBox(height: 24),

            // Settings Section
            _buildSectionHeader('Ayarlar'),
            const SizedBox(height: 12),
            _buildSettingsSection(context, authViewModel),

            const SizedBox(height: 120), // Space for bottom nav
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        title,
        style: GoogleFonts.nunito(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: const Color(0xFF2D3748),
        ),
      ),
    );
  }

  Widget _buildUserProfileCard(
      AuthState authState, AuthViewModel authViewModel) {
    final userProfile = authState.userProfile;
    final isLoading = authState.isLoading;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Avatar
          Container(
            width: 80,
            height: 80,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: const Icon(
              Icons.person,
              size: 40,
              color: Colors.white,
            ),
          ),
          const SizedBox(width: 16),

          // User Info
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        userProfile?.name ?? 'Kullanıcı',
                        style: GoogleFonts.nunito(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF2D3748),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        userProfile?.email ?? 'email@example.com',
                        style: GoogleFonts.nunito(
                          fontSize: 14,
                          color: const Color(0xFF718096),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFF667EEA).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          userProfile?.isSubscriptionActive == true
                              ? '${userProfile?.subscriptionTier.toUpperCase()} Üye'
                              : 'Ücretsiz Üye',
                          style: GoogleFonts.nunito(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF667EEA),
                          ),
                        ),
                      ),
                    ],
                  ),
          ),

          // Edit Button
          IconButton(
            onPressed: () {
              // Edit profile
            },
            icon: const Icon(
              Icons.edit_outlined,
              color: Color(0xFF667EEA),
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 400.ms).slideY(begin: -0.2);
  }

  Widget _buildChildrenSection(AuthState authState, WidgetRef ref) {
    if (authState.userProfile == null) {
      return const Center(child: Text('Kullanıcı girişi yapılmamış'));
    }

    return FutureBuilder<List<ChildProfile>>(
      future: ref
          .read(firestoreServiceProvider)
          .getChildren(authState.userProfile!.id),
      builder: (context, snapshot) {
        return Column(
          children: [
            // Add Child Button
            _buildAddChildCard(),
            const SizedBox(height: 12),

            // Loading state
            if (snapshot.connectionState == ConnectionState.waiting)
              const Center(child: CircularProgressIndicator())

            // Error state
            else if (snapshot.hasError)
              Center(
                child: Text(
                  'Çocuk profilleri yüklenirken hata oluştu',
                  style: GoogleFonts.nunito(color: Colors.red),
                ),
              )

            // Empty state
            else if (!snapshot.hasData || snapshot.data!.isEmpty)
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.grey.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  'Henüz çocuk profili eklenmemiş.\nYukarıdaki butona tıklayarak ilk profili oluşturun.',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.nunito(
                    color: const Color(0xFF718096),
                    fontSize: 14,
                  ),
                ),
              )

            // Children list
            else
              ...snapshot.data!.map((child) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _buildChildCardFromProfile(child, ref),
                  )),
          ],
        );
      },
    );
  }

  Widget _buildAddChildCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFF667EEA).withOpacity(0.3),
          width: 2,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFF667EEA).withOpacity(0.1),
            ),
            child: const Icon(
              Icons.add,
              color: Color(0xFF667EEA),
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Yeni Çocuk Ekle',
                  style: GoogleFonts.nunito(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF667EEA),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Çocuğunuzun profilini oluşturun',
                  style: GoogleFonts.nunito(
                    fontSize: 12,
                    color: const Color(0xFF718096),
                  ),
                ),
              ],
            ),
          ),
          const Icon(
            Icons.arrow_forward_ios,
            color: Color(0xFF667EEA),
            size: 16,
          ),
        ],
      ),
    ).animate().fadeIn(duration: 400.ms, delay: 100.ms).slideX(begin: -0.2);
  }

  Widget _buildChildCard({
    required String name,
    required int age,
    required String gender,
    required int analysisCount,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Child Avatar
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: gender == 'Erkek'
                  ? Colors.blue.withOpacity(0.1)
                  : Colors.pink.withOpacity(0.1),
            ),
            child: Icon(
              gender == 'Erkek' ? Icons.boy : Icons.girl,
              color: gender == 'Erkek' ? Colors.blue : Colors.pink,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),

          // Child Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: GoogleFonts.nunito(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF2D3748),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '$age yaş • $analysisCount analiz',
                  style: GoogleFonts.nunito(
                    fontSize: 12,
                    color: const Color(0xFF718096),
                  ),
                ),
              ],
            ),
          ),

          // More Button
          IconButton(
            onPressed: () {
              // Child details
            },
            icon: const Icon(
              Icons.more_vert,
              color: Color(0xFF718096),
              size: 20,
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 400.ms, delay: 200.ms).slideX(begin: -0.2);
  }

  Widget _buildChildCardFromProfile(ChildProfile child, WidgetRef ref) {
    return FutureBuilder<int>(
      future:
          ref.read(firestoreServiceProvider).getAnalysisCountForChild(child.id),
      builder: (context, snapshot) {
        final analysisCount = snapshot.data ?? 0;

        return _buildChildCard(
          name: child.name,
          age: child.ageInYears,
          gender: child.gender,
          analysisCount: analysisCount,
        );
      },
    );
  }

  Widget _buildSettingsSection(
      BuildContext context, AuthViewModel authViewModel) {
    return Column(
      children: [
        _buildSettingItem(
          icon: Icons.notifications_outlined,
          title: 'Bildirimler',
          subtitle: 'Bildirim ayarlarını yönetin',
          onTap: () {},
        ),
        const SizedBox(height: 12),
        _buildSettingItem(
          icon: Icons.privacy_tip_outlined,
          title: 'Gizlilik',
          subtitle: 'Gizlilik ve güvenlik ayarları',
          onTap: () {},
        ),
        const SizedBox(height: 12),
        _buildSettingItem(
          icon: Icons.help_outline,
          title: 'Yardım',
          subtitle: 'Sık sorulan sorular ve destek',
          onTap: () {},
        ),
        const SizedBox(height: 12),
        _buildSettingItem(
          icon: Icons.logout,
          title: 'Çıkış Yap',
          subtitle: 'Hesabınızdan çıkış yapın',
          onTap: () async {
            // Show confirmation dialog
            final confirmed = await showDialog<bool>(
              context: context,
              builder: (context) => AlertDialog(
                title: Text(
                  'Çıkış Yap',
                  style: GoogleFonts.nunito(fontWeight: FontWeight.bold),
                ),
                content: Text(
                  'Hesabınızdan çıkış yapmak istediğinizden emin misiniz?',
                  style: GoogleFonts.nunito(),
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(false),
                    child: Text(
                      'İptal',
                      style: GoogleFonts.nunito(color: Colors.grey),
                    ),
                  ),
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(true),
                    child: Text(
                      'Çıkış Yap',
                      style: GoogleFonts.nunito(color: Colors.red),
                    ),
                  ),
                ],
              ),
            );

            if (confirmed == true) {
              await authViewModel.signOut();
            }
          },
          isDestructive: true,
        ),
      ],
    );
  }

  Widget _buildSettingItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        leading: Icon(
          icon,
          color: isDestructive ? Colors.red : const Color(0xFF667EEA),
        ),
        title: Text(
          title,
          style: GoogleFonts.nunito(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: isDestructive ? Colors.red : const Color(0xFF2D3748),
          ),
        ),
        subtitle: Text(
          subtitle,
          style: GoogleFonts.nunito(
            fontSize: 12,
            color: const Color(0xFF718096),
          ),
        ),
        trailing: const Icon(
          Icons.arrow_forward_ios,
          size: 16,
          color: Color(0xFF718096),
        ),
        onTap: onTap,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    ).animate().fadeIn(duration: 400.ms, delay: 300.ms).slideX(begin: 0.2);
  }
}
