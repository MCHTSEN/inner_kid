import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../services/auth_service.dart';
import '../services/firestore_service.dart';
import '../services/storage_service.dart';

/// Centralized providers for dependency injection
/// This file contains all service providers to avoid ambiguous imports

/// Authentication service provider
final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService();
});

/// Firestore service provider
final firestoreServiceProvider = Provider<FirestoreService>((ref) {
  return FirestoreService();
});

/// Storage service provider
final storageServiceProvider = Provider<StorageService>((ref) {
  return StorageService();
});

// Re-export AI Analysis service providers from the service file to avoid duplication
// These are defined in ai_analysis_service.dart:
// - aiAnalysisServiceProvider (Vertex AI backend)
// - aiAnalysisServiceGoogleAIProvider (Google AI backend)
