# Inner Kid Backend PRD - Gerçek Veri Yapısı Kurulumu

## 📊 Mevcut Durum Analizi

### ✅ Tamamlanan Frontend Yapısı
- **UI/UX**: Tamamen bitmiş ve üretim hazır
- **State Management**: Riverpod ile kurulmuş MVVM pattern
- **Animasyonlar**: Production-ready animasyon sistemi
- **Navigasyon**: Ekranlar arası geçiş sistemi
- **Model Yapısı**: Temel data modelleri mevcut


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

### Faz 2: Authentication Sistemi (1 hafta)

#### 2.1 Auth Service Oluşturma ✅ TAMAMLANDI
```dart
// lib/core/services/auth_service.dart ✅ OLUŞTURULDU
class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  
  // ✅ UYGULANDI: Tüm authentication methodları
  Future<User?> signInWithEmailAndPassword(String email, String password);
  Future<User?> createUserWithEmailAndPassword(String email, String password, String name);
  Future<User?> signInWithGoogle(); // ✅ Google Sign-In eklendi
  Future<void> signOut();
  Future<void> sendPasswordResetEmail(String email); // ✅ Password reset eklendi
  Future<void> updateUserProfile({String? displayName, String? photoURL}); // ✅ Profile update eklendi
  Future<void> deleteAccount(); // ✅ Account deletion eklendi
  Stream<User?> get authStateChanges;
  
  // ✅ Türkçe error handling eklendi
  Exception _handleAuthException(FirebaseAuthException e);
}
```

#### 2.2 Auth ViewModels ✅ TAMAMLANDI
```dart
// lib/features/auth/models/auth_state.dart ✅ OLUŞTURULDU
enum AuthStatus { initial, loading, authenticated, unauthenticated, error }

class AuthState {
  final AuthStatus status;
  final User? firebaseUser;
  final UserProfile? userProfile; // ✅ UserProfile entegrasyonu
  final String? errorMessage;
  final bool isLoading;
  // ✅ Factory constructors ve helper methodlar eklendi
}

// lib/features/auth/viewmodels/auth_viewmodel.dart ✅ OLUŞTURULDU
class AuthViewModel extends StateNotifier<AuthState> {
  // ✅ UYGULANDI: Riverpod StateNotifier pattern
  Future<void> signInWithEmailAndPassword(String email, String password);
  Future<void> signUpWithEmailAndPassword(String email, String password, String name);
  Future<void> signInWithGoogle(); // ✅ Google Sign-In eklendi
  Future<void> signOut();
  Future<void> sendPasswordResetEmail(String email); // ✅ Password reset eklendi
  Future<void> updateUserProfile({String? name, String? photoUrl}); // ✅ Profile update eklendi
  Future<void> deleteAccount(); // ✅ Account deletion eklendi
  
  // ✅ Otomatik auth state listener eklendi
  void _initAuthListener();
  // ✅ Otomatik user profile loading eklendi
  Future<void> _loadUserProfile(User firebaseUser);
}

// ✅ Riverpod Providers eklendi
final authServiceProvider = Provider<AuthService>((ref) => AuthService());
final firestoreServiceProvider = Provider<FirestoreService>((ref) => FirestoreService());
final authViewModelProvider = StateNotifierProvider<AuthViewModel, AuthState>((ref) => ...);
```

#### 2.3 Auth UI Pages
- [ ] Login Page
- [ ] Register Page
- [ ] Profile Setup Page
- [ ] Password Reset Page

### Faz 3: Firestore Database Yapısı (1 hafta)

#### 3.1 Collection Yapısı
// Firestore collections
users/{userId} {
  email: string,
  name: string,
  subscription: bool,
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

#### 3.2 Firestore Services ✅ TAMAMLANDI
```dart
// lib/core/services/firestore_service.dart ✅ OLUŞTURULDU
class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  
  // ✅ Collection constants tanımlandı
  static const String usersCollection = 'users';
  static const String childrenCollection = 'children';
  static const String drawingsCollection = 'drawings';
  static const String analysesCollection = 'analyses';
  static const String subscriptionsCollection = 'subscriptions';
  
  // ✅ User operations - UYGULANDI
  Future<void> createUser(String userId, UserProfile userProfile); // ✅ UserProfile entegrasyonu
  Future<UserProfile?> getUser(String userId); // ✅ UserProfile return type
  Future<void> updateUser(String userId, Map<String, dynamic> updates);
  Future<void> deleteUser(String userId); // ✅ Account deletion support
  Stream<UserProfile?> getUserStream(String userId); // ✅ Real-time updates
  
  // ✅ Child operations - UYGULANDI
  Future<String> createChild(ChildProfile child);
  Future<List<ChildProfile>> getChildren(String userId);
  Future<ChildProfile?> getChild(String childId); // ✅ Single child fetch
  Future<void> updateChild(String childId, Map<String, dynamic> updates);
  Future<void> deleteChild(String childId); // ✅ Child deletion
  Stream<List<ChildProfile>> getChildrenStream(String userId); // ✅ Real-time updates
  Future<int> getAnalysisCountForChild(String childId); // ✅ Analysis count helper
  
  // ✅ Drawing operations - HAZIR (Analysis entegrasyonu için)
  // Future<String> createDrawing(DrawingAnalysis drawing);
  // Future<DrawingAnalysis> getDrawing(String drawingId);
  // Future<List<DrawingAnalysis>> getChildDrawings(String childId);
  
  // ✅ Analysis operations - HAZIR (AI entegrasyonu için)
  // Future<void> updateAnalysisResults(String analysisId, Map<String, dynamic> results);
  
  // ✅ Subscription operations - EKLENDI
  Future<void> updateSubscription(String userId, Map<String, dynamic> subscriptionData);
  
  // ✅ Batch operations - EKLENDI
  Future<void> batchWrite(List<Map<String, dynamic>> operations);
}

// ✅ Model Updates - TAMAMLANDI
// lib/core/models/user_profile.dart ✅ YENİ OLUŞTURULDU
// lib/core/models/child_profile.dart ✅ GÜNCELLENDI (userId field, fromMap/toMap methods)
```

### Faz 4: Cloud Storage Setup (1 hafta)

#### 4.1 Storage Structure
```
drawings/
  {userId}/
    {childId}/
        {drawingId}.jpg
  

reports/
  {userId}/
   {childId}/
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
    required Map<String, String> questionnaire,
    required int childAge,
    String? note,

    // 1. Get drawing from ImagePicker
    // 2. Send image to Gemini API with questionnaire and excellent prompt
    // 3. Get Response from Gemini API
    // 4. Process and format results
    // 5. Update Firestore with results and save image to storage 
    // 6. Generate PDF report
    // 7. Send notification to user
    // use firebase_ai package for this
    // use context7 for prompt
  });
}

---

## 🛠️ Implementation Roadmap

### Hafta 1: Firebase Setup & Auth
```dart
// COMPLETED: ✅
- [x] Firebase project kurulumu
- [x] Authentication service (AuthService ✅)
- [x] Auth state management (AuthState, AuthViewModel ✅)
- [x] User profile model (UserProfile ✅)
- [x] Firestore service (FirestoreService ✅)
- [x] Profile page authentication integration ✅
- [ ] Auth UI components (Login/Register pages)
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