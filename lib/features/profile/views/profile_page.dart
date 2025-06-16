import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

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
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.person_outline,
              size: 100,
              color: Color(0xFF667EEA),
            ),
            SizedBox(height: 20),
            Text(
              'Profil Sayfası',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2D3748),
              ),
            ),
            SizedBox(height: 10),
            Text(
              'Kullanıcı profili ve çocuk profilleri\nyönetimi burada yer alacak.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: Color(0xFF718096),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
