# Inner Kid Backend PRD - Gerçek Veri Yapısı Kurulumu

## 📊 Mevcut Durum Analizi

### ✅ Tamamlanan Frontend Yapısı
- **UI/UX**: Tamamen bitmiş ve üretim hazır
- **State Management**: Riverpod ile kurulmuş MVVM pattern
- **Animasyonlar**: Production-ready animasyon sistemi
- **Navigasyon**: Ekranlar arası geçiş sistemi
- **Model Yapısı**: Temel data modelleri mevcut

### 🔄 Eksik Backend Entegrasyonları
- Firebase Authentication henüz entegre edilmemiş
- Firestore database bağlantısı yok
- Cloud Storage yapılandırması eksik
- Gerçek AI analiz servisi yok
- Payment system entegrasyonu eksik

---

## 🗂️ Mevcut Data Model Yapısı

### Child Profile Model
```dart
class ChildProfile {
  final String id;
  final String name;
  final DateTime birthDate;
  final String gender;
  final String? avatarUrl;
  final Map<String, dynamic>? additionalInfo;
  final DateTime createdAt;
  final DateTime updatedAt;
}
```

### Drawing Analysis Model
```dart
class DrawingAnalysis {
  final String id;
  final String childId;
  final String imageUrl;
  final DateTime uploadDate;
  final DrawingTestType testType;
  final AnalysisStatus status;
  final Map<String, dynamic>? aiResults;
  final String? expertComments;
  final List<String> recommendations;
  final Map<String, dynamic>? metadata;
  final DateTime createdAt;
  final DateTime? completedAt;
}
```

### Test Types (Enum)
- `selfPortrait`: Kendini Çizme
- `familyDrawing`: Aile Çizimi
- `houseTreePerson`: Ev-Ağaç-İnsan
- `narrativeDrawing`: Hikaye Çizimi
- `emotionalStates`: Duygusal Durumlar

---

## 🏗️ Firebase Backend Kurulum Yol Haritası

### Faz 1: Firebase Proje Kurulumu (1 hafta)

#### 1.1 Firebase Console Kurulumu
```bash
# Firebase CLI kurulumu
npm install -g firebase-tools
firebase login
```

#### 1.2 Flutter Firebase Entegrasyonu
```yaml
# pubspec.yaml - Zaten mevcut
dependencies:
  firebase_core: ^3.13.0
  firebase_auth: ^5.5.1
  cloud_firestore: ^5.6.9
  firebase_storage: ^12.4.6
  firebase_analytics: ^11.5.0
```

#### 1.3 Platform Konfigürasyonları
- [ ] Android: `google-services.json` ekleme
- [ ] iOS: `GoogleService-Info.plist` ekleme
- [ ] Web: Firebase config ekleme
- [ ] macOS: Firebase setup

### Faz 2: Authentication Sistemi (1 hafta)

#### 2.1 Auth Service Oluşturma
```dart
// lib/core/services/auth_service.dart
class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  
  Future<User?> signInWithEmailAndPassword(String email, String password);
  Future<User?> createUserWithEmailAndPassword(String email, String password);
  Future<User?> signInWithGoogle();
  Future<User?> signInWithApple();
  Future<void> signOut();
  Stream<User?> get authStateChanges;
}
```

#### 2.2 Auth ViewModels
```dart
// lib/features/auth/viewmodels/auth_viewmodel.dart
class AuthViewModel extends StateNotifier<AuthState> {
  Future<void> signIn(String email, String password);
  Future<void> signUp(String email, String password, String name);
  Future<void> signInWithGoogle();
  Future<void> signOut();
}
```

#### 2.3 Auth UI Pages
- [ ] Login Page
- [ ] Register Page
- [ ] Profile Setup Page
- [ ] Password Reset Page

### Faz 3: Firestore Database Yapısı (1 hafta)

#### 3.1 Collection Yapısı
```javascript
// Firestore collections
users/{userId} {
  email: string,
  name: string,
  subscriptionTier: 'free' | 'pro' | 'family',
  subscriptionExpiry: timestamp,
  createdAt: timestamp,
  updatedAt: timestamp
}

children/{childId} {
  userId: string,
  name: string,
  birthDate: timestamp,
  gender: 'erkek' | 'kız' | 'belirtmek_istemiyorum',
  avatarUrl: string?,
  additionalInfo: {
    schoolInfo?: string,
    specialNeeds?: string,
    notes?: string
  },
  createdAt: timestamp,
  updatedAt: timestamp
}

drawings/{drawingId} {
  childId: string,
  userId: string,
  imageUrl: string,
  thumbnailUrl: string,
  uploadDate: timestamp,
  testType: string,
  analysisStatus: 'pending' | 'processing' | 'completed' | 'failed',
  questionnaire: {
    childAge: string,
    emotionalState: string,
    drawingDuration: string,
    childBehavior: string
  },
  createdAt: timestamp
}

analyses/{analysisId} {
  drawingId: string,
  childId: string,
  userId: string,
  aiResults: {
    primaryInsight: string,
    emotionalScore: number, // 1-10
    creativityScore: number, // 1-10
    developmentScore: number, // 1-10
    keyFindings: string[],
    detailedAnalysis: {
      emotionalIndicators: string[],
      developmentLevel: string,
      socialAspects: string[],
      creativityMarkers: string[]
    }
  },
  recommendations: string[],
  expertComments: string?,
  reportUrl: string?,
  createdAt: timestamp,
  completedAt: timestamp
}

subscriptions/{userId} {
  planId: string,
  status: 'active' | 'cancelled' | 'expired',
  startDate: timestamp,
  endDate: timestamp,
  paymentMethod: string,
  transactionId: string,
  features: string[]
}
```

#### 3.2 Firestore Services
```dart
// lib/core/services/firestore_service.dart
class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  
  // User operations
  Future<void> createUser(String userId, Map<String, dynamic> userData);
  Future<DocumentSnapshot> getUser(String userId);
  
  // Child operations
  Future<String> createChild(ChildProfile child);
  Future<List<ChildProfile>> getChildren(String userId);
  Future<void> updateChild(String childId, Map<String, dynamic> updates);
  
  // Drawing operations
  Future<String> createDrawing(DrawingAnalysis drawing);
  Future<DrawingAnalysis> getDrawing(String drawingId);
  Future<List<DrawingAnalysis>> getChildDrawings(String childId);
  
  // Analysis operations
  Future<void> updateAnalysisResults(String analysisId, Map<String, dynamic> results);
}
```

### Faz 4: Cloud Storage Setup (1 hafta)

#### 4.1 Storage Structure
```
drawings/
  {userId}/
    {childId}/
      originals/
        {drawingId}.jpg
      thumbnails/
        {drawingId}_thumb.jpg

reports/
  {userId}/
    {analysisId}.pdf

profiles/
  {userId}/
    {childId}/
      avatar.jpg
```

#### 4.2 Storage Service
```dart
// lib/core/services/storage_service.dart
class StorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;
  
  Future<String> uploadDrawing(File imageFile, String userId, String childId, String drawingId);
  Future<String> uploadThumbnail(File thumbnailFile, String userId, String childId, String drawingId); 
  Future<String> uploadAvatar(File avatarFile, String userId, String childId);
  Future<String> uploadReport(Uint8List pdfBytes, String userId, String analysisId);
  Future<void> deleteDrawing(String userId, String childId, String drawingId);
}
```

### Faz 5: AI Analysis Integration (2 hafta)

#### 5.1 Gemini API Integration
```dart
// lib/core/services/ai_analysis_service.dart
class AIAnalysisService {
  final GoogleGenerativeAI _ai = GoogleGenerativeAI(apiKey: 'YOUR_API_KEY');
  
  Future<Map<String, dynamic>> analyzeDrawing({
    required File imageFile,
    required DrawingTestType testType,
    required Map<String, String> questionnaire,
    required int childAge,
  });
  
  Future<List<String>> generateRecommendations(Map<String, dynamic> analysisResults);
  Future<String> generateDetailedReport(String analysisId);
}
```

#### 5.2 Analysis Processing
```dart
// lib/core/services/analysis_processing_service.dart
class AnalysisProcessingService {
  Future<void> processDrawingAnalysis(String drawingId) async {
    // 1. Get drawing from Firestore
    // 2. Download image from Storage  
    // 3. Call AI analysis service
    // 4. Process and format results
    // 5. Update Firestore with results
    // 6. Generate PDF report
    // 7. Send notification to user
  }
}
```

---

## 🛠️ Implementation Roadmap

### Hafta 1: Firebase Setup & Auth
```dart
// TODO: Implement
- [x] Firebase project kurulumu
- [ ] Authentication service
- [ ] Auth UI components
- [ ] Auth state management
- [ ] Platform-specific configurations
```

### Hafta 2: Database & Storage
```dart
// TODO: Implement  
- [ ] Firestore collections setup
- [ ] Database service layer
- [ ] Cloud Storage configuration
- [ ] File upload/download services
- [ ] Data validation & security rules
```

### Hafta 3: Core Data Flow
```dart
// TODO: Implement
- [ ] Child profile management
- [ ] Drawing upload pipeline
- [ ] Basic CRUD operations
- [ ] State management integration
- [ ] Error handling
```

### Hafta 4: AI Integration
```dart
// TODO: Implement
- [ ] Gemini API setup
- [ ] Image analysis pipeline
- [ ] Analysis result processing
- [ ] Background job processing
- [ ] Result caching
```

### Hafta 5: Payment & Subscription
```dart
// TODO: Implement
- [ ] Stripe/PayPal integration
- [ ] Subscription management
- [ ] Premium feature gating
- [ ] Payment security
- [ ] Webhook handling
```

### Hafta 6: Reports & Notifications
```dart
// TODO: Implement
- [ ] PDF report generation
- [ ] Push notifications
- [ ] Email notifications
- [ ] Share functionality
- [ ] Export features
```

---

## 🔧 Required Code Changes

### 1. Main App Setup
```dart
// lib/main.dart - Update required
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Firebase initialization
  await Firebase.initializeApp();
  
  // Service registration
  await setupServices();
  
  runApp(
    ProviderScope(
      child: MyApp(),
    ),
  );
}
```

### 2. Service Registration
```dart
// lib/core/di/service_locator.dart - New file
Future<void> setupServices() async {
  final getIt = GetIt.instance;
  
  // Core services
  getIt.registerSingleton<AuthService>(AuthService());
  getIt.registerSingleton<FirestoreService>(FirestoreService());
  getIt.registerSingleton<StorageService>(StorageService());
  getIt.registerSingleton<AIAnalysisService>(AIAnalysisService());
  getIt.registerSingleton<AnalysisProcessingService>(AnalysisProcessingService());
}
```

### 3. FirstAnalysisViewModel Update
```dart
// lib/features/first_analysis/viewmodel/first_analysis_viewmodel.dart
Future<void> submitAnalysis() async {
  if (!state.allQuestionsAnswered || state.uploadedImage == null) return;
  
  try {
    state = state.copyWith(isAnalyzing: true);
    
    // 1. Upload image to Firebase Storage
    final imageUrl = await _storageService.uploadDrawing(
      state.uploadedImage!,
      _authService.currentUser!.uid,
      state.selectedChildId!,
      _generateDrawingId(),
    );
    
    // 2. Create drawing record in Firestore
    final drawingId = await _firestoreService.createDrawing(
      DrawingAnalysis(
        id: _generateDrawingId(),
        childId: state.selectedChildId!,
        imageUrl: imageUrl,
        uploadDate: DateTime.now(),
        testType: state.selectedTestType!,
        status: AnalysisStatus.pending,
        // questionnaire data from state
        createdAt: DateTime.now(),
      ),
    );
    
    // 3. Trigger AI analysis (background job)
    await _analysisProcessingService.processDrawingAnalysis(drawingId);
    
    state = state.copyWith(
      isAnalyzing: false,
      isAnalysisCompleted: true,
      currentDrawingId: drawingId,
    );
    
  } catch (e) {
    state = state.copyWith(isAnalyzing: false);
    // Handle error
  }
}
```

---

## 📱 Integration Points

### Mevcut ViewModels'larda Güncellenecek Methodlar

#### FirstAnalysisViewModel
- ✅ `uploadImageFromGallery()` - Storage service entegrasyonu
- ✅ `uploadImageFromCamera()` - Storage service entegrasyonu  
- ✅ `submitAnalysis()` - Full backend pipeline
- ✅ `reset()` - State cleanup

#### AnalysisResultsViewModel  
- ✅ `loadAnalysisResults()` - Firestore'dan veri çekme
- ✅ `generatePDFReport()` - PDF service entegrasyonu
- ✅ `shareResults()` - Share service entegrasyonu

### Yeni Service Providers
```dart
// Riverpod providers for services
final authServiceProvider = Provider<AuthService>((ref) => GetIt.instance<AuthService>());
final firestoreServiceProvider = Provider<FirestoreService>((ref) => GetIt.instance<FirestoreService>());
final storageServiceProvider = Provider<StorageService>((ref) => GetIt.instance<StorageService>());
final aiAnalysisServiceProvider = Provider<AIAnalysisService>((ref) => GetIt.instance<AIAnalysisService>());
```

---

## 🔒 Security Rules

### Firestore Security Rules
```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Users can only access their own data
    match /users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
    
    // Children belong to authenticated user
    match /children/{childId} {
      allow read, write: if request.auth != null && 
        request.auth.uid == resource.data.userId;
    }
    
    // Drawings belong to authenticated user
    match /drawings/{drawingId} {
      allow read, write: if request.auth != null && 
        request.auth.uid == resource.data.userId;
    }
    
    // Analyses belong to authenticated user
    match /analyses/{analysisId} {
      allow read, write: if request.auth != null && 
        request.auth.uid == resource.data.userId;
    }
  }
}
```

### Storage Security Rules
```javascript
rules_version = '2';
service firebase.storage {
  match /b/{bucket}/o {
    // Users can only access their own files
    match /drawings/{userId}/{allPaths=**} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
    
    match /reports/{userId}/{allPaths=**} {
      allow read: if request.auth != null && request.auth.uid == userId;
    }
    
    match /profiles/{userId}/{allPaths=**} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
  }
}
```

---

## 🧪 Testing Strategy

### Unit Tests
```dart
// test/services/auth_service_test.dart
// test/services/firestore_service_test.dart
// test/services/storage_service_test.dart
// test/services/ai_analysis_service_test.dart
```

### Integration Tests  
```dart
// integration_test/auth_flow_test.dart
// integration_test/drawing_upload_test.dart
// integration_test/analysis_pipeline_test.dart
```

### API Testing
```dart
// test/api/mock_firebase_test.dart
// test/api/gemini_api_test.dart
```

---

## 💰 Cost Optimization

### Firebase Pricing Considerations
- **Firestore**: Read/Write operations
- **Storage**: File storage + bandwidth
- **Auth**: Monthly active users
- **Functions**: Execution time + invocations

### Optimization Strategies
1. **Image Compression**: Reduce storage costs
2. **Caching**: Minimize Firestore reads
3. **Batch Operations**: Reduce transaction costs
4. **CDN**: Use Firebase Hosting for static assets

---

## 🚀 Deployment Pipeline

### Environment Setup
```yaml
# Firebase environments
- Development: inner-kid-dev
- Staging: inner-kid-staging  
- Production: inner-kid-prod
```

### CI/CD Pipeline
```yaml
# .github/workflows/deploy.yml
- Build Flutter app
- Run tests
- Deploy to Firebase Hosting
- Update Firestore rules
- Deploy Cloud Functions
```

---

## 📊 Monitoring & Analytics

### Firebase Analytics Events
```dart
// Track key user actions
FirebaseAnalytics.instance.logEvent(
  name: 'drawing_uploaded',
  parameters: {
    'test_type': testType.id,
    'child_age': childAge,
    'user_subscription': subscriptionTier,
  },
);
```

### Performance Monitoring
- App startup time
- Image upload speed  
- Analysis completion time
- User engagement metrics

---

## ⚡ Next Steps - Priority Order

### Hafta 1 (En Yüksek Öncelik)
1. ✅ Firebase project kurulumu
2. ✅ Authentication service implementation
3. ✅ Basic Firestore setup
4. ✅ FirstAnalysisViewModel backend entegrasyonu

### Hafta 2 (Yüksek Öncelik)
1. ✅ Child profile management
2. ✅ Drawing upload pipeline
3. ✅ Basic AI analysis integration
4. ✅ Results display backend entegrasyonu

### Hafta 3 (Orta Öncelik)  
1. ✅ Payment system integration
2. ✅ PDF report generation
3. ✅ Push notifications
4. ✅ Error handling & edge cases

Bu yol haritasını takip ederek, mevcut güzel frontend'inizi gerçek backend servisleriyle entegre edebilirsiniz. Kod yapınız zaten backend entegrasyonu için hazır durumda! 🚀 