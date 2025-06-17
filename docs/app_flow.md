```mermaid
graph TD
    A[Splash Screen] --> B{İlk Defa mı?}
    B -->|Evet| C[Landing Page]
    B -->|Hayır| D{Giriş Yapmış mı?}
    D -->|Evet| E[Home Dashboard]
    D -->|Hayır| F[Login Page]
    
    C --> G[First Analysis Page]
    F --> H[Register Page]
    F --> I[Google Sign-In]
    H --> J[Email/Password Register]
    I --> E
    J --> E
    
    G --> K[Resim Yükle - State'te Tut]
    K --> L[Soruları Yanıtla]
    L --> M[Fake Loading Widget]
    M --> N[Results Page - Blurred + Paywall]
    
    N --> O{Ödeme Yapıldı mı?}
    O -->|Hayır| P[Paywall - Subscription Plans]
    P --> Q[Payment Processing]
    Q -->|Başarılı| R[Premium Unlocked]
    Q -->|Başarısız| P
    
    O -->|Evet| S{Giriş Yapmış mı?}
    R --> S
    S -->|Hayır| T[Auth Required - Login/Register]
    S -->|Evet| U[Gerçek AI Analizi Başlat]
    
    T --> F
    T --> H
    
    U --> V[Firebase Storage'a Resim Yükle]
    V --> W[Gemini AI Analizi]
    W --> X[Firestore'a Sonuçları Kaydet]
    X --> E
    
    E --> Y[Analizleri Görüntüle]
    E --> Z[Yeni Analiz Başlat]
    Z --> G