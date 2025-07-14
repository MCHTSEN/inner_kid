import 'dart:io';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:inner_kid/core/theme/theme.dart';

import '../first_analysis/components/paywall_widget.dart';

/// A/B Testing configuration for success header messages
///
/// This enum defines different message variants for A/B testing
/// to optimize user engagement and conversion rates.
enum SuccessHeaderVariant {
  /// Emotional revelation message
  emotional(
      'Çocuğunuzun çiziminde gizli kalan duygular, artık görünür hale geliyor.'),

  /// Scientific insight message
  scientific('Bilimsel analiz ile çocuğunuzun iç dünyasını keşfedin.'),

  /// Development focused message
  development(
      'Çocuğunuzun gelişim yolculuğunda size rehber olacak önemli ipuçları.'),

  /// Achievement focused message
  achievement('Çocuğunuzun yaratıcı potansiyeli ortaya çıktı!');

  const SuccessHeaderVariant(this.message);

  /// The message text to display
  final String message;

  /// Get a variant based on user ID or other criteria for A/B testing
  ///
  /// This can be replaced with a more sophisticated A/B testing framework
  static SuccessHeaderVariant getVariantForUser({String? userId}) {
    // Simple hash-based selection for demonstration
    // In production, use proper A/B testing tools like Firebase Remote Config
    final hash = userId?.hashCode ?? DateTime.now().millisecondsSinceEpoch;
    const variants = SuccessHeaderVariant.values;
    return variants[hash.abs() % variants.length];
  }
}

/// Analysis results page showing detailed psychological insights with premium gating
///
/// Features:
/// - Blurred content with premium overlay for non-premium users
/// - Clickable blur area that triggers paywall
/// - Premium-gated action buttons in app bar
/// - A/B testing support for success header messages
/// - Smooth animations and transitions
class AnalysisResultsPage extends ConsumerStatefulWidget {
  final File? analyzedImage;
  final Map<String, String>? analysisData;
  final bool isBlurred;
  final VoidCallback? onPremiumUnlock;
  final String? userId; // For A/B testing
  final SuccessHeaderVariant? variant; // Override for testing

  const AnalysisResultsPage({
    super.key,
    this.analyzedImage,
    this.analysisData,
    this.isBlurred = false,
    this.onPremiumUnlock,
    this.userId,
    this.variant,
  });

  @override
  ConsumerState<AnalysisResultsPage> createState() =>
      _AnalysisResultsPageState();
}

class _AnalysisResultsPageState extends ConsumerState<AnalysisResultsPage>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late SuccessHeaderVariant _headerVariant;

  bool _isPremiumUnlocked = false;

  @override
  void initState() {
    super.initState();
    _initAnimations();
    _initABTesting();
    _isPremiumUnlocked = !widget.isBlurred;

    // Show paywall after content is displayed if blurred
    if (widget.isBlurred) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Future.delayed(const Duration(seconds: 2), () {
          if (mounted) {
            _showPaywall();
          }
        });
      });
    }
  }

  /// Initialize A/B testing variant for success header
  void _initABTesting() {
    _headerVariant = widget.variant ??
        SuccessHeaderVariant.getVariantForUser(userId: widget.userId);
  }

  void _initAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.3, 1.0, curve: Curves.easeOutCubic),
    ));

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFF8FAFC),
              Color(0xFFE2E8F0),
            ],
          ),
        ),
        child: SafeArea(
          child: AnimatedBuilder(
            animation: _animationController,
            builder: (context, child) {
              return FadeTransition(
                opacity: _fadeAnimation,
                child: SlideTransition(
                  position: _slideAnimation,
                  child: Column(
                    children: [
                      // App Bar
                      _buildAppBar(),

                      // Content
                      Expanded(
                        child: SingleChildScrollView(
                          physics: const BouncingScrollPhysics(),
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            children: [
                              // Success Header (always visible)
                              _buildSuccessHeader(),

                              const SizedBox(height: 24),

                              // Premium gated content
                              _buildBlurWrapper(
                                child: Column(
                                  children: [
                                    // Analysis Overview
                                    _buildAnalysisOverview(),

                                    const SizedBox(height: 24),

                                    // Psychological Insights
                                    _buildPsychologicalInsights(),

                                    const SizedBox(height: 24),

                                    // Development Recommendations
                                    _buildDevelopmentRecommendations(),

                                    const SizedBox(height: 24),

                                    // Activities & Games
                                    _buildActivitiesSection(),

                                    const SizedBox(height: 24),

                                    // Progress Tracking
                                    _buildProgressTracking(),

                                    const SizedBox(height: 32),

                                    // Action Buttons
                                    _buildActionButtons(),
                                  ],
                                ),
                              ),

                              const SizedBox(height: 40),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        children: [
          Expanded(
            child: Text(
              'Analiz Sonuçları',
              style: GoogleFonts.poppins(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: AppTheme.textPrimary,
              ),
            ),
          ),
          // Premium-gated share button
          _buildPremiumActionButton(
            icon: Icons.share,
            onPressed: _isPremiumUnlocked ? _shareResults : _showPaywall,
            tooltip:
                _isPremiumUnlocked ? 'Sonuçları Paylaş' : 'Premium Gerekli',
          ),
          // Premium-gated download button
          _buildPremiumActionButton(
            icon: Icons.download,
            onPressed: _isPremiumUnlocked ? _downloadReport : _showPaywall,
            tooltip: _isPremiumUnlocked ? 'Raporu İndir' : 'Premium Gerekli',
          ),
        ],
      ),
    );
  }

  /// Build premium-gated action button with visual feedback
  ///
  /// Shows different states for premium and non-premium users:
  /// - Active state for premium users
  /// - Dimmed state with lock icon overlay for non-premium users
  Widget _buildPremiumActionButton({
    required IconData icon,
    required VoidCallback onPressed,
    required String tooltip,
  }) {
    return Tooltip(
      message: tooltip,
      child: Stack(
        children: [
          IconButton(
            onPressed: onPressed,
            icon: Icon(
              icon,
              color: _isPremiumUnlocked
                  ? AppTheme.textSecondary
                  : AppTheme.textSecondary.withOpacity(0.4),
            ),
          ),
          // Lock overlay for non-premium users
          if (!_isPremiumUnlocked)
            Positioned(
              right: 0,
              bottom: 0,
              child: Container(
                padding: const EdgeInsets.all(2),
                decoration: const BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.lock,
                  size: 12,
                  color: Colors.white,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSuccessHeader() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.green.shade50,
            Colors.green.shade100.withOpacity(0.3),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.green.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.green.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              color: Colors.green,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.psychology_outlined,
              color: Colors.white,
              size: 32,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Analiz Tamamlandı!',
            style: GoogleFonts.poppins(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: Colors.green.shade700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _headerVariant.message,
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: Colors.green.shade600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnalysisOverview() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  gradient: AppTheme.primaryGradient,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(
                  Icons.analytics_outlined,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Analiz Özeti',
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    Text(
                      'Çizim analizi sonuçları',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // Analysis Image
          if (widget.analyzedImage != null)
            Container(
              height: 200,
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.file(
                  widget.analyzedImage!,
                  fit: BoxFit.cover,
                ),
              ),
            ),

          const SizedBox(height: 20),

          // Key Metrics
          Row(
            children: [
              Expanded(
                  child: _buildMetricCard('Yaratıcılık', '92%', Colors.purple)),
              const SizedBox(width: 12),
              Expanded(
                  child:
                      _buildMetricCard('Duygusal İfade', '87%', Colors.blue)),
              const SizedBox(width: 12),
              Expanded(child: _buildMetricCard('Gelişim', '94%', Colors.green)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMetricCard(String title, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              fontSize: 12,
              color: AppTheme.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPsychologicalInsights() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Psikolojik Değerlendirme',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          _buildInsightCard(
            Icons.favorite,
            Colors.red,
            'Duygusal Gelişim',
            'Çocuğunuz duygularını sağlıklı bir şekilde ifade edebiliyor. Çizimlerinde pozitif duygular öne çıkıyor.',
          ),
          _buildInsightCard(
            Icons.psychology,
            Colors.purple,
            'Yaratıcı Düşünce',
            'Hayal gücü oldukça gelişmiş. Renk kullanımı ve çizim detayları yaratıcılığının göstergesi.',
          ),
          _buildInsightCard(
            Icons.groups,
            Colors.blue,
            'Sosyal Gelişim',
            'Çizimlerinde aile ve arkadaş figürleri sosyal bağlarının güçlü olduğunu gösteriyor.',
          ),
        ],
      ),
    );
  }

  Widget _buildInsightCard(
      IconData icon, Color color, String title, String description) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: Colors.white,
              size: 20,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: AppTheme.textSecondary,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDevelopmentRecommendations() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Gelişim Önerileri',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          ...[
            'Yaratıcılığını desteklemek için farklı sanat malzemeleri sunun',
            'Hikaye anlatımı ile hayal gücünü geliştirin',
            'Grup aktiviteleri ile sosyal becerilerini güçlendirin',
            'Duygusal ifade için müzik ve dans aktiviteleri ekleyin',
          ].asMap().entries.map((entry) {
            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              child: Row(
                children: [
                  Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      gradient: AppTheme.primaryGradient,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: Text(
                        '${entry.key + 1}',
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      entry.value,
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: AppTheme.textPrimary,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildActivitiesSection() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Önerilen Aktiviteler',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 120,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: 4,
              itemBuilder: (context, index) {
                final activities = [
                  {
                    'title': 'Renk Karışımı',
                    'icon': Icons.palette,
                    'color': Colors.purple
                  },
                  {
                    'title': 'Hikaye Yazma',
                    'icon': Icons.book,
                    'color': Colors.blue
                  },
                  {
                    'title': 'Müzik Yapma',
                    'icon': Icons.music_note,
                    'color': Colors.green
                  },
                  {
                    'title': 'Rol Yapma',
                    'icon': Icons.theater_comedy,
                    'color': Colors.orange
                  },
                ];

                final activity = activities[index];

                return Container(
                  width: 100,
                  margin: const EdgeInsets.only(right: 16),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: (activity['color'] as Color).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: (activity['color'] as Color).withOpacity(0.3),
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        activity['icon'] as IconData,
                        color: activity['color'] as Color,
                        size: 32,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        activity['title'] as String,
                        textAlign: TextAlign.center,
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressTracking() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'İlerleme Takibi',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Gelecek analiz tarihi: ${DateTime.now().add(const Duration(days: 30)).day}/${DateTime.now().add(const Duration(days: 30)).month}/${DateTime.now().add(const Duration(days: 30)).year}',
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: AppTheme.textSecondary,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.notifications_active,
                  color: AppTheme.primaryColor,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Bir sonraki analiz için hatırlatma alacaksınız',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: AppTheme.primaryColor,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _downloadReport,
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 18),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.file_download, size: 20),
                const SizedBox(width: 8),
                Text(
                  'PDF Raporu İndir',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 18),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              side: const BorderSide(color: AppTheme.primaryColor),
            ),
            child: Text(
              'Yeni Analiz Başlat',
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppTheme.primaryColor,
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _shareResults() {
    // Implement sharing functionality
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Paylaşım özelliği yakında eklenecek',
          style: GoogleFonts.poppins(),
        ),
        backgroundColor: AppTheme.primaryColor,
      ),
    );
  }

  void _downloadReport() {
    // Implement download functionality
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Rapor indiriliyor...',
          style: GoogleFonts.poppins(),
        ),
        backgroundColor: Colors.green,
      ),
    );
  }

  /// Build blur wrapper with clickable area for premium content
  ///
  /// Features:
  /// - ImageFilter.blur for content obscuring
  /// - Clickable overlay that triggers paywall
  /// - Visual premium indicator with call-to-action
  /// - Gradient overlay for better readability
  Widget _buildBlurWrapper({required Widget child}) {
    if (_isPremiumUnlocked) {
      return child;
    }

    return GestureDetector(
      onTap: _showPaywall, // Make entire blur area clickable
      child: Stack(
        children: [
          // Blurred content
          ImageFiltered(
            imageFilter: ImageFilter.blur(sigmaX: 3.0, sigmaY: 3.0),
            child: child,
          ),

          // Clickable premium overlay
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.white.withOpacity(0.3),
                    Colors.white.withOpacity(0.8),
                  ],
                ),
              ),
              child: Center(
                child: Container(
                  padding: const EdgeInsets.all(20),
                  margin: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Premium icon with pulse animation
                      TweenAnimationBuilder(
                        duration: const Duration(seconds: 2),
                        tween: Tween<double>(begin: 0.8, end: 1.2),
                        curve: Curves.easeInOut,
                        builder: (context, double scale, child) {
                          return Transform.scale(
                            scale: scale,
                            child: const Icon(
                              Icons.lock_outline,
                              size: 48,
                              color: AppTheme.primaryColor,
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Premium İçerik',
                        style: GoogleFonts.poppins(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Detaylı analiz sonuçlarını görmek için premium\'a geçin',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      // Clickable hint
                      Text(
                        'Dokunarak premium\'a geçin',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: AppTheme.primaryColor,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: _showPaywall,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 32,
                            vertical: 12,
                          ),
                        ),
                        child: Text(
                          'Premium\'a Geç',
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Show paywall modal with payment options
  ///
  /// Handles premium unlock and state updates
  void _showPaywall() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => PaywallWidget(
        onPaymentSuccess: () {
          Navigator.pop(context); // Close paywall
          setState(() {
            _isPremiumUnlocked = true;
          });
          // Trigger parent callback if provided
          if (widget.onPremiumUnlock != null) {
            widget.onPremiumUnlock!();
          }
          // Show success feedback
          _showPremiumUnlockFeedback();
        },
        onDismiss: () => Navigator.pop(context),
      ),
    );
  }

  /// Show success feedback when premium is unlocked
  void _showPremiumUnlockFeedback() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white),
            const SizedBox(width: 8),
            Text(
              'Premium aktif! Tüm özellikler açıldı.',
              style: GoogleFonts.poppins(),
            ),
          ],
        ),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 3),
      ),
    );
  }
}
