import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:inner_kid/core/models/drawing_analysis.dart';

class DrawingTestsPage extends StatelessWidget {
  const DrawingTestsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: _buildAppBar(context),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            const SizedBox(height: 24),
            _buildTestCards(context),
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      leading: IconButton(
        onPressed: () => Navigator.pop(context),
        icon: const Icon(
          Icons.arrow_back_ios,
          color: Color(0xFF4A5568),
        ),
      ),
      title: Text(
        'Çizim Testleri',
        style: GoogleFonts.nunito(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: const Color(0xFF2D3748),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF667EEA),
            Color(0xFF764BA2),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.psychology,
            color: Colors.white,
            size: 32,
          ),
          const SizedBox(height: 12),
          Text(
            'Çocuğunuzun İç Dünyasını Keşfedin',
            style: GoogleFonts.nunito(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Bilimsel araştırmalara dayalı çizim testleri ile çocuğunuzun duygusal gelişimini takip edin.',
            style: GoogleFonts.nunito(
              fontSize: 14,
              color: Colors.white.withOpacity(0.9),
              height: 1.4,
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 400.ms).slideY(begin: -0.2, duration: 400.ms);
  }

  Widget _buildTestCards(BuildContext context) {
    final tests = [
      _TestInfo(
        type: DrawingTestType.selfPortrait,
        title: 'Kendini Çizme Testi',
        description:
            'Çocuğunuzun öz-algısını ve özgüven düzeyini değerlendirin',
        icon: Icons.person_outline,
        ageRange: '4-12 yaş',
        duration: '10-15 dk',
        difficulty: 'Kolay',
        color: const Color(0xFF667EEA),
        insights: [
          'Benlik kavramı',
          'Özgüven düzeyi',
          'Beden algısı',
          'Duygusal durum',
        ],
      ),
      _TestInfo(
        type: DrawingTestType.familyDrawing,
        title: 'Aile Çizimi Testi',
        description: 'Aile dinamiklerini ve güvenlik hissini analiz edin',
        icon: Icons.family_restroom,
        ageRange: '4-12 yaş',
        duration: '15-20 dk',
        difficulty: 'Kolay',
        color: const Color(0xFF38B2AC),
        insights: [
          'Aile dinamikleri',
          'Güvenlik hissi',
          'Bağlanma stilleri',
          'İlişki kalitesi',
        ],
      ),
      _TestInfo(
        type: DrawingTestType.houseTreePerson,
        title: 'Ev-Ağaç-İnsan Testi',
        description: 'Kişilik yapısını ve çevre algısını keşfedin',
        icon: Icons.home_outlined,
        ageRange: '6-12 yaş',
        duration: '20-25 dk',
        difficulty: 'Orta',
        color: const Color(0xFFED8936),
        insights: [
          'Kişilik yapısı',
          'Çevre algısı',
          'Güvenlik ihtiyaçları',
          'Sembolik düşünce',
        ],
      ),
      _TestInfo(
        type: DrawingTestType.narrativeDrawing,
        title: 'Hikaye Çizimi Testi',
        description: 'Yaratıcılığı ve duygusal işleme becerisini ölçün',
        icon: Icons.auto_stories,
        ageRange: '5-12 yaş',
        duration: '15-30 dk',
        difficulty: 'Orta',
        color: const Color(0xFF9F7AEA),
        insights: [
          'Yaratıcılık',
          'Problem çözme',
          'Duygusal işleme',
          'Anlatım becerileri',
        ],
      ),
      _TestInfo(
        type: DrawingTestType.emotionalStates,
        title: 'Duygusal Durumlar Çizimi',
        description:
            'Mevcut duygusal durumu ve stres faktörlerini değerlendirin',
        icon: Icons.emoji_emotions,
        ageRange: '4-12 yaş',
        duration: '10-15 dk',
        difficulty: 'Kolay',
        color: const Color(0xFFE53E3E),
        insights: [
          'Mevcut duygusal durum',
          'Stres faktörleri',
          'Başa çıkma mekanizmaları',
          'Duygu düzenleme',
        ],
      ),
    ];

    return Column(
      children: tests.map((test) {
        final index = tests.indexOf(test);
        return Padding(
          padding: EdgeInsets.only(bottom: index < tests.length - 1 ? 16 : 0),
          child: _buildTestCard(context, test)
              .animate(delay: (index * 100).ms)
              .slideX(begin: 0.3, duration: 400.ms)
              .fadeIn(duration: 400.ms),
        );
      }).toList(),
    );
  }

  Widget _buildTestCard(BuildContext context, _TestInfo test) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      elevation: 3,
      child: InkWell(
        onTap: () {
          // Navigate to test execution
        },
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: test.color.withOpacity(0.2),
              width: 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: test.color.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      test.icon,
                      color: test.color,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          test.title,
                          style: GoogleFonts.nunito(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF2D3748),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          test.description,
                          style: GoogleFonts.nunito(
                            fontSize: 12,
                            color: const Color(0xFF718096),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Test specs
              Row(
                children: [
                  _buildSpec(Icons.people, test.ageRange),
                  const SizedBox(width: 16),
                  _buildSpec(Icons.schedule, test.duration),
                  const SizedBox(width: 16),
                  _buildSpec(Icons.bar_chart, test.difficulty),
                ],
              ),

              const SizedBox(height: 16),

              // Insights
              Text(
                'Bu testte değerlendirilen alanlar:',
                style: GoogleFonts.nunito(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF4A5568),
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 4,
                children: test.insights.map((insight) {
                  return Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: test.color.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      insight,
                      style: GoogleFonts.nunito(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: test.color,
                      ),
                    ),
                  );
                }).toList(),
              ),

              const SizedBox(height: 16),

              // Start button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    // Navigate to test execution
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: test.color,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    'Teste Başla',
                    style: GoogleFonts.nunito(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSpec(IconData icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          size: 16,
          color: const Color(0xFF718096),
        ),
        const SizedBox(width: 4),
        Text(
          text,
          style: GoogleFonts.nunito(
            fontSize: 12,
            color: const Color(0xFF718096),
          ),
        ),
      ],
    );
  }
}

class _TestInfo {
  final DrawingTestType type;
  final String title;
  final String description;
  final IconData icon;
  final String ageRange;
  final String duration;
  final String difficulty;
  final Color color;
  final List<String> insights;

  _TestInfo({
    required this.type,
    required this.title,
    required this.description,
    required this.icon,
    required this.ageRange,
    required this.duration,
    required this.difficulty,
    required this.color,
    required this.insights,
  });
}
