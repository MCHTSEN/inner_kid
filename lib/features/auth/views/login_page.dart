import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../viewmodels/auth_viewmodel.dart';
import '../models/auth_state.dart';

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _isPasswordVisible = false;
  bool _isLogin = true; // true for login, false for register
  final _nameController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authViewModelProvider);
    final authViewModel = ref.read(authViewModelProvider.notifier);

    // Navigate to main app when authenticated
    ref.listen(authViewModelProvider, (previous, next) {
      if (next.isAuthenticated) {
        Navigator.of(context).pushReplacementNamed('/main');
      }
    });

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 60),

                // Logo and Title
                _buildHeader(),

                const SizedBox(height: 60),

                // Login/Register Form
                _buildForm(authState, authViewModel),

                const SizedBox(height: 24),

                // Submit Button
                _buildSubmitButton(authState, authViewModel),

                const SizedBox(height: 16),


                // Toggle Login/Register
                _buildToggleButton(),

                if (_isLogin) ...[
                  const SizedBox(height: 16),
                  _buildForgotPasswordButton(authViewModel),
                ],

                // Error Message
                if (authState.hasError) ...[
                  const SizedBox(height: 16),
                  _buildErrorMessage(authState.errorMessage!),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        Container(
          width: 100,
          height: 100,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: const Icon(
            Icons.child_care,
            size: 50,
            color: Colors.white,
          ),
        ).animate().scale(duration: 600.ms),
        const SizedBox(height: 24),
        Text(
          'Inner Kid',
          style: GoogleFonts.nunito(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF2D3748),
          ),
        ).animate().fadeIn(delay: 200.ms),
        const SizedBox(height: 8),
        Text(
          _isLogin ? 'Hesabınıza giriş yapın' : 'Yeni hesap oluşturun',
          style: GoogleFonts.nunito(
            fontSize: 16,
            color: const Color(0xFF718096),
          ),
        ).animate().fadeIn(delay: 400.ms),
      ],
    );
  }

  Widget _buildForm(AuthState authState, AuthViewModel authViewModel) {
    return Column(
      children: [
        if (!_isLogin) ...[
          TextFormField(
            controller: _nameController,
            decoration: InputDecoration(
              labelText: 'Ad Soyad',
              prefixIcon: const Icon(Icons.person_outline),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            validator: (value) {
              if (!_isLogin && (value == null || value.trim().isEmpty)) {
                return 'Ad soyad gerekli';
              }
              return null;
            },
          ).animate().slideY(begin: 0.2, delay: 200.ms),
          const SizedBox(height: 16),
        ],
        TextFormField(
          controller: _emailController,
          keyboardType: TextInputType.emailAddress,
          decoration: InputDecoration(
            labelText: 'E-posta',
            prefixIcon: const Icon(Icons.email_outlined),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'E-posta gerekli';
            }
            if (!value.contains('@')) {
              return 'Geçerli bir e-posta adresi girin';
            }
            return null;
          },
        ).animate().slideY(begin: 0.2, delay: _isLogin ? 200.ms : 300.ms),
        const SizedBox(height: 16),
        TextFormField(
          controller: _passwordController,
          obscureText: !_isPasswordVisible,
          decoration: InputDecoration(
            labelText: 'Şifre',
            prefixIcon: const Icon(Icons.lock_outline),
            suffixIcon: IconButton(
              onPressed: () {
                setState(() {
                  _isPasswordVisible = !_isPasswordVisible;
                });
              },
              icon: Icon(
                _isPasswordVisible ? Icons.visibility_off : Icons.visibility,
              ),
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Şifre gerekli';
            }
            if (!_isLogin && value.length < 6) {
              return 'Şifre en az 6 karakter olmalı';
            }
            return null;
          },
        ).animate().slideY(begin: 0.2, delay: _isLogin ? 300.ms : 400.ms),
      ],
    );
  }

  Widget _buildSubmitButton(AuthState authState, AuthViewModel authViewModel) {
    return ElevatedButton(
      onPressed:
          authState.isLoading ? null : () => _handleSubmit(authViewModel),
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      child: authState.isLoading
          ? const SizedBox(
              height: 20,
              width: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : Text(
              _isLogin ? 'Giriş Yap' : 'Hesap Oluştur',
              style: GoogleFonts.nunito(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
    ).animate().slideY(begin: 0.2, delay: 500.ms);
  }

  Widget _buildGoogleSignInButton(
      AuthState authState, AuthViewModel authViewModel) {
    return OutlinedButton.icon(
      onPressed:
          authState.isLoading ? null : () => authViewModel.signInWithGoogle(),
      icon: Image.asset('assets/images/google-logo.png', height: 20, width: 20),
      label: Text(
        'Google ile ${_isLogin ? 'Giriş Yap' : 'Kayıt Ol'}',
        style: GoogleFonts.nunito(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: const Color(0xFF2D3748),
        ),
      ),
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    ).animate().slideY(begin: 0.2, delay: 600.ms);
  }

  Widget _buildToggleButton() {
    return TextButton(
      onPressed: () {
        setState(() {
          _isLogin = !_isLogin;
        });
        ref.read(authViewModelProvider.notifier).clearError();
      },
      child: RichText(
        text: TextSpan(
          style: GoogleFonts.nunito(color: const Color(0xFF718096)),
          children: [
            TextSpan(
              text:
                  _isLogin ? 'Hesabınız yok mu? ' : 'Zaten hesabınız var mı? ',
            ),
            TextSpan(
              text: _isLogin ? 'Kayıt Ol' : 'Giriş Yap',
              style: GoogleFonts.nunito(
                color: const Color(0xFF667EEA),
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    ).animate().fadeIn(delay: 700.ms);
  }

  Widget _buildForgotPasswordButton(AuthViewModel authViewModel) {
    return TextButton(
      onPressed: () => _showForgotPasswordDialog(authViewModel),
      child: Text(
        'Şifrenizi mi unuttunuz?',
        style: GoogleFonts.nunito(
          color: const Color(0xFF667EEA),
          fontWeight: FontWeight.w600,
        ),
      ),
    ).animate().fadeIn(delay: 800.ms);
  }

  Widget _buildErrorMessage(String message) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.red.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.red.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline, color: Colors.red, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: GoogleFonts.nunito(
                color: Colors.red,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    ).animate().shake();
  }

  Future<void> _handleSubmit(AuthViewModel authViewModel) async {
    if (!_formKey.currentState!.validate()) return;

    try {
      if (_isLogin) {
        await authViewModel.signInWithEmailAndPassword(
          _emailController.text.trim(),
          _passwordController.text,
        );
      } else {
        await authViewModel.signUpWithEmailAndPassword(
          _emailController.text.trim(),
          _passwordController.text,
          _nameController.text.trim(),
        );
      }
    } catch (e) {
      // Error is handled by the view model
    }
  }

  Future<void> _showForgotPasswordDialog(AuthViewModel authViewModel) async {
    final emailController = TextEditingController();

    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Şifre Sıfırlama',
          style: GoogleFonts.nunito(fontWeight: FontWeight.bold),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'E-posta adresinizi girin, şifre sıfırlama bağlantısı gönderelim.',
              style: GoogleFonts.nunito(),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                labelText: 'E-posta',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              'İptal',
              style: GoogleFonts.nunito(color: Colors.grey),
            ),
          ),
          TextButton(
            onPressed: () async {
              if (emailController.text.trim().isNotEmpty) {
                try {
                  await authViewModel.sendPasswordResetEmail(
                    emailController.text.trim(),
                  );
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Şifre sıfırlama e-postası gönderildi',
                        style: GoogleFonts.nunito(),
                      ),
                      backgroundColor: Colors.green,
                    ),
                  );
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        e.toString(),
                        style: GoogleFonts.nunito(),
                      ),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            child: Text(
              'Gönder',
              style: GoogleFonts.nunito(color: const Color(0xFF667EEA)),
            ),
          ),
        ],
      ),
    );
  }
}
