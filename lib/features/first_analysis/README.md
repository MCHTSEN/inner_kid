# First Analysis Feature

## Overview

The First Analysis feature allows users to upload a child's drawing and answer a series of questions to provide context for psychological analysis. The feature follows a step-by-step flow with smooth animations and intuitive UI/UX.

## Architecture

The feature follows the MVVM (Model-View-ViewModel) pattern with clean separation of concerns:

```
lib/features/first_analysis/
├── models/
│   ├── analysis_question.dart      # Question data model
│   └── first_analysis_state.dart   # State management model
├── viewmodel/
│   └── first_analysis_viewmodel.dart # Business logic & state management
├── components/
│   ├── image_upload_widget.dart     # Image upload UI component
│   ├── question_widget.dart         # Question display & interaction
│   └── progress_indicator_widget.dart # Progress tracking UI
├── first_analysis_page.dart        # Main page view
└── README.md                       # This documentation
```

## User Flow

1. **Initial State**: User sees only the image upload widget
2. **Image Upload**: User can upload from gallery or camera
3. **Questions Appear**: After image upload, questions appear one by one
4. **Progressive Answering**: Each answered question collapses to a summary line
5. **Completion**: All questions answered shows submit button
6. **Submission**: Data is sent for analysis

## Components

### Models

#### `AnalysisQuestion`
```dart
class AnalysisQuestion {
  final String id;           // Unique identifier
  final String question;     // Question text
  final List<String> options; // Answer options
  final String? selectedAnswer; // Selected answer
  
  bool get isAnswered; // Helper getter
}
```

#### `FirstAnalysisState`
```dart
class FirstAnalysisState {
  final File? uploadedImage;        // Uploaded image file
  final List<AnalysisQuestion> questions; // All questions
  final int currentQuestionIndex;   // Current active question
  final bool isImageUploaded;      // Image upload status
  final bool isCompleted;          // Analysis completion status
  final bool isLoading;            // Loading state
  
  // Helper getters
  AnalysisQuestion? get currentQuestion;
  List<AnalysisQuestion> get answeredQuestions;
  bool get allQuestionsAnswered;
  double get progress;
}
```

### ViewModel

#### `FirstAnalysisViewModel`
Manages the business logic and state using Riverpod StateNotifier:

**Key Methods:**
- `uploadImageFromGallery()` - Upload from device gallery
- `uploadImageFromCamera()` - Upload from device camera  
- `answerQuestion(String questionId, String answer)` - Answer a question
- `submitAnalysis()` - Submit completed analysis
- `reset()` - Reset the entire analysis

**Provider:**
```dart
final firstAnalysisViewModelProvider = 
    StateNotifierProvider<FirstAnalysisViewModel, FirstAnalysisState>(
  (ref) => FirstAnalysisViewModel(),
);
```

### UI Components

#### `ImageUploadWidget`
- **Purpose**: Handles image upload with visual feedback
- **Features**: 
  - Dashed border placeholder when empty
  - Loading indicator during upload
  - Success state with checkmark when uploaded
  - Tap to trigger upload options

#### `QuestionWidget`
- **Purpose**: Displays questions with smooth expand/collapse animations
- **Features**:
  - Animated expansion when question becomes active
  - Radio button style options
  - Collapse to summary line when answered
  - Visual feedback for selection states

#### `ProgressIndicatorWidget`
- **Purpose**: Shows overall progress through the analysis flow
- **Features**:
  - Animated progress bar
  - Step indicators with checkmarks
  - Percentage completion display
  - Step counting (image + questions)

## Animations & UX

### Page Transitions
- Fade-in animation on page load (1000ms)
- Smooth transitions between states

### Question Animations
- Height and opacity animations for expand/collapse (600ms)
- Staggered animations (height first, then opacity)
- Curve: `Curves.easeOutCubic` for natural feel

### Progress Animations
- Progress bar fills smoothly (800ms)
- Step indicators animate on completion

### Interaction Feedback
- Button hover/press states
- Loading spinners during operations
- Success confirmations with dialogs

## State Management

Uses Flutter Riverpod for reactive state management:

1. **State Updates**: ViewModel updates state immutably
2. **UI Reactions**: Widgets rebuild automatically on state changes
3. **Side Effects**: Async operations handled in ViewModel
4. **Provider Scope**: Single source of truth for analysis state

## Error Handling

- Image picker errors are caught and handled gracefully
- Loading states prevent multiple simultaneous operations
- Validation ensures all questions are answered before submission
- Reset functionality allows starting over

## Accessibility

- Semantic labels for screen readers
- High contrast colors for text and backgrounds
- Large touch targets for buttons
- Clear visual hierarchy

## Future Enhancements

1. **Persistence**: Save draft analysis state
2. **Validation**: Enhanced input validation
3. **Offline Support**: Cache analysis data
4. **Custom Questions**: Dynamic question loading
5. **Multi-language**: Internationalization support

## Usage Example

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'first_analysis_page.dart';

// Navigate to first analysis
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => const FirstAnalysisPage(),
  ),
);

// Or use in a ProviderScope
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ProviderScope(
      child: MaterialApp(
        home: FirstAnalysisPage(),
      ),
    );
  }
}
```

## Dependencies

- `flutter_riverpod: ^2.6.1` - State management
- `image_picker: ^1.0.8` - Image selection
- `google_fonts: ^6.1.0` - Typography
- Custom theme from `inner_kid/core/theme/theme.dart`

## Testing Considerations

1. **Unit Tests**: Test ViewModel logic and state transitions
2. **Widget Tests**: Test individual component behavior
3. **Integration Tests**: Test complete user flow
4. **Golden Tests**: Visual regression testing for UI components 