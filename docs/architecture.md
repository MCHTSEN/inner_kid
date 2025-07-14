
# Project Architecture

This document outlines the architecture of the Inner Kid Flutter application. The project follows a modern, scalable, and maintainable architecture based on the **MVVM (Model-View-ViewModel)** pattern, with principles from **Clean Architecture**.

## 1. Directory Structure

The project is organized into a feature-based directory structure, which promotes separation of concerns and modularity.

```
lib/
├── core/              # Core functionalities, shared across features
│   ├── constants/     # App-wide constants (e.g., assets, colors)
│   ├── di/            # Dependency Injection (Riverpod providers)
│   ├── extension/     # Dart extensions for core types
│   ├── helper/        # Helper widgets and functions
│   ├── models/        # Core data models (e.g., UserProfile, ChildProfile)
│   ├── navigation/    # Main navigation logic (e.g., Bottom Nav Bar)
│   ├── services/      # Business logic services (e.g., Auth, Firestore)
│   ├── theme/         # App theme and styling
│   └── widgets/       # Shared custom widgets
│
├── features/          # Individual feature modules
│   ├── auth/          # Authentication (login, register)
│   ├── analysis_flow/ # AI-powered drawing analysis flow
│   ├── home_dashboard/ # Main user dashboard
│   └── ...            # Other features like profile, landing, etc.
│
├── main.dart          # App entry point
└── widgets/           # General-purpose widgets (could be merged into core/widgets)
```

## 2. Architectural Pattern: MVVM

The application primarily uses the **MVVM (Model-View-ViewModel)** pattern for managing UI and business logic.

-   **Model**: Represents the data and business logic. These are the data structures found in `lib/core/models` and `lib/features/*/models`. They handle data validation, conversion (e.g., `fromJson`, `toJson`), and business rules.
-   **View**: The UI of the application, composed of Widgets. These are located in `lib/features/*/views` and `lib/features/*/components`. They are responsible for displaying data and capturing user input, but they do not contain any business logic.
-   **ViewModel**: Acts as a bridge between the Model and the View. It holds the state and business logic for a specific feature. ViewModels are implemented as `StateNotifier` classes from the **Riverpod** package and are located in `lib/features/*/viewmodels`. They expose state to the View and handle user actions.

## 3. State Management: Riverpod

**Riverpod** is used as the primary state management and dependency injection solution.

-   **Providers**: Located in `lib/core/di/providers.dart`, these providers are used to instantiate and provide services (like `AuthService`, `FirestoreService`) to the ViewModels and other parts of the app. This decouples services from their consumers.
-   **StateNotifierProvider**: Used for creating and providing ViewModels (e.g., `authViewModelProvider`, `analysisViewModelProvider`). Widgets `watch` these providers to reactively rebuild when the state changes.
-   **FutureProvider**: Used for handling asynchronous operations, such as fetching initial data for the `HomeDashboardPage`.

## 4. Backend Integration: Firebase

The application is powered by **Firebase** for its backend services.

-   **Authentication**: `firebase_auth` is used for user authentication (email/password and Google Sign-In). The `AuthService` (`lib/core/services/auth_service.dart`) encapsulates all authentication logic.
-   **Database**: `cloud_firestore` is used as the primary database for storing user profiles, child profiles, and analysis results. The `FirestoreService` (`lib/core/services/firestore_service.dart`) abstracts all database operations.
-   **Storage**: `firebase_storage` is used for storing user-uploaded images (drawings, avatars). The `StorageService` (`lib/core/services/storage_service.dart`) handles all file upload and download logic.

## 5. AI Analysis Service

A key feature of the app is the AI-powered drawing analysis.

-   **Service**: The `AIAnalysisService` (`lib/core/services/ai_analysis_service.dart`) is responsible for communicating with an external AI provider (currently OpenAI).
-   **Flow**:
    1.  The image is first uploaded to Firebase Storage to get a public URL.
    2.  A detailed prompt, including child context and the image URL, is sent to the AI API.
    3.  The JSON response from the AI is parsed into the `DrawingAnalysisModel`.
    4.  The results are stored in Firestore for future access.
-   **Fallback Mechanism**: The service includes a fallback to mock data if the real AI analysis fails, ensuring a smooth user experience.

## 6. Code Conventions

-   **Extensions**: Dart's extension methods are used extensively (`lib/core/extension`) to add utility functions to existing classes (e.g., `String`, `Widget`), promoting cleaner and more readable code.
-   **Constants**: UI constants like colors, radii, and asset paths are centralized in the `lib/core/constants` directory for consistency and easy maintenance.
-   **Theming**: A dedicated `AppTheme` class (`lib/core/theme/theme.dart`) defines the application's color palette, typography (using Google Fonts), and component styles.
