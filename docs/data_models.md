
# Data Models

This document provides an overview of the core data models used in the Inner Kid application. These models are essential for structuring data, ensuring type safety, and handling data serialization/deserialization.

## 1. Core Models (`lib/core/models`)

These models represent the fundamental entities of the application.

### `UserProfile`

-   **File**: `lib/core/models/user_profile.dart`
-   **Description**: Represents a registered user of the application.
-   **Key Fields**:
    -   `id`: Unique identifier (matches Firebase Auth UID).
    -   `email`: User's email address.
    -   `name`: User's display name.
    -   `photoUrl`: URL for the user's profile picture.
    -   `isSubscriptionActive`: Boolean indicating if the user has an active subscription.
    -   `subscriptionTier`: The user's subscription level (e.g., 'free', 'premium').
-   **Methods**: Includes `fromMap` and `toMap` for Firestore serialization.

### `ChildProfile`

-   **File**: `lib/core/models/child_profile.dart`
-   **Description**: Represents a child's profile, created by a parent (user).
-   **Key Fields**:
    -   `id`: Unique identifier for the child's profile.
    -   `userId`: The ID of the parent user.
    -   `name`: The child's name.
    -   `birthDate`: The child's date of birth.
    -   `gender`: The child's gender.
-   **Computed Properties**:
    -   `ageInYears`: Calculates the child's age in years.
    -   `ageInMonths`: Calculates the child's age in months.
-   **Methods**: Includes `fromMap`, `toMap`, `fromJson`, and `toJson` for data handling.

### `DrawingAnalysis` & `DrawingAnalysisModel`

-   **File**: `lib/core/models/drawing_analysis.dart`
-   **Description**: A comprehensive model that represents a single drawing analysis. This is the primary model for storing and displaying AI-generated insights.
-   **`DrawingTestType` (Enum)**: Defines the different types of drawing tests (e.g., `self_portrait`, `family_drawing`).
-   **`AnalysisStatus` (Enum)**: Represents the status of an analysis (e.g., `pending`, `processing`, `completed`).
-   **`DrawingAnalysisModel`**: Represents the direct output from the AI service.
    -   `summary`: A high-level summary of the analysis.
    -   `analysis`: A nested `Analysis` object containing detailed insights.
-   **`Analysis`**: Contains the detailed breakdown of the AI analysis:
    -   `emotionalSignals`: Text describing emotional indicators.
    -   `developmentalIndicators`: Text on developmental aspects.
    -   `symbolicContent`: Interpretation of symbols in the drawing.
    -   `socialAndFamilyContext`: Insights into social and family dynamics.
    -   `emergingThemes`: A list of key themes identified.
    -   `recommendations`: A nested `Recommendations` object.
-   **`Recommendations`**: Contains lists of `parentingTips` and `activityIdeas`.
-   **`DrawingAnalysis`**: The main model that wraps the AI results with additional metadata.
    -   `id`: Unique ID for the analysis.
    -   `childId`: The ID of the child who created the drawing.
    -   `imageUrl`: The URL of the analyzed drawing.
    -   `aiResults`: The `DrawingAnalysisModel` containing the AI insights.

## 2. Feature-Specific Models

These models are tailored to the state management needs of specific features.

### `AuthState`

-   **File**: `lib/features/auth/models/auth_state.dart`
-   **Description**: Represents the authentication state of the application.
-   **`AuthStatus` (Enum)**: Defines the possible authentication statuses (`initial`, `loading`, `authenticated`, `unauthenticated`, `error`).
-   **Key Fields**:
    -   `status`: The current `AuthStatus`.
    -   `firebaseUser`: The `User` object from Firebase Auth.
    -   `userProfile`: The `UserProfile` object from Firestore.
    -   `errorMessage`: Any error message from the authentication process.

### `AnalysisState` (Analysis Flow)

-   **File**: `lib/features/analysis_flow/models/analysis_state.dart`
-   **Description**: Manages the state of the multi-step drawing analysis process.
-   **`AnalysisStatus` (Enum)**: Reuses the core enum to track the analysis progress.
-   **Key Fields**:
    -   `status`: The current `AnalysisStatus`.
    -   `selectedImage`: The `File` object of the uploaded image.
    -   `analysisId`: The unique ID for the current analysis.
    -   `progress`: An `AnalysisProgress` object to track the loading progress.
    -   `results`: An `AnalysisResults` object containing the final results.

### `FirstAnalysisState`

-   **File**: `lib/features/first_analysis/models/first_analysis_state.dart`
-   **Description**: Manages the state of the initial analysis flow, including the questionnaire.
-   **Key Fields**:
    -   `uploadedImage`: The `File` object of the uploaded drawing.
    -   `questions`: A list of `AnalysisQuestion` objects.
    -   `isImageUploaded`: A boolean to track if the image has been uploaded.
    -   `isCompleted`: A boolean to track if the questionnaire is complete.

### `AnalysisQuestion`

-   **File**: `lib/features/first_analysis/models/analysis_question.dart`
-   **Description**: Represents a single question in the analysis questionnaire.
-   **Key Fields**:
    -   `id`: Unique identifier for the question.
    -   `question`: The text of the question.
    -   `options`: A list of possible answers.
    -   `selectedAnswer`: The answer selected by the user.
