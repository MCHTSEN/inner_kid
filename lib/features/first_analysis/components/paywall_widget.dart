import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:inner_kid/core/theme/theme.dart';

/// Paywall widget for premium analysis features
class PaywallWidget extends ConsumerStatefulWidget {
  final VoidCallback? onPaymentSuccess;
  final VoidCallback? onDismiss;

  const PaywallWidget({
    super.key,
    this.onPaymentSuccess,
    this.onDismiss,
  });

  @override
  ConsumerState<PaywallWidget> createState() => _PaywallWidgetState();
}

class _PaywallWidgetState extends ConsumerState<PaywallWidget>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _slideAnimation;
  late Animation<double> _fadeAnimation;

  bool _isProcessingPayment = false;
  int _selectedPlanIndex = 1; // Default to middle plan

  final List<PricingPlan> _plans = [
    const PricingPlan(
      title: 'Temel',
      price: '₺29',
      period: '/ay',
      features: [
        'Temel analiz raporu',
        'Email desteği',
        '3 analiz/ay',
      ],
      isPopular: false,
    ),
    const PricingPlan(
      title: 'Popüler',
      price: '₺49',
      period: '/ay',
      features: [
        'Detaylı analiz raporu',
        'Gelişim önerileri',
        'Öncelikli destek',
        'Sınırsız analiz',
        'PDF rapor çıktısı',
      ],
      isPopular: true,
    ),
    const PricingPlan(
      title: 'Premium',
      price: '₺79',
      period: '/ay',
      features: [
        'Kapsamlı analiz raporu',
        'Uzman danışmanlığı',
        '7/24 destek',
        'Sınırsız analiz',
        'PDF + Video rapor',
        'Kişisel gelişim planı',
      ],
      isPopular: false,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _initAnimations();
  }

  void _initAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _slideAnimation = Tween<double>(
      begin: 1.0,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.3, 1.0, curve: Curves.easeOut),
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
    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: AnimatedBuilder(
        animation: _animationController,
        builder: (context, child) {
          return Transform.translate(
            offset: Offset(0, _slideAnimation.value * 50),
            child: Opacity(
              opacity: _fadeAnimation.value,
              child: Column(
                children: [
                  // Header
                  _buildHeader(),

                  // Content
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        spacing: 32,
                        children: [
                          // Hero section
                          _buildHeroSection(),


                          // Pricing plans
                          _buildPricingPlans(),


                          // Features comparison
                          _buildFeaturesSection(),


                          // Payment button
                          _buildPaymentButton(),

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
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          const Spacer(),
          Text(
            'Premium Analiz',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppTheme.textPrimary,
            ),
          ),
          const Spacer(),
          IconButton(
            onPressed: widget.onDismiss,
            icon: const Icon(Icons.close, color: AppTheme.textSecondary),
          ),
        ],
      ),
    );
  }

  Widget _buildHeroSection() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: AppTheme.primaryGradient,
            borderRadius: BorderRadius.circular(20),
          ),
          child: const Icon(
            Icons.psychology_outlined,
            color: Colors.white,
            size: 48,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'Detaylı Analiz Sonuçları',
          style: GoogleFonts.poppins(
            fontSize: 24,
            fontWeight: FontWeight.w700,
            color: AppTheme.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Uzman psikologlar tarafından hazırlanan kapsamlı analiz raporları ile çocuğunuzun gelişimini destekleyin.',
          textAlign: TextAlign.center,
          style: GoogleFonts.poppins(
            fontSize: 14,
            color: AppTheme.textSecondary,
            height: 1.5,
          ),
        ),
      ],
    );
  }

  Widget _buildPricingPlans() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Planları Seçin',
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: AppTheme.textPrimary,
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 320,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: _plans.length,
            itemBuilder: (context, index) {
              return _buildPricingCard(index);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildPricingCard(int index) {
    final plan = _plans[index];
    final isSelected = _selectedPlanIndex == index;

    return GestureDetector(
      onTap: () => setState(() => _selectedPlanIndex = index),
      child: Container(
        width: 180,
        margin: const EdgeInsets.only(right: 16),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isSelected
              ? AppTheme.primaryColor.withOpacity(0.1)
              : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? AppTheme.primaryColor : Colors.grey.shade200,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppTheme.primaryColor.withOpacity(0.2),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ]
              : [],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Popular badge
            if (plan.isPopular)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  gradient: AppTheme.primaryGradient,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'EN POPÜLER',
                  style: GoogleFonts.poppins(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),

            if (plan.isPopular) const SizedBox(height: 12),

            // Plan title
            Text(
              plan.title,
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppTheme.textPrimary,
              ),
            ),

            const SizedBox(height: 8),

            // Price
            Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text(
                  plan.price,
                  style: GoogleFonts.poppins(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.primaryColor,
                  ),
                ),
                Text(
                  plan.period,
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: AppTheme.textSecondary,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Features
            ...plan.features.map((feature) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.check_circle,
                        color: Colors.green,
                        size: 16,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          feature,
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            color: AppTheme.textSecondary,
                          ),
                        ),
                      ),
                    ],
                  ),
                )),
          ],
        ),
      ),
    );
  }

  Widget _buildFeaturesSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Premium ile Neler Kazanırsınız?',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          ...[
            'Uzman psikolog yorumları',
            'Detaylı gelişim önerileri',
            'Kişiselleştirilmiş aktiviteler',
            'İlerleme takibi',
            'PDF ve video raporlar',
          ].map((feature) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        gradient: AppTheme.primaryGradient,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.star,
                        color: Colors.white,
                        size: 16,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        feature,
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }

  Widget _buildPaymentButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _isProcessingPayment ? null : _processPayment,
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 18),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: _isProcessingPayment
            ? Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'İşlem yapılıyor...',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.payment, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    'Analiz Sonuçlarını Gör - ${_plans[_selectedPlanIndex].price}',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  void _processPayment() async {
    setState(() => _isProcessingPayment = true);

    // Simulate payment processing
    await Future.delayed(const Duration(seconds: 2));

    setState(() => _isProcessingPayment = false);

    // Simulate successful payment
    widget.onPaymentSuccess?.call();
  }
}

/// Pricing plan model
class PricingPlan {
  final String title;
  final String price;
  final String period;
  final List<String> features;
  final bool isPopular;

  const PricingPlan({
    required this.title,
    required this.price,
    required this.period,
    required this.features,
    this.isPopular = false,
  });
}
