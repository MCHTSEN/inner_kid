# Inner Kid - Çocukların İç Dünyasını Keşfetme Platformu
## Product Requirements Document (PRD)

### 📋 Proje Özeti
Inner Kid, 4-12 yaş arası çocukların çizimlerini analiz ederek iç dünyalarını, duygusal durumlarını ve gelişim seviyelerini keşfetmeyi amaçlayan bir dijital platform projesidir. Bilimsel araştırmalara dayalı çizim analizi teknikleri kullanarak, çocukların psikolojik durumları hakkında ailelere ve eğitimcilere değerli bilgiler sağlar.

---

## 🎯 Hedef Kitle
- **Birincil**: Çocukları olan ebeveynler (25-45 yaş)
- **İkincil**: Eğitimciler, öğretmenler, okul psikolojistleri
- **Üçüncül**: Çocuk gelişimi uzmanları, terapistler

---

## 🔍 Literatür Araştırması ve Çizim Testleri

### Bilimsel Temeller
Araştırmalar çocukların çizimlerinin iç dünyalarını yansıttığını göstermektedir:

1. **Projeksiyonel Değer**: Çizimler çocukların sözcükle ifade edemediği duyguları ortaya çıkarır
2. **Gelişimsel Göstergeler**: Yaş gruplarına göre çizim seviyesi gelişimi
3. **Duygusal İndikatörler**: Renk kullanımı, figür boyutları, kompozisyon düzeni
4. **Aile İlişkileri**: Aile çizimleri ile çocuğun aile algısı
5. **Travma Belirtileri**: Çizimlerde görülen kaygı, korku, depresyon işaretleri

### 5 Temel Çizim Testi Kategorisi

#### 1. **Kendini Çizme Testi (Self-Portrait Drawing)**
- **Amaç**: Öz-algı, benlik kavramı, özgüven düzeyi
- **Yöntem**: "Kendini çiz" talimatı
- **Analiz**: Figür büyüklüğü, detay seviyesi, yüz ifadeleri
- **Yaş Grubu**: 4-12 yaş

#### 2. **Aile Çizimi Testi (Family Drawing Test)**
- **Amaç**: Aile dinamikleri, güvenlik hissi, bağlanma stilleri
- **Yöntem**: "Ailenle birlikte bir şey yaparken çiz"
- **Analiz**: Figür yakınlığı, boyut oranları, aktivite seçimi
- **Yaş Grubu**: 4-12 yaş

#### 3. **Ev-Ağaç-İnsan Testi (House-Tree-Person)**
- **Amaç**: Kişilik yapısı, çevre algısı, güvenlik ihtiyaçları
- **Yöntem**: Ev, ağaç ve insan çizimi
- **Analiz**: Sembolik anlamlar, proporsiyonlar, detaylar
- **Yaş Grubu**: 6-12 yaş

#### 4. **Hikaye Anlatımlı Çizim (Narrative Drawing)**
- **Amaç**: Yaratıcılık, duygusal işleme, problem çözme
- **Yöntem**: "Bir hikaye çiz ve anlat"
- **Analiz**: Hikaye sonu (pozitif/negatif), çatışma çözümü
- **Yaş Grubu**: 5-12 yaş

#### 5. **Duygusal Durumlar Çizimi (Emotional States)**
- **Amaç**: Mevcut duygusal durum, stres faktörleri
- **Yönethod**: "Şu anki hislerini çiz"
- **Analiz**: Renk seçimi, çizgi kalitesi, semboller
- **Yaş Grubu**: 4-12 yaş

---

## 🚀 Özellikler ve Fonksiyonaliteler

### 🏠 Ana Sayfa Özellikleri
- **Kullanıcı Profili**: Çoklu çocuk profili desteği
- **Geçmiş Analizler**: Kronolojik çizim geçmişi ve gelişim grafikleri
- **Hızlı Analiz**: Yeni çizim yükleme butonu
- **İlerleme Takibi**: Çocuğun gelişim çizelgesi
- **Öneriler Paneli**: Günlük aktivite önerileri

### 👤 Profil Yönetimi
- **Çoklu Çocuk Desteği**: Aynı hesapta birden fazla çocuk
- **Çocuk Bilgileri**: Yaş, cinsiyet, okul bilgileri
- **Gelişim Milestones**: Yaş gruplarına göre beklenen gelişim
- **Aile Bilgileri**: Aile yapısı, özel durumlar

### 📱 Çizim Yükleme ve Analiz
- **Kamera Entegrasyonu**: Anlık fotoğraf çekme
- **Galeri Seçimi**: Var olan çizimlerden seçim
- **Çizim Kalitesi Kontrolü**: Otomatik kalite değerlendirmesi
- **Metadata Toplama**: Çizim tarihi, koşulları, çocuğun durumu

### 🧠 AI Analiz Sistemi
- **Görüntü İşleme**: Çizim elementlerinin otomatik tanınması
- **Psikolojik Analiz**: Bilimsel kriterlere dayalı değerlendirme
- **Karşılaştırmalı Analiz**: Yaş grubu normları ile karşılaştırma
- **Trend Analizi**: Zaman içindeki değişimler

### 📊 Raporlama ve Sonuçlar
- **Detaylı Analiz Raporu**: Psikolojik değerlendirme
- **Görsel Grafik**: Gelişim çizelgeleri
- **Öneriler**: Aktivite ve destek önerileri
- **PDF İhracatı**: Uzmanlarla paylaşım için
- **Ebeveyn Rehberi**: Çocukla nasıl konuşulacağı

### 💬 Sosyal Özellikler
- **Uzman Danışmanlığı**: Çocuk psikoloğu ile iletişim
- **Ebeveyn Forumu**: Deneyim paylaşımı
- **Aktivite Önerileri**: Topluluk destekli içerik
- **Başarı Rozetleri**: Çocuk motivasyonu

---

## 🏗️ Teknik Mimari (Firebase Backend)

### Firebase Servisleri

#### 🔐 Authentication
```javascript
// Kullanıcı kimlik doğrulama
- Email/Password
- Google Sign-In
- Apple Sign-In
- Telefon doğrulama
```

#### 💾 Firestore Database
```javascript
// Veri yapısı
users/{userId} {
  email: string,
  name: string,
  subscriptionTier: string,
  createdAt: timestamp
}

children/{childId} {
  userId: string,
  name: string,
  birthDate: date,
  gender: string,
  additionalInfo: object
}

drawings/{drawingId} {
  childId: string,
  imageUrl: string,
  uploadDate: timestamp,
  testType: string,
  analysisStatus: string,
  analysisResults: object
}

analyses/{analysisId} {
  drawingId: string,
  aiResults: object,
  expertComments: string,
  recommendations: array,
  createdAt: timestamp
}
```

#### 📁 Cloud Storage
```javascript
// Dosya yapısı
drawings/{userId}/{childId}/{drawingId}.jpg
reports/{userId}/{analysisId}.pdf
profiles/{userId}/{childId}/avatar.jpg
```

#### ⚡ Cloud Functions
```javascript
// Backend işlemleri
- analyzeDrawing(drawingId)
- generateReport(analysisId)
- sendNotifications(userId)
- processPayment(subscriptionData)
```

#### 📊 Analytics
```javascript
// Kullanım metrikleri
- Çizim yükleme oranları
- Analiz tamamlama süreleri
- Kullanıcı engagement
- Abonelik dönüşüm oranları
```

### 🤖 AI/ML Entegrasyonu
- **Google Vision API**: Görüntü analizi
- **TensorFlow Lite**: Mobil ML modelleri
- **Custom ML Model**: Çizim analizi için özel eğitilmiş model
- **Natural Language Processing**: Hikaye analizi

---

## 💰 Monetizasyon Stratejisi

### Freemium Model
**Ücretsiz Tier (Basic)**
- Ayda 3 çizim analizi
- Temel rapor
- Sınırlı geçmiş erişimi

**Premium Tier (Pro) - ₺29.99/ay**
- Sınırsız çizim analizi
- Detaylı raporlar
- Uzman önerileri
- PDF ihracatı
- Karşılaştırmalı analiz

**Family Tier (Premium) - ₺49.99/ay**
- 5 adede kadar çocuk profili
- Aile analiz raporu
- Uzman danışmanlığı
- Öncelikli destek

---

## 📱 Kullanıcı Arayüzü Tasarımı

### Ana Sayfa Layout
```
┌─────────────────────────────────────┐
│ 👤 Profil    Inner Kid    🔔 Bildirim │
├─────────────────────────────────────┤
│ 📊 Günlük İçgörü Kartı              │
│ "Ahmet bugün yaratıcı çizimler yaptı"│
├─────────────────────────────────────┤
│ 👶 Çocuk Profilleri                  │
│ [Ahmet] [Ayşe] [+ Ekle]              │
├─────────────────────────────────────┤
│ 🎨 Hızlı Analiz                      │
│ [📷 Fotoğraf Çek] [📁 Galeri]         │
├─────────────────────────────────────┤
│ 📈 Son Analizler                     │
│ • Aile Çizimi - 2 gün önce           │
│ • Kendini Çizme - 1 hafta önce       │
├─────────────────────────────────────┤
│ 💡 Günlük Öneriler                   │
│ "Çocuğunuzla birlikte resim yapın"   │
└─────────────────────────────────────┘
```

### Çizim Analiz Süreci
```
1. Çizim Yükleme
   ├── Fotoğraf çekme/seçme
   ├── Kalite kontrolü
   └── Metadata girişi

2. Test Seçimi
   ├── Otomatik öneri
   ├── Manuel seçim
   └── Çoklu test seçeneği

3. Analiz Süreci
   ├── AI ön analiz (30 saniye)
   ├── Psikolojik değerlendirme (2-3 dakika)
   └── Rapor oluşturma

4. Sonuç Sunumu
   ├── Görsel özet
   ├── Detaylı analiz
   └── Öneriler
```

---

## 🚀 Geliştirme Aşamaları

### Faz 1: Temel Özellikler (4-6 hafta)
- [x] Temel UI komponenrleri (Mevcut)
- [x] Çizim yükleme sistemi (Mevcut)
- [ ] Firebase Authentication entegrasyonu
- [ ] Firestore database kurulumu
- [ ] Temel çocuk profili yönetimi
- [ ] Basit çizim analizi (mock data)

### Faz 2: AI Entegrasyonu (6-8 hafta)
- [ ] Gemini API entegrasyonu
- [ ] Gemini Response Format entegrasyonu
- [ ] Psikolojik analiz algoritmaları
- [ ] Gerçek zamanlı analiz sistemi
- [ ] Sonuç raporlama sistemi (PDF)

### Faz 3: Gelişmiş Özellikler (4-6 hafta)
- [ ] Çoklu çocuk profili desteği
- [ ] Geçmiş analiz ve trend takibi
- [ ] PDF rapor oluşturma
- [ ] Push notification sistemi
- [ ] Offline mod desteği

### Faz 4: Sosyal ve Premium (6-8 hafta)
- [ ] Uzman danışmanlığı sistemi
- [ ] Ebeveyn forumu
- [ ] Premium abonelik sistemi
- [ ] Ödeme entegrasyonu (Stripe/PayPal)
- [ ] Aktivite öneril sistemi

### Faz 5: Optimizasyon ve Yayın (2-4 hafta)
- [ ] Performance optimizasyonu
- [ ] Security audit
- [ ] App Store/Play Store hazırlık
- [ ] Beta test süreci
- [ ] Marketing materyalleri

---

## 🔒 Güvenlik ve Gizlilik

### Veri Güvenliği
- **End-to-end şifreleme**: Tüm çizim verileri
- **GDPR Uyumluluğu**: Avrupa veri koruma
- **COPPA Uyumluluğu**: Çocuk veri koruma
- **Regular security audits**: Güvenlik denetimleri

### Gizlilik Önlemleri
- **Anonim analiz**: Kişisel veriler olmadan analiz
- **Veri minimizasyonu**: Sadece gerekli veri toplama
- **Kullanıcı kontrolü**: Veri silme ve indirme hakları
- **Şeffaflık**: Açık gizlilik politikası

---

## 📊 Başarı Metrikleri

### Kullanıcı Metrikleri
- **MAU (Monthly Active Users)**: Aylık aktif kullanıcı
- **Retention Rate**: Kullanıcı tutma oranı
- **Session Duration**: Ortalama kullanım süresi
- **Upload Frequency**: Çizim yükleme sıklığı

### İş Metrikleri
- **Conversion Rate**: Ücretsizden premium geçiş
- **ARPU (Average Revenue Per User)**: Kullanıcı başı gelir
- **Churn Rate**: Kullanıcı kaybı oranı
- **Customer Lifetime Value**: Müşteri yaşam boyu değeri

### Kalite Metrikleri
- **Analysis Accuracy**: Analiz doğruluğu
- **User Satisfaction**: Kullanıcı memnuniyeti
- **Expert Validation**: Uzman onayı oranı
- **Parent Feedback**: Ebeveyn geri bildirimi

---

## 🎯 Gelecek Vizyonu

### Kısa Vadeli Hedefler (6 ay)
- 10,000+ aktif kullanıcı
- 5 farklı çizim testi
- %15 premium dönüşüm oranı
- 4.5+ app store rating

### Orta Vadeli Hedefler (1 yıl)
- 50,000+ aktif kullanıcı
- Uzman danışmanlığı sistemi
- Eğitim kurumları partnerlikleri
- İngilizce dil desteği

### Uzun Vadeli Hedefler (2-3 yıl)
- 500,000+ aktif kullanıcı
- Uluslararası pazar genişlemesi
- AR/VR çizim deneyimi
- Akademik araştırma partnerlikleri

---

## 🤝 Ekip Gereksinimleri

### Geliştirme Ekibi
- **Flutter Developer (2)**: Mobil uygulama geliştirme
- **Backend Developer (1)**: Firebase ve Cloud Functions
- **ML Engineer (1)**: AI/ML model geliştirme
- **UI/UX Designer (1)**: Kullanıcı deneyimi tasarımı

### Uzman Ekibi
- **Çocuk Psikoloğu (1)**: İçerik validasyonu
- **Eğitim Uzmanı (1)**: Pedagojik içerik
- **Pediatrist (Danışman)**: Gelişim milestones

### İş Geliştirme
- **Product Manager (1)**: Ürün yönetimi
- **Marketing Specialist (1)**: Pazarlama stratejisi
- **Community Manager (1)**: Kullanıcı topluluk yönetimi

---

*Bu PRD, Inner Kid projesinin kapsamlı bir yol haritasını sunmaktadır. Bilimsel araştırmalara dayalı, çocuk odaklı ve kullanıcı dostu bir platform geliştirme hedefi ile hazırlanmıştır.* 