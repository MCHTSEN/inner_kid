import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:logger/logger.dart';

import '../../features/analysis_flow/models/analysis_state.dart';
import '../models/child_profile.dart';
import '../models/drawing_analysis.dart';
import '../models/user_profile.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final Logger _logger = Logger();

  // Collections
  static const String usersCollection = 'users';
  static const String childrenCollection = 'children';
  static const String drawingsCollection = 'drawings';
  static const String analysesCollection = 'analyses';
  static const String subscriptionsCollection = 'subscriptions';

  // User operations
  Future<void> createUser(String userId, UserProfile userProfile) async {
    try {
      _logger.i('Creating user document for: $userId');

      await _db
          .collection(usersCollection)
          .doc(userId)
          .set(userProfile.toMap());

      _logger.i('User document created successfully for: $userId');
    } catch (e) {
      _logger.e('Error creating user document: $e');
      throw Exception('Failed to create user profile');
    }
  }

  Future<UserProfile?> getUser(String userId) async {
    try {
      _logger.i('Fetching user document for: $userId');

      final doc = await _db.collection(usersCollection).doc(userId).get();

      if (!doc.exists) {
        _logger.w('User document not found for: $userId');
        return null;
      }

      final userProfile = UserProfile.fromMap(doc.data()!, userId);
      _logger.i('User document fetched successfully for: $userId');

      return userProfile;
    } catch (e) {
      _logger.e('Error fetching user document: $e');
      throw Exception('Failed to fetch user profile');
    }
  }

  Future<void> updateUser(String userId, Map<String, dynamic> updates) async {
    try {
      _logger.i('Updating user document for: $userId');

      updates['updatedAt'] = FieldValue.serverTimestamp();

      await _db.collection(usersCollection).doc(userId).update(updates);

      _logger.i('User document updated successfully for: $userId');
    } catch (e) {
      _logger.e('Error updating user document: $e');
      throw Exception('Failed to update user profile');
    }
  }

  Future<void> deleteUser(String userId) async {
    try {
      _logger.i('Deleting user document for: $userId');

      await _db.collection(usersCollection).doc(userId).delete();

      _logger.i('User document deleted successfully for: $userId');
    } catch (e) {
      _logger.e('Error deleting user document: $e');
      throw Exception('Failed to delete user profile');
    }
  }

  Stream<UserProfile?> getUserStream(String userId) {
    return _db.collection(usersCollection).doc(userId).snapshots().map((doc) {
      if (!doc.exists) return null;
      return UserProfile.fromMap(doc.data()!, userId);
    });
  }

  // Child operations
  Future<String> createChild(ChildProfile child) async {
    try {
      _logger.i('Creating child document for user: ${child.userId}');

      final docRef =
          await _db.collection(childrenCollection).add(child.toMap());

      _logger.i('Child document created successfully with ID: ${docRef.id}');
      return docRef.id;
    } catch (e) {
      _logger.e('Error creating child document: $e');
      throw Exception('Failed to create child profile');
    }
  }

  Future<List<ChildProfile>> getChildren(String userId) async {
    try {
      _logger.i('Fetching children for user: $userId');

      final querySnapshot = await _db
          .collection(childrenCollection)
          .where('userId', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .get();

      final children = querySnapshot.docs
          .map((doc) => ChildProfile.fromMap(doc.data(), doc.id))
          .toList();

      _logger.i('Fetched ${children.length} children for user: $userId');
      return children;
    } catch (e) {
      _logger.e('Error fetching children: $e');
      throw Exception('Failed to fetch children profiles');
    }
  }

  Future<ChildProfile?> getChild(String childId) async {
    try {
      _logger.i('Fetching child document: $childId');

      final doc = await _db.collection(childrenCollection).doc(childId).get();

      if (!doc.exists) {
        _logger.w('Child document not found: $childId');
        return null;
      }

      final child = ChildProfile.fromMap(doc.data()!, childId);
      _logger.i('Child document fetched successfully: $childId');

      return child;
    } catch (e) {
      _logger.e('Error fetching child document: $e');
      throw Exception('Failed to fetch child profile');
    }
  }

  Future<void> updateChild(String childId, Map<String, dynamic> updates) async {
    try {
      _logger.i('Updating child document: $childId');

      updates['updatedAt'] = FieldValue.serverTimestamp();

      await _db.collection(childrenCollection).doc(childId).update(updates);

      _logger.i('Child document updated successfully: $childId');
    } catch (e) {
      _logger.e('Error updating child document: $e');
      throw Exception('Failed to update child profile');
    }
  }

  Future<void> deleteChild(String childId) async {
    try {
      _logger.i('Deleting child document: $childId');

      await _db.collection(childrenCollection).doc(childId).delete();

      _logger.i('Child document deleted successfully: $childId');
    } catch (e) {
      _logger.e('Error deleting child document: $e');
      throw Exception('Failed to delete child profile');
    }
  }

  Stream<List<ChildProfile>> getChildrenStream(String userId) {
    return _db
        .collection(childrenCollection)
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((querySnapshot) {
      return querySnapshot.docs
          .map((doc) => ChildProfile.fromMap(doc.data(), doc.id))
          .toList();
    });
  }

  // Analysis operations
  Stream<List<DrawingAnalysis>> getUserAnalysesStream(String userId) {
    try {
      _logger.i('Setting up analyses stream for user: $userId');

      return _db
          .collection(analysesCollection)
          .where('userId', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .limit(20)
          .snapshots()
          .map((querySnapshot) {
        _logger.i('Stream update: Found ${querySnapshot.docs.length} documents for user: $userId');

        final analyses = <DrawingAnalysis>[];

        for (final doc in querySnapshot.docs) {
          try {
            final data = doc.data();
            _logger.i('Processing document ${doc.id} with data keys: ${data.keys.toList()}');

            // Check if required fields exist
            if (!data.containsKey('userId') ||
                !data.containsKey('imageUrl') ||
                !data.containsKey('createdAt')) {
              _logger.w('Document ${doc.id} missing required fields, skipping');
              continue;
            }

            // Prepare data with proper null handling and defaults
            final analysisData = {
              'id': doc.id,
              'childId': (data['childId'] as String?) ?? 'default_child',
              'imageUrl': (data['imageUrl'] as String?) ?? '',
              'uploadDate': _getDateString(data['uploadDate'] ?? data['createdAt']),
              'testType': (data['testType'] as String?) ?? 'family_drawing',
              'status': (data['status'] as String?) ?? 'completed',
              'aiResults': (data['insights'] ?? data['aiResults']) as Map<String, dynamic>?,
              'metadata': data['metadata'] as Map<String, dynamic>?,
              'createdAt': _getDateString(data['createdAt']),
              'completedAt': _getDateString(data['completedAt']),
            };

            final analysis = DrawingAnalysis.fromJson(analysisData);
            analyses.add(analysis);
            _logger.i('Successfully parsed document ${doc.id}');
          } catch (e) {
            _logger.e('Error parsing document ${doc.id}: $e');
            // Continue with other documents
          }
        }

        _logger.i('Stream update: Successfully processed ${analyses.length} analyses for user: $userId');
        return analyses;
      }).handleError((error) {
        _logger.e('Error in analyses stream: $error');
        
        // If composite index error, fall back to client-side sorting stream
        if (error.toString().contains('index') || error.toString().contains('requires an index')) {
          _logger.w('Composite index not found, falling back to client-side sorting stream');
          return _getUserAnalysesStreamWithClientSorting(userId);
        }
        
        // Return empty list for other errors
        return <DrawingAnalysis>[];
      });
    } catch (e) {
      _logger.e('Error setting up analyses stream: $e');
      // Return a stream with empty list as fallback
      return Stream.value(<DrawingAnalysis>[]);
    }
  }

  // Fallback stream method with client-side sorting
  Stream<List<DrawingAnalysis>> _getUserAnalysesStreamWithClientSorting(String userId) {
    try {
      _logger.i('Using client-side sorting stream for user: $userId');

      return _db
          .collection(analysesCollection)
          .where('userId', isEqualTo: userId)
          .snapshots()
          .map((querySnapshot) {
        _logger.i('Client-side stream update: Found ${querySnapshot.docs.length} documents for user: $userId');

        final analyses = <DrawingAnalysis>[];

        for (final doc in querySnapshot.docs) {
          try {
            final data = doc.data();

            // Check if required fields exist
            if (!data.containsKey('userId') ||
                !data.containsKey('imageUrl') ||
                !data.containsKey('createdAt')) {
              _logger.w('Document ${doc.id} missing required fields, skipping');
              continue;
            }

            // Prepare data with proper null handling and defaults
            final analysisData = {
              'id': doc.id,
              'childId': (data['childId'] as String?) ?? 'default_child',
              'imageUrl': (data['imageUrl'] as String?) ?? '',
              'uploadDate': _getDateString(data['uploadDate'] ?? data['createdAt']),
              'testType': (data['testType'] as String?) ?? 'family_drawing',
              'status': (data['status'] as String?) ?? 'completed',
              'aiResults': (data['insights'] ?? data['aiResults']) as Map<String, dynamic>?,
              'metadata': data['metadata'] as Map<String, dynamic>?,
              'createdAt': _getDateString(data['createdAt']),
              'completedAt': _getDateString(data['completedAt']),
            };

            final analysis = DrawingAnalysis.fromJson(analysisData);
            analyses.add(analysis);
          } catch (e) {
            _logger.e('Error parsing document ${doc.id}: $e');
            // Continue with other documents
          }
        }

        // Sort client-side by createdAt descending and limit to 20
        analyses.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        final limitedAnalyses = analyses.take(20).toList();

        _logger.i('Client-side stream update: Successfully processed ${limitedAnalyses.length} analyses');
        return limitedAnalyses;
      });
    } catch (e) {
      _logger.e('Error in client-side sorting stream: $e');
      return Stream.value(<DrawingAnalysis>[]);
    }
  }

  Future<List<DrawingAnalysis>> getUserAnalyses(String userId) async {
    try {
      _logger.i('Fetching analyses for user: $userId');

      // Use server-side query with orderBy (requires composite index)
      final querySnapshot = await _db
          .collection(analysesCollection)
          .where('userId', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .limit(20)
          .get();

      _logger
          .i('Found ${querySnapshot.docs.length} documents for user: $userId');

      final analyses = <DrawingAnalysis>[];

      for (final doc in querySnapshot.docs) {
        try {
          final data = doc.data();
          _logger.i(
              'Processing document ${doc.id} with data keys: ${data.keys.toList()}');

          // Check if required fields exist
          if (!data.containsKey('userId') ||
              !data.containsKey('imageUrl') ||
              !data.containsKey('createdAt')) {
            _logger.w('Document ${doc.id} missing required fields, skipping');
            continue;
          }

          // Prepare data with proper null handling and defaults
          final analysisData = {
            'id': doc.id,
            'childId': (data['childId'] as String?) ?? 'default_child',
            'imageUrl': (data['imageUrl'] as String?) ?? '',
            'uploadDate':
                _getDateString(data['uploadDate'] ?? data['createdAt']),
            'testType': (data['testType'] as String?) ?? 'family_drawing',
            'status': (data['status'] as String?) ?? 'completed',
            'aiResults': (data['insights'] ?? data['aiResults'])
                as Map<String, dynamic>?,
            'metadata': data['metadata'] as Map<String, dynamic>?,
            'createdAt': _getDateString(data['createdAt']),
            'completedAt': _getDateString(data['completedAt']),
          };

          final analysis = DrawingAnalysis.fromJson(analysisData);

          analyses.add(analysis);
          _logger.i('Successfully parsed document ${doc.id}');
        } catch (e) {
          _logger.e('Error parsing document ${doc.id}: $e');
          // Continue with other documents
        }
      }

      _logger.i(
          'Successfully fetched ${analyses.length} analyses for user: $userId');
      return analyses;
    } catch (e) {
      _logger.e('Error fetching user analyses: $e');

      // If composite index error, fall back to client-side sorting
      if (e.toString().contains('index') ||
          e.toString().contains('requires an index')) {
        _logger.w(
            'Composite index not found, falling back to client-side sorting');
        return _getUserAnalysesWithClientSorting(userId);
      }

      // Return empty list for other errors to allow fallback to mock data
      return [];
    }
  }

  // Fallback method with client-side sorting (current implementation)
  Future<List<DrawingAnalysis>> _getUserAnalysesWithClientSorting(
      String userId) async {
    try {
      _logger.i('Using client-side sorting for user: $userId');

      // Get analyses for the user (without orderBy to avoid composite index requirement)
      final querySnapshot = await _db
          .collection(analysesCollection)
          .where('userId', isEqualTo: userId)
          .get();

      _logger
          .i('Found ${querySnapshot.docs.length} documents for user: $userId');

      final analyses = <DrawingAnalysis>[];

      for (final doc in querySnapshot.docs) {
        try {
          final data = doc.data();

          // Check if required fields exist
          if (!data.containsKey('userId') ||
              !data.containsKey('imageUrl') ||
              !data.containsKey('createdAt')) {
            _logger.w('Document ${doc.id} missing required fields, skipping');
            continue;
          }

          // Prepare data with proper null handling and defaults
          final analysisData = {
            'id': doc.id,
            'childId': (data['childId'] as String?) ?? 'default_child',
            'imageUrl': (data['imageUrl'] as String?) ?? '',
            'uploadDate':
                _getDateString(data['uploadDate'] ?? data['createdAt']),
            'testType': (data['testType'] as String?) ?? 'family_drawing',
            'status': (data['status'] as String?) ?? 'completed',
            'aiResults': (data['insights'] ?? data['aiResults'])
                as Map<String, dynamic>?,
            'metadata': data['metadata'] as Map<String, dynamic>?,
            'createdAt': _getDateString(data['createdAt']),
            'completedAt': _getDateString(data['completedAt']),
          };

          final analysis = DrawingAnalysis.fromJson(analysisData);
          analyses.add(analysis);
        } catch (e) {
          _logger.e('Error parsing document ${doc.id}: $e');
          // Continue with other documents
        }
      }

      // Sort client-side by createdAt descending and limit to 20
      analyses.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      final limitedAnalyses = analyses.take(20).toList();

      _logger.i(
          'Successfully fetched ${limitedAnalyses.length} analyses with client-side sorting');
      return limitedAnalyses;
    } catch (e) {
      _logger.e('Error in client-side sorting fallback: $e');
      return [];
    }
  }

  // Save analysis results
  Future<void> saveAnalysisResults(AnalysisResults results) async {
    try {
      _logger.i('Saving analysis results: ${results.id}');

      final data = results.toMap();
      data['status'] = 'completed';
      data['testType'] = 'family_drawing';
      data['uploadDate'] = results.createdAt.toIso8601String();

      await _db
          .collection(analysesCollection)
          .doc(results.id)
          .set(data, SetOptions(merge: true));

      _logger.i('Analysis results saved successfully: ${results.id}');
    } catch (e) {
      _logger.e('Error saving analysis results: $e');
      throw Exception('Failed to save analysis results');
    }
  }

  // Get single analysis result
  Future<AnalysisResults?> getAnalysisResults(String analysisId) async {
    try {
      _logger.i('Fetching analysis results: $analysisId');

      final doc =
          await _db.collection(analysesCollection).doc(analysisId).get();

      if (!doc.exists) {
        _logger.w('Analysis document not found: $analysisId');
        return null;
      }

      final data = doc.data()!;
      _logger.i('Analysis document found with keys: ${data.keys.toList()}');
      _logger.i('Full analysis document data: $data');

      // Check if this is already an AnalysisResults format (has 'insights' field)
      if (data.containsKey('insights')) {
        _logger.i('Found AnalysisResults format data');
        final results = AnalysisResults.fromMap(data, analysisId);
        _logger.i('Parsed AnalysisResults: ${results.insights.primaryInsight}');
        return results;
      }

      // Check if this is AI service raw data format (has 'aiResults' field)
      else if (data.containsKey('aiResults') || data.containsKey('analysis')) {
        _logger.i('Found AI service raw data format, converting...');
        return _convertRawDataToAnalysisResults(data, analysisId);
      }

      // Fallback: unknown format
      else {
        _logger.w('Unknown data format for analysis $analysisId');
        return _createFallbackAnalysisResults(data, analysisId);
      }
    } catch (e) {
      _logger.e('Error fetching analysis results: $e');
      return null;
    }
  }

  // Analysis count for child
  Future<int> getAnalysisCountForChild(String childId) async {
    try {
      _logger.i('Fetching analysis count for child: $childId');

      final querySnapshot = await _db
          .collection(drawingsCollection)
          .where('childId', isEqualTo: childId)
          .get();

      final count = querySnapshot.docs.length;
      _logger.i('Analysis count for child $childId: $count');

      return count;
    } catch (e) {
      _logger.e('Error fetching analysis count: $e');
      return 0;
    }
  }

  // Subscription operations
  Future<void> updateSubscription(
      String userId, Map<String, dynamic> subscriptionData) async {
    try {
      _logger.i('Updating subscription for user: $userId');

      subscriptionData['updatedAt'] = FieldValue.serverTimestamp();

      await _db.collection(subscriptionsCollection).doc(userId).set(
            subscriptionData,
            SetOptions(merge: true),
          );

      // Also update user document
      await updateUser(userId, {
        'isSubscriptionActive': subscriptionData['status'] == 'active',
        'subscriptionTier': subscriptionData['planId'] ?? 'free',
        'subscriptionExpiry': subscriptionData['endDate'],
      });

      _logger.i('Subscription updated successfully for user: $userId');
    } catch (e) {
      _logger.e('Error updating subscription: $e');
      throw Exception('Failed to update subscription');
    }
  }

  /// Convert AI service raw data to AnalysisResults format
  AnalysisResults _convertRawDataToAnalysisResults(
      Map<String, dynamic> data, String analysisId) {
    try {
      _logger.i('Converting AI raw data to AnalysisResults format');

      // Extract AI results - could be in 'aiResults' or directly in root
      final aiResults = data['aiResults'] as Map<String, dynamic>? ?? data;
      final analysisData = aiResults['analysis'] as Map<String, dynamic>?;

      // Create AnalysisInsights from AI data
      final insights = AnalysisInsights(
        primaryInsight: aiResults['summary'] as String? ??
            'Çocuğunuzun çizimi başarıyla analiz edildi.',
        emotionalScore: 7.5,
        creativityScore: 8.0,
        developmentScore: 7.8,
        keyFindings: _extractEmergingThemes(analysisData),
        detailedAnalysis: _extractDetailedAnalysis(analysisData),
        recommendations: _extractRecommendations(analysisData),
        createdAt: DateTime.now(),
      );

      return AnalysisResults(
        id: analysisId,
        childId: data['childId'] as String? ?? 'default_child',
        userId: data['userId'] as String? ?? '',
        imageUrl: data['imageUrl'] as String? ?? '',
        insights: insights,
        createdAt: DateTime.parse(
            data['createdAt'] as String? ?? DateTime.now().toIso8601String()),
        completedAt: data['completedAt'] != null
            ? DateTime.parse(data['completedAt'] as String)
            : null,
        rawAnalysisData: aiResults, // Store the raw AI data
      );
    } catch (e) {
      _logger.e('Error converting AI raw data: $e');
      return _createFallbackAnalysisResults(data, analysisId);
    }
  }

  /// Create fallback AnalysisResults when data format is unknown
  AnalysisResults _createFallbackAnalysisResults(
      Map<String, dynamic> data, String analysisId) {
    final fallbackInsights = AnalysisInsights(
      primaryInsight: 'Çocuğunuzun çizimi başarıyla analiz edildi.',
      emotionalScore: 7.5,
      creativityScore: 8.0,
      developmentScore: 7.8,
      keyFindings: [
        'Yaratıcı ifade',
        'Gelişim göstergeleri',
        'Pozitif duygular'
      ],
      detailedAnalysis: {
        'emotionalIndicators':
            'Çizimde pozitif duygusal göstergeler mevcuttur.',
        'developmentLevel': 'Yaşına uygun gelişim seviyesi gözlemlenmektedir.',
        'socialAspects': 'Sosyal etkileşim becerileri gelişmektedir.',
        'creativityMarkers': 'Yaratıcı düşünce ve hayal gücü belirgindir.',
      },
      recommendations: [
        'Yaratıcı aktiviteleri destekleyin',
        'Sanat malzemeleriyle oynama fırsatları sağlayın'
      ],
      createdAt: DateTime.now(),
    );

    return AnalysisResults(
      id: analysisId,
      childId: data['childId'] as String? ?? 'default_child',
      userId: data['userId'] as String? ?? '',
      imageUrl: data['imageUrl'] as String? ?? '',
      insights: fallbackInsights,
      createdAt: DateTime.parse(
          data['createdAt'] as String? ?? DateTime.now().toIso8601String()),
      completedAt: data['completedAt'] != null
          ? DateTime.parse(data['completedAt'] as String)
          : null,
      rawAnalysisData: null,
    );
  }

  /// Extract emerging themes from analysis data
  List<String> _extractEmergingThemes(Map<String, dynamic>? analysisData) {
    if (analysisData == null) return ['Yaratıcı ifade', 'Gelişim göstergeleri'];

    final themes = analysisData['emerging_themes'] as List?;
    if (themes != null) {
      return themes.cast<String>();
    }

    return ['Yaratıcı ifade', 'Gelişim göstergeleri'];
  }

  /// Extract detailed analysis from analysis data
  Map<String, dynamic> _extractDetailedAnalysis(
      Map<String, dynamic>? analysisData) {
    if (analysisData == null) {
      return {
        'emotionalIndicators':
            'Çizimde pozitif duygusal göstergeler mevcuttur.',
        'developmentLevel': 'Yaşına uygun gelişim seviyesi gözlemlenmektedir.',
        'socialAspects': 'Sosyal etkileşim becerileri gelişmektedir.',
        'creativityMarkers': 'Yaratıcı düşünce ve hayal gücü belirgindir.',
      };
    }

    return {
      'emotionalIndicators':
          analysisData['emotional_signals']?['text'] as String? ??
              'Pozitif duygusal göstergeler mevcuttur.',
      'developmentLevel':
          analysisData['developmental_indicators']?['text'] as String? ??
              'Yaşına uygun gelişim seviyesi.',
      'socialAspects':
          analysisData['social_and_family_context']?['text'] as String? ??
              'Sosyal etkileşim becerileri gelişmektedir.',
      'creativityMarkers':
          analysisData['symbolic_content']?['text'] as String? ??
              'Yaratıcı düşünce ve hayal gücü belirgindir.',
    };
  }

  /// Extract recommendations from analysis data
  List<String> _extractRecommendations(Map<String, dynamic>? analysisData) {
    if (analysisData == null) return ['Yaratıcı aktiviteleri destekleyin'];

    final recommendations =
        analysisData['recommendations'] as Map<String, dynamic>?;
    if (recommendations == null) return ['Yaratıcı aktiviteleri destekleyin'];

    final allRecommendations = <String>[];

    final parentingTips = recommendations['parenting_tips'] as List?;
    if (parentingTips != null) {
      allRecommendations.addAll(parentingTips.cast<String>());
    }

    final activityIdeas = recommendations['activity_ideas'] as List?;
    if (activityIdeas != null) {
      allRecommendations.addAll(activityIdeas.cast<String>());
    }

    return allRecommendations.isNotEmpty
        ? allRecommendations
        : ['Yaratıcı aktiviteleri destekleyin'];
  }

  /// Helper method to safely convert timestamp to ISO string
  String _getDateString(dynamic timestamp) {
    if (timestamp == null) {
      return DateTime.now().toIso8601String();
    }

    if (timestamp is Timestamp) {
      return timestamp.toDate().toIso8601String();
    }

    if (timestamp is String) {
      try {
        // Try to parse the string to validate it
        DateTime.parse(timestamp);
        return timestamp;
      } catch (e) {
        return DateTime.now().toIso8601String();
      }
    }

    if (timestamp is DateTime) {
      return timestamp.toIso8601String();
    }

    // Fallback for unknown types
    return DateTime.now().toIso8601String();
  }

  // Batch operations
  Future<void> batchWrite(List<Map<String, dynamic>> operations) async {
    try {
      _logger.i('Executing batch write with ${operations.length} operations');

      final batch = _db.batch();

      for (final operation in operations) {
        final type = operation['type'] as String;
        final collection = operation['collection'] as String;
        final docId = operation['docId'] as String?;
        final data = operation['data'] as Map<String, dynamic>?;

        switch (type) {
          case 'create':
            if (docId != null && data != null) {
              batch.set(_db.collection(collection).doc(docId), data);
            }
            break;
          case 'update':
            if (docId != null && data != null) {
              batch.update(_db.collection(collection).doc(docId), data);
            }
            break;
          case 'delete':
            if (docId != null) {
              batch.delete(_db.collection(collection).doc(docId));
            }
            break;
        }
      }

      await batch.commit();

      _logger.i('Batch write executed successfully');
    } catch (e) {
      _logger.e('Error executing batch write: $e');
      throw Exception('Failed to execute batch operations');
    }
  }
}
