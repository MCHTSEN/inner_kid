import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';

class ShareOptionsWidget extends StatelessWidget {
  const ShareOptionsWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle bar
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          const SizedBox(height: 20),

          // Title
          Text(
            'Sonuçları Paylaş',
            style: GoogleFonts.nunito(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF2D3748),
            ),
          ),

          const SizedBox(height: 8),

          Text(
            'Analiz sonuçlarını nasıl paylaşmak istersiniz?',
            style: GoogleFonts.nunito(
              fontSize: 14,
              color: const Color(0xFF718096),
            ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 24),

          // Share options
          Column(
            children: [
              _buildShareOption(
                icon: Icons.picture_as_pdf,
                title: 'PDF Raporu',
                subtitle: 'Detaylı raporu PDF olarak paylaş',
                color: Colors.red,
                onTap: () => _shareAsPDF(context),
              ),
              const SizedBox(height: 12),
              _buildShareOption(
                icon: Icons.image,
                title: 'Görsel Özet',
                subtitle: 'Özet görseli olarak paylaş',
                color: Colors.blue,
                onTap: () => _shareAsImage(context),
              ),
              const SizedBox(height: 12),
              _buildShareOption(
                icon: Icons.link,
                title: 'Bağlantı Linki',
                subtitle: 'Sonuçları link olarak paylaş',
                color: Colors.green,
                onTap: () => _shareAsLink(context),
              ),
              const SizedBox(height: 12),
              _buildShareOption(
                icon: Icons.email,
                title: 'E-posta Gönder',
                subtitle: 'E-posta ile paylaş',
                color: Colors.orange,
                onTap: () => _shareViaEmail(context),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Cancel button
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () => Navigator.of(context).pop(),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                'İptal',
                style: GoogleFonts.nunito(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),

          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Widget _buildShareOption({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.05),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: color.withOpacity(0.2),
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: color,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.nunito(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF2D3748),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: GoogleFonts.nunito(
                      fontSize: 14,
                      color: const Color(0xFF718096),
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              color: color,
              size: 16,
            ),
          ],
        ),
      ),
    ).animate().slideX(delay: 100.ms);
  }

  void _shareAsPDF(BuildContext context) {
    Navigator.of(context).pop();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('PDF raporu hazırlanıyor...'),
        backgroundColor: Colors.green,
      ),
    );

    // TODO: Implement PDF sharing
  }

  void _shareAsImage(BuildContext context) {
    Navigator.of(context).pop();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Görsel özet hazırlanıyor...'),
        backgroundColor: Colors.blue,
      ),
    );

    // TODO: Implement image sharing
  }

  void _shareAsLink(BuildContext context) {
    Navigator.of(context).pop();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Paylaşım linki oluşturuluyor...'),
        backgroundColor: Colors.green,
      ),
    );

    // TODO: Implement link sharing
  }

  void _shareViaEmail(BuildContext context) {
    Navigator.of(context).pop();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('E-posta uygulaması açılıyor...'),
        backgroundColor: Colors.orange,
      ),
    );

    // TODO: Implement email sharing
  }
}
