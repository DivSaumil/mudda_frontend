import 'dart:async';
import '../../domain/entities/community_models.dart';

class MockCommunityRepository {
  // Mock singleton for simplicity
  static final MockCommunityRepository _instance = MockCommunityRepository._internal();
  factory MockCommunityRepository() => _instance;
  MockCommunityRepository._internal();

  Community? _currentCommunity;

  Future<List<Community>> getNearbyCommunities(double lat, double lng, double radiusKm) async {
    await Future.delayed(const Duration(milliseconds: 600));
    return [
      Community(
        id: 1,
        name: 'Hillview Estates',
        description: 'A quiet, family-friendly neighborhood with private parks.',
        lat: 34.0522,
        lng: -118.2437,
        radiusKm: 2.5,
        memberCount: 2450,
        activeIssuesCount: 128,
        bannerUrl: 'https://images.unsplash.com/photo-1555620953-e968ec5d918b?q=80&w=600&auto=format&fit=crop',
      )
    ];
  }

  Future<bool> joinCommunity(int id) async {
    await Future.delayed(const Duration(milliseconds: 500));
    final communities = await getNearbyCommunities(0, 0, 0);
    _currentCommunity = communities.firstWhere((c) => c.id == id);
    return true; // Pending approval
  }

  Future<Community?> getHub() async {
    await Future.delayed(const Duration(milliseconds: 400));
    if (_currentCommunity == null) {
      final list = await getNearbyCommunities(0, 0, 0);
      _currentCommunity = list.first;
    }
    return _currentCommunity;
  }

  Future<List<CommunityInitiative>> getInitiatives(int communityId) async {
    await Future.delayed(const Duration(milliseconds: 500));
    return [
      CommunityInitiative(
        id: 'init-1',
        title: 'Park Cleanup Drive',
        description: 'Join us this weekend to clean up the Central Square Gardens. Trash bags and gloves provided.',
        type: 'event',
        date: DateTime.now().add(const Duration(days: 3)),
        locationStr: 'Central Square Gardens',
        rsvpCount: 42,
        imageUrl: 'https://images.unsplash.com/photo-1542601906990-b4d3fb778b09?w=500&q=80',
      ),
      CommunityInitiative(
        id: 'init-2',
        title: 'Road Repair Fundraising',
        description: 'We are raising funds to independently patch the potholes on Main St before winter arrives.',
        type: 'fundraiser',
        date: DateTime.now().add(const Duration(days: 14)),
        goalAmount: 5000,
        raisedAmount: 3200,
        imageUrl: 'https://images.unsplash.com/photo-1582213782179-e0d53f98f2ca?w=500&q=80',
      )
    ];
  }

  Future<List<CommunityAnnouncement>> getAnnouncements(int communityId) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return [
      CommunityAnnouncement(
        id: 'msg-1',
        title: 'Town Hall: Road Safety',
        content: 'Please attend our monthly town hall in Hall B. We will be discussing recent traffic safety concerns.',
        postedAt: DateTime.now().subtract(const Duration(days: 1)),
        authorName: 'City Hall',
      )
    ];
  }

  Future<bool> participateInInitiative(String initiativeId) async {
    await Future.delayed(const Duration(milliseconds: 500));
    return true;
  }
}
