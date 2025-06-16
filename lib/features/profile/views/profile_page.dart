import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
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
            _buildUserProfileCard(),

            const SizedBox(height: 24),

            // Children Section
            _buildSectionHeader('Çocuk Profilleri'),
            const SizedBox(height: 12),
            _buildChildrenSection(),

            const SizedBox(height: 24),

            // Settings Section
            _buildSectionHeader('Ayarlar'),
            const SizedBox(height: 12),
            _buildSettingsSection(),

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

  Widget _buildUserProfileCard() {
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Kullanıcı Adı',
                  style: GoogleFonts.nunito(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF2D3748),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'kullanici@email.com',
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
                    'Premium Üye',
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

  Widget _buildChildrenSection() {
    return Column(
      children: [
        // Add Child Button
        _buildAddChildCard(),
        const SizedBox(height: 12),

        // Existing Children
        _buildChildCard(
          name: 'Ahmet',
          age: 8,
          gender: 'Erkek',
          analysisCount: 5,
        ),
        const SizedBox(height: 12),
        _buildChildCard(
          name: 'Ayşe',
          age: 6,
          gender: 'Kız',
          analysisCount: 3,
        ),
      ],
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

  Widget _buildSettingsSection() {
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
          onTap: () {},
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
