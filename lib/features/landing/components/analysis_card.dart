import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:inner_kid/core/theme/theme.dart';

class DrawingAnalysisWidget extends StatefulWidget {
  const DrawingAnalysisWidget({super.key});

  @override
  State<DrawingAnalysisWidget> createState() => _DrawingAnalysisWidgetState();
}

class _DrawingAnalysisWidgetState extends State<DrawingAnalysisWidget>
    with TickerProviderStateMixin {
  final List<Map<String, dynamic>> analysisData = [
    {
      "text":
          "Bireylerin el ele tutuşması, aile bağlarının güçlü olduğuna işaret eder.",
      "icon": Icons.favorite,
      "color": AppTheme.accentColor,
      "isPositive": true,
      "category": "Pozitif Bağ",
    },
    {
      "text":
          "Güneşin resimde yer alması, içsel umut ve güvenlik hissini yansıtabilir.",
      "icon": Icons.wb_sunny,
      "color": AppTheme.warningColor,
      "isPositive": true,
      "category": "Umut",
    },
    {
      "text":
          "Ev figürünün büyük ve merkezi çizilmesi, aileye verilen önemi gösterir.",
      "icon": Icons.home,
      "color": AppTheme.primaryColor,
      "isPositive": true,
      "category": "Aile Odaklı",
    },
    {
      "text":
          "Figürlerin gözlerinin olmaması, duyguların bastırılması veya korkuların ifadesi olabilir.",
      "icon": Icons.visibility_off,
      "color": AppTheme.errorColor,
      "isPositive": false,
      "category": "Dikkat",
    },
    {
      "text":
          "Karakterlerin ayrı köşelere çizilmesi, içsel yalnızlık veya iletişim kopukluğunu gösterebilir.",
      "icon": Icons.groups_outlined,
      "color": AppTheme.errorColor,
      "isPositive": false,
      "category": "Sosyal Mesafe",
    },
  ];

  final List<Map<String, dynamic>> displayedItems = [];
  late AnimationController _progressController;
  late AnimationController _pulseController;
  late Animation<double> _progressAnimation;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _initAnimations();
    _startAnimation();
  }

  void _initAnimations() {
    _progressController = AnimationController(
      duration: Duration(seconds: analysisData.length),
      vsync: this,
    );

    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );

    _progressAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _progressController, curve: Curves.easeInOut),
    );

    _pulseAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _pulseController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _progressController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  void _startAnimation() async {
    _progressController.forward();

    for (var i = 0; i < analysisData.length; i++) {
      await Future.delayed(const Duration(milliseconds: 700));
      if (mounted) {
        setState(() {
          displayedItems.add(analysisData[i]);
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white,
            AppTheme.surfaceColor,
            Colors.white,
          ],
          stops: [0.0, 0.5, 1.0],
        ),
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryColor.withOpacity(0.08),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildHeader(),
          _buildProgressBar(),
          _buildAnalysisItems(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppTheme.primaryColor.withOpacity(0.03),
            AppTheme.secondaryColor.withOpacity(0.02),
          ],
        ),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(28),
          topRight: Radius.circular(28),
        ),
      ),
      child: Row(
        children: [
          // Icon container with pulse animation
          AnimatedBuilder(
            animation: _pulseAnimation,
            builder: (context, child) {
              return Transform.scale(
                scale: _pulseAnimation.value,
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    gradient: AppTheme.primaryGradient,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.primaryColor.withOpacity(0.3),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.psychology_outlined,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
              );
            },
          ),

          const SizedBox(width: 16),

          // Title only
          Expanded(
            child: Text(
              'Psikolojik Analiz',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppTheme.textPrimary,
              ),
            ),
          ),

          // Status indicator
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppTheme.accentColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: AppTheme.accentColor.withOpacity(0.2),
                width: 1,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 6,
                  height: 6,
                  decoration: const BoxDecoration(
                    color: AppTheme.accentColor,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  'Aktif',
                  style: GoogleFonts.poppins(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.accentColor,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Analiz İlerlemesi',
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textSecondary,
                ),
              ),
              AnimatedBuilder(
                animation: _progressAnimation,
                builder: (context, child) {
                  return Text(
                    '${(_progressAnimation.value * 100).toInt()}%',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.primaryColor,
                    ),
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: 8),
          Container(
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(2),
            ),
            child: AnimatedBuilder(
              animation: _progressAnimation,
              builder: (context, child) {
                return FractionallySizedBox(
                  alignment: Alignment.centerLeft,
                  widthFactor: _progressAnimation.value,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: AppTheme.primaryGradient,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnalysisItems() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
      child: Column(
        children: displayedItems.asMap().entries.map((entry) {
          final index = entry.key;
          final item = entry.value;
          final bool isLast = index == displayedItems.length - 1;

          return TweenAnimationBuilder<double>(
            duration: Duration(milliseconds: 600 + (index * 120)),
            tween: Tween(begin: 0.0, end: 1.0),
            builder: (context, value, child) {
              return Opacity(
                opacity: value,
                child: Transform.translate(
                  offset: Offset(0, 20 * (1 - value)),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Timeline indicator (dot + vertical line)
                      Column(
                        children: [
                          // Dot with gradient background & icon
                          Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: item['isPositive']
                                  ? AppTheme.primaryGradient
                                  : const LinearGradient(
                                      colors: [
                                        AppTheme.errorColor,
                                        AppTheme.warningColor,
                                      ],
                                      begin: Alignment.topCenter,
                                      end: Alignment.bottomCenter,
                                    ),
                              boxShadow: [
                                BoxShadow(
                                  color: item['color'].withOpacity(0.25),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Icon(
                              item['icon'],
                              color: Colors.white,
                              size: 18,
                            ),
                          ),
                          // Vertical connector line (omit for the last element)
                          if (!isLast)
                            Container(
                              width: 2,
                              height: 80,
                              color: Colors.grey.shade200,
                            ),
                        ],
                      ),

                      const SizedBox(width: 20),

                      // Card containing the analysis details
                      Expanded(
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 24),
                          padding: const EdgeInsets.all(18),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(
                              color: item['color'].withOpacity(0.12),
                              width: 1,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.04),
                                blurRadius: 12,
                                offset: const Offset(0, 6),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Category chip
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: item['color'].withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Text(
                                  item['category'],
                                  style: GoogleFonts.poppins(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color: item['color'],
                                  ),
                                ),
                              ),
                              const SizedBox(height: 10),
                              // Analysis description
                              Text(
                                item['text'],
                                style: GoogleFonts.poppins(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  height: 1.45,
                                  color: AppTheme.textPrimary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        }).toList(),
      ),
    );
  }
}
