class Community {
  final int id;
  final String name;
  final String description;
  final double lat;
  final double lng;
  final double radiusKm;
  final int memberCount;
  final int activeIssuesCount;
  final String? bannerUrl;

  Community({
    required this.id,
    required this.name,
    required this.description,
    required this.lat,
    required this.lng,
    required this.radiusKm,
    required this.memberCount,
    required this.activeIssuesCount,
    this.bannerUrl,
  });
}

class CommunityInitiative {
  final String id;
  final String title;
  final String description;
  final String type; // 'event' or 'fundraiser'
  final DateTime date;
  final String? locationStr;
  final double? goalAmount;
  final double? raisedAmount;
  final int rsvpCount;
  final String? imageUrl;
  final bool hasUserRsvp;
  final bool hasUserPledged;

  CommunityInitiative({
    required this.id,
    required this.title,
    required this.description,
    required this.type,
    required this.date,
    this.locationStr,
    this.goalAmount,
    this.raisedAmount,
    this.rsvpCount = 0,
    this.imageUrl,
    this.hasUserRsvp = false,
    this.hasUserPledged = false,
  });
}

class CommunityAnnouncement {
  final String id;
  final String title;
  final String content;
  final DateTime postedAt;
  final String authorName;

  CommunityAnnouncement({
    required this.id,
    required this.title,
    required this.content,
    required this.postedAt,
    required this.authorName,
  });
}
