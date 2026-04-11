import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/leaderboard_model.dart';

class LeaderboardService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  /// Base query for leaderboard (reusable)
  Future<List<LeaderboardEntry>> _getLeaderboardByField(String field) async {
    final snapshot = await _db
        .collection('users')
        .orderBy(field, descending: true)
        .limit(50)
        .get();

    return snapshot.docs
        .asMap()
        .entries
        .map((e) => LeaderboardEntry.fromFirestore(e.value, e.key + 1))
        .toList();
  }

  /// Community/Barangay leaderboard (aggregates points by barangay)
  Future<List<LeaderboardEntry>> getWeeklyCommunitLeaderboard() async {
    try {
      final snapshot = await _db
          .collection('users')
          .get();

      // If no data or insufficient data, use mock data
      if (snapshot.docs.isEmpty) {
        return _getMockCommunityLeaderboard(true);
      }

      // Group users by barangay and sum points
      final Map<String, dynamic> communityData = {};
      int validUsers = 0;
      
      for (var doc in snapshot.docs) {
        final data = doc.data();
        final barangay = data['barangay']?.toString().trim() ?? '';
        
        // Skip users without a barangay
        if (barangay.isEmpty || barangay.toLowerCase() == 'unknown') {
          continue;
        }
        
        validUsers++;
        final points = data['points'] ?? 0;
        final jobsFinished = data['jobsFinished'] ?? 0;
        
        if (!communityData.containsKey(barangay)) {
          communityData[barangay] = {
            'points': 0,
            'jobsFinished': 0,
            'count': 0,
          };
        }
        
        communityData[barangay]['points'] += points;
        communityData[barangay]['jobsFinished'] += jobsFinished;
        communityData[barangay]['count'] += 1;
      }

      // If no valid users with barangay, use mock data
      if (validUsers == 0 || communityData.isEmpty) {
        return _getMockCommunityLeaderboard(true);
      }

      // Convert to LeaderboardEntry list sorted by points
      List<LeaderboardEntry> communities = communityData.entries
          .map((e) => LeaderboardEntry(
            userId: 'community_${e.key}',
            username: '${e.key} Community',
            avatarUrl: null,
            barangay: e.key,
            city: 'Iloilo City',
            points: e.value['points'],
            jobsFinished: e.value['jobsFinished'],
            rank: 0, // Will be set below
          ))
          .toList();

      // Sort by points descending
      communities.sort((a, b) => b.points.compareTo(a.points));

      // Set ranks
      for (int i = 0; i < communities.length; i++) {
        communities[i] = LeaderboardEntry(
          userId: communities[i].userId,
          username: communities[i].username,
          avatarUrl: communities[i].avatarUrl,
          barangay: communities[i].barangay,
          city: communities[i].city,
          points: communities[i].points,
          jobsFinished: communities[i].jobsFinished,
          rank: i + 1,
        );
      }

      return communities;
    } catch (e) {
      // Fallback to mock data on error
      return _getMockCommunityLeaderboard(true);
    }
  }

  /// Get mock community leaderboard
  List<LeaderboardEntry> _getMockCommunityLeaderboard(bool isWeekly) {
    if (isWeekly) {
      return [
        const LeaderboardEntry(userId: 'community_rizal', username: 'Brgy. Rizal Community', avatarUrl: null, barangay: 'Brgy. Rizal', city: 'Iloilo City', points: 2085, jobsFinished: 22, rank: 1),
        const LeaderboardEntry(userId: 'community_balabago', username: 'Balabago Community', avatarUrl: null, barangay: 'Balabago', city: 'Iloilo City', points: 1188, jobsFinished: 12, rank: 2),
        const LeaderboardEntry(userId: 'community_calumpang', username: 'Calumpang Community', avatarUrl: null, barangay: 'Calumpang', city: 'Iloilo City', points: 1102, jobsFinished: 11, rank: 3),
        const LeaderboardEntry(userId: 'community_obrero', username: 'Bo. Obrero Community', avatarUrl: null, barangay: 'Bo. Obrero', city: 'Iloilo City', points: 948, jobsFinished: 9, rank: 4),
      ];
    } else {
      return [
        const LeaderboardEntry(userId: 'community_rizal', username: 'Brgy. Rizal Community', avatarUrl: null, barangay: 'Brgy. Rizal', city: 'Iloilo City', points: 9240, jobsFinished: 82, rank: 1),
        const LeaderboardEntry(userId: 'community_balabago', username: 'Balabago Community', avatarUrl: null, barangay: 'Balabago', city: 'Iloilo City', points: 8420, jobsFinished: 67, rank: 2),
        const LeaderboardEntry(userId: 'community_calumpang', username: 'Calumpang Community', avatarUrl: null, barangay: 'Calumpang', city: 'Iloilo City', points: 7920, jobsFinished: 68, rank: 3),
        const LeaderboardEntry(userId: 'community_obrero', username: 'Bo. Obrero Community', avatarUrl: null, barangay: 'Bo. Obrero', city: 'Iloilo City', points: 7125, jobsFinished: 61, rank: 4),
      ];
    }
  }

  /// Monthly community leaderboard
  Future<List<LeaderboardEntry>> getMonthlyCommunitLeaderboard() async {
    try {
      final snapshot = await _db
          .collection('users')
          .get();

      // If no data or insufficient data, use mock data
      if (snapshot.docs.isEmpty) {
        return _getMockCommunityLeaderboard(false);
      }

      // Group users by barangay and sum points
      final Map<String, dynamic> communityData = {};
      int validUsers = 0;
      
      for (var doc in snapshot.docs) {
        final data = doc.data();
        final barangay = data['barangay']?.toString().trim() ?? '';
        
        // Skip users without a barangay
        if (barangay.isEmpty || barangay.toLowerCase() == 'unknown') {
          continue;
        }
        
        validUsers++;
        final points = data['points'] ?? 0;
        final jobsFinished = data['jobsFinished'] ?? 0;
        
        if (!communityData.containsKey(barangay)) {
          communityData[barangay] = {
            'points': 0,
            'jobsFinished': 0,
            'count': 0,
          };
        }
        
        communityData[barangay]['points'] += points;
        communityData[barangay]['jobsFinished'] += jobsFinished;
        communityData[barangay]['count'] += 1;
      }

      // If no valid users with barangay, use mock data
      if (validUsers == 0 || communityData.isEmpty) {
        return _getMockCommunityLeaderboard(false);
      }

      List<LeaderboardEntry> communities = communityData.entries
          .map((e) => LeaderboardEntry(
            userId: 'community_${e.key}',
            username: '${e.key} Community',
            avatarUrl: null,
            barangay: e.key,
            city: 'Iloilo City',
            points: e.value['points'],
            jobsFinished: e.value['jobsFinished'],
            rank: 0,
          ))
          .toList();

      communities.sort((a, b) => b.points.compareTo(a.points));

      for (int i = 0; i < communities.length; i++) {
        communities[i] = LeaderboardEntry(
          userId: communities[i].userId,
          username: communities[i].username,
          avatarUrl: communities[i].avatarUrl,
          barangay: communities[i].barangay,
          city: communities[i].city,
          points: communities[i].points,
          jobsFinished: communities[i].jobsFinished,
          rank: i + 1,
        );
      }

      return communities;
    } catch (e) {
      return _getMockCommunityLeaderboard(false);
    }
  }

  /// All-time leaderboard (uses total points)
  Future<List<LeaderboardEntry>> getAllTimeLeaderboard() async {
    return _getLeaderboardByField('points');
  }

  /// Weekly leaderboard (TEMP: uses total points for consistency)
  Future<List<LeaderboardEntry>> getWeeklyLeaderboard() async {
    return _getLeaderboardByField('points');
  }

  /// Monthly leaderboard (TEMP: uses total points for consistency)
  Future<List<LeaderboardEntry>> getMonthlyLeaderboard() async {
    return _getLeaderboardByField('points');
  }
}