import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:inner_kid/core/enums/custom_images.dart';
import 'package:inner_kid/core/extension/ui_helper_extensions.dart';
import 'package:inner_kid/core/theme/theme.dart';

import '../viewmodels/onboarding_viewmodel.dart';

class SocialProofScreen extends ConsumerWidget {
  const SocialProofScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gradientColor = Colors.white;
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppTheme.backgroundGradient,
        ),
        child: Stack(
          children: [
            // Background image
            Container(
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: CustomImages.inner_bg_4.buildImage,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            // Blur effect on bottom half
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              height: MediaQuery.of(context).size.height * 0.6,
              child: ClipRect(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        gradientColor.withOpacity(0.5),
                        gradientColor.withOpacity(0.8),
                        gradientColor.withOpacity(1),
                      ],
                      stops: const [0.0, 0.25, 0.7, 1.0],
                    ),
                  ),
                ),
              ),
            ),
            // Content
            Container(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  // Header with skip option
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () {
                          // TODO: Skip onboarding and go to main app
                        },
                        child: Text(
                          'Atla',
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            color: AppTheme.textSecondary,
                          ),
                        ),
                      ),
                    ],
                  ),

                  // Main content
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text(
                            'Inner Kid 22.400\'den fazla kullanıcıyla çocukların duygularını anlamada bilimsel destek sağladı!',
                            style: GoogleFonts.nunitoSans(
                              fontSize: 30,
                              fontWeight: FontWeight.w900,
                            )).withPadding(bottom: 50),
                        // // Social proof text
                        // Container(
                        //   padding: const EdgeInsets.symmetric(
                        //     horizontal: 24,
                        //     vertical: 20,
                        //   ),
                        //   decoration: BoxDecoration(
                        //     color: Colors.white,
                        //     borderRadius: BorderRadius.circular(16),
                        //     border: Border.all(
                        //       color: Colors.black.withOpacity(0.7),
                        //       width: 1,
                        //     ),
                        //     boxShadow: [
                        //       BoxShadow(
                        //         color: Colors.black.withOpacity(0.05),
                        //         blurRadius: 10,
                        //         offset: const Offset(0, 5),
                        //       ),
                        //     ],
                        //   ),
                        //   child: Column(
                        //     children: [
                        //       Row(
                        //         mainAxisAlignment: MainAxisAlignment.center,
                        //         children: [
                        //           Text(
                        //             'Inner Kid',
                        //             style: GoogleFonts.poppins(
                        //               fontSize: 20,
                        //               fontWeight: FontWeight.w700,
                        //             ),
                        //           ),
                        //           Gap.low,
                        //           Icon(Icons.verified,
                        //               size: 20, color: Colors.lightBlue),
                        //         ],
                        //       ),
                        //       const SizedBox(height: 8),
                        //       Text(
                        //         '22.400\'den fazla kullanıcıyla',
                        //         style: GoogleFonts.poppins(
                        //           fontSize: 16,
                        //           fontWeight: FontWeight.w600,
                        //           color: Colors.black87,
                        //         ),
                        //         textAlign: TextAlign.center,
                        //       ),
                        //       const SizedBox(height: 4),
                        //       Text(
                        //         'çocukların duygularını anlamada',
                        //         style: GoogleFonts.poppins(
                        //           fontSize: 16,
                        //           fontWeight: FontWeight.w600,
                        //           color: Colors.black87,
                        //         ),
                        //         textAlign: TextAlign.center,
                        //       ),
                        //       const SizedBox(height: 4),
                        //       Text(
                        //         'bilimsel destek sağladı',
                        //         style: GoogleFonts.poppins(
                        //           fontSize: 16,
                        //           fontWeight: FontWeight.w600,
                        //           color: Colors.black87,
                        //         ),
                        //         textAlign: TextAlign.center,
                        //       ),
                        //     ],
                        //   ),
                        // ),
                      ],
                    ),
                  ),

                  // Continue button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        ref
                            .read(onboardingViewModelProvider.notifier)
                            .nextStep();
                      },
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: Text(
                        'Başlayalım',
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
