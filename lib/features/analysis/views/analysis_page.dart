import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:inner_kid/features/first_analysis/components/native_dialogs.dart';
import 'package:inner_kid/features/first_analysis/components/analysis_loading_widget.dart';

class AnalysisPage extends StatefulWidget {
  const AnalysisPage({super.key});

  @override
  State<AnalysisPage> createState() => _AnalysisPageState();
}

class _AnalysisPageState extends State<AnalysisPage> {
  @override
  void initState() {
    super.initState();
    // Automatically show image picker when page loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _showImagePicker();
    });
  }

  void _showImagePicker() {
    NativeDialogs.showImagePickerActionSheet(
      context: context,
      onGalleryTap: () {
        // Handle gallery selection
        _onImageSelected();
      },
      onCameraTap: () {
        // Handle camera selection
        _onImageSelected();
      },
    );
  }

  void _onImageSelected() {
    // Navigate to analysis loading widget
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => const AnalysisLoadingWidget(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          'Analiz Et',
          style: GoogleFonts.nunito(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF2D3748),
          ),
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.add_a_photo,
              size: 100,
              color: Color(0xFF667EEA),
            ),
            const SizedBox(height: 20),
            Text(
              'Çizim Analizi',
              style: GoogleFonts.nunito(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF2D3748),
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'Çocuğunuzun çizimini yükleyerek\npsikololojik analiz yapın.',
              textAlign: TextAlign.center,
              style: GoogleFonts.nunito(
                fontSize: 16,
                color: const Color(0xFF718096),
              ),
            ),
            const SizedBox(height: 40),
            ElevatedButton.icon(
              onPressed: _showImagePicker,
              icon: const Icon(Icons.photo_camera),
              label: const Text('Çizim Yükle'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF667EEA),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 16,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
