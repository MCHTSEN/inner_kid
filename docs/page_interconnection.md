
# Page Interconnection and Navigation Flow

This document describes the navigation flow and how different pages and features are interconnected within the Inner Kid application.

## 1. Main Navigation

The primary navigation is handled by the `MainNavigation` widget (`lib/core/navigation/main_navigation.dart`), which uses a custom `FloatingBottomNav` widget. This serves as the main container for the app's core features after the user is authenticated.

### Core Navigation Flow:

-   **`SplashPage`**: The initial entry point of the app. It checks if the user is a first-time visitor and their authentication status.
    -   **First-time user**: Navigates to `LandingPage`.
    -   **Returning user (not authenticated)**: Navigates to `LoginPage`.
    -   **Returning user (authenticated)**: Navigates to `MainNavigation` (the main app).

-   **`LandingPage`**: Introduces the app to new users and provides options to either start the analysis (`FirstAnalysisPage`) or log in (`LoginPage`).

-   **`LoginPage`**: Handles user authentication (sign-in and registration). Upon successful authentication, it navigates to `MainNavigation`.

-   **`MainNavigation`**: The central hub of the app, containing the following pages accessible via the `FloatingBottomNav`:
    -   **AnimationPage**: A placeholder for a future feature to animate drawings.
    -   **ProfilePage**: Displays user and child profiles, and app settings.
    -   **HomeDashboardPage**: The main dashboard, showing daily insights, recent analyses, and recommendations.
    -   **DrawingTestsPage**: Lists available drawing tests for the user to start.

## 2. Analysis Flow

The drawing analysis flow is a critical user journey with several interconnected pages:

1.  **Triggering the Analysis**: The analysis can be initiated from multiple points:
    -   The central "Analiz Et" button on the `FloatingBottomNav`.
    -   The "Analiz Başlat" button on the `LandingPage`.
    -   The `AnalysisPage` itself, which immediately prompts for an image.

2.  **Image Selection**: The user selects an image from the gallery or camera. This is handled by the `ImageUploadWidget` and `NativeDialogs`.

3.  **Questionnaire**: After uploading an image, the user is presented with a series of questions in the `FirstAnalysisPage` to provide context for the analysis.

4.  **Analysis Loading**: Upon submitting the questions, the user is navigated to the `AnalysisWaitingPage`, which displays a trust-building loading animation while the AI processes the drawing.

5.  **Results Display**: Once the analysis is complete, the user is automatically navigated to the `AnalysisResultsPage`.
    -   **Premium Gating**: If the user is not a premium subscriber, the results are blurred, and a paywall (`PaywallWidget`) is presented.
    -   **Full Results**: After a successful premium upgrade, the blur is removed, and the full, detailed analysis is displayed.

## 3. Feature-Specific Navigation

-   **Profile Management**:
    -   The `ProfilePage` displays a list of child profiles.
    -   An "Add Child" card allows the user to create a new child profile (future implementation).
    -   Users can view past analyses for each child by tapping on their profile (future implementation).

-   **Home Dashboard**:
    -   The `HomeDashboardPage` displays a summary of recent analyses.
    -   Tapping on a recent analysis card navigates the user to the `AnalysisResultsPage` for that specific analysis.

## 4. Key Navigational Components

-   **`FloatingBottomNav` (`lib/core/widgets/floating_bottom_nav.dart`)**: A custom bottom navigation bar that provides access to the main sections of the app. The central "Analiz Et" button is a key entry point to the analysis flow.

-   **`MainNavigation` (`lib/core/navigation/main_navigation.dart`)**: A `StatefulWidget` that manages the currently selected page in the bottom navigation bar.

-   **`Navigator` and `MaterialPageRoute`**: Standard Flutter navigation is used for pushing new pages onto the navigation stack (e.g., navigating from the analysis flow to the results page).

-   **Riverpod for State-Driven Navigation**: The `authViewModelProvider` is used in the `SplashPage` to determine the initial navigation route based on the user's authentication state. This is a clean way to handle auth-based routing.
