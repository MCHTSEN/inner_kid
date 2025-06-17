import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:logger/logger.dart';

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

          // Prepare data with defaults for missing fields
          final analysisData = {
            'id': doc.id,
            'userId': data['userId'],
            'childId': data['childId'] ?? 'default_child',
            'imageUrl': data['imageUrl'],
            'uploadDate': data['uploadDate'] ??
                data['createdAt'], // Use createdAt as fallback
            'testType':
                data['testType'] ?? 'family_drawing', // Default test type
            'status': data['status'] ?? 'completed',
            'aiResults': data['insights'] ??
                data['aiResults'], // Support both field names
            'expertComments': data['expertComments'],
            'recommendations': data['recommendations'] ?? <String>[],
            'metadata': data['metadata'],
            'createdAt': data['createdAt'],
            'completedAt': data['completedAt'],
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

          // Prepare data with defaults for missing fields
          final analysisData = {
            'id': doc.id,
            'userId': data['userId'],
            'childId': data['childId'] ?? 'default_child',
            'imageUrl': data['imageUrl'],
            'uploadDate': data['uploadDate'] ?? data['createdAt'],
            'testType': data['testType'] ?? 'family_drawing',
            'status': data['status'] ?? 'completed',
            'aiResults': data['insights'] ?? data['aiResults'],
            'expertComments': data['expertComments'],
            'recommendations': data['recommendations'] ?? <String>[],
            'metadata': data['metadata'],
            'createdAt': data['createdAt'],
            'completedAt': data['completedAt'],
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
