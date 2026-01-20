// Unit tests for IssueResponse and related models
// These tests lock in existing JSON parsing behavior before refactoring

import 'dart:convert';
import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:mudda_frontend/api/models/issue_models.dart';

void main() {
  group('IssueResponse', () {
    group('fromJson', () {
      test('parses complete valid JSON correctly', () {
        final json = {
          'id': 1,
          'title': 'Test Issue Title',
          'content': 'This is test content',
          'media_urls': [
            'https://example.com/image1.jpg',
            'https://example.com/image2.jpg',
          ],
          'vote_count': 42,
          'comments': 5,
          'status': 'PENDING',
          'created_at': '2024-01-15T10:30:00Z',
          'has_user_voted': false,
          'can_user_vote': true,
          'username': 'testuser123',
        };

        final issue = IssueResponse.fromJson(json);

        expect(issue.id, 1);
        expect(issue.title, 'Test Issue Title');
        expect(issue.content, 'This is test content');
        expect(issue.mediaUrls, hasLength(2));
        expect(issue.mediaUrls[0], 'https://example.com/image1.jpg');
        expect(issue.voteCount, 42);
        expect(issue.comments, 5);
        expect(issue.status, 'PENDING');
        expect(issue.createdAt, '2024-01-15T10:30:00Z');
        expect(issue.hasUserVoted, false);
        expect(issue.canUserVote, true);
        expect(issue.username, 'testuser123');
      });

      test('handles null values with sensible defaults', () {
        final json = <String, dynamic>{};

        final issue = IssueResponse.fromJson(json);

        expect(issue.id, 0);
        expect(issue.title, '');
        expect(issue.content, '');
        expect(issue.mediaUrls, isEmpty);
        expect(issue.voteCount, 0);
        expect(issue.comments, 0);
        expect(issue.status, 'PENDING');
        expect(issue.hasUserVoted, false);
        expect(issue.canUserVote, false);
        expect(issue.username, 'Anonymous Citizen');
      });

      test('parses id from string correctly', () {
        final json = {'id': '123'};

        final issue = IssueResponse.fromJson(json);

        expect(issue.id, 123);
      });

      test('uses description field when content is null', () {
        final json = {'description': 'Description text'};

        final issue = IssueResponse.fromJson(json);

        expect(issue.content, 'Description text');
      });

      test('handles empty media_urls list', () {
        final json = {'media_urls': []};

        final issue = IssueResponse.fromJson(json);

        expect(issue.mediaUrls, isEmpty);
        expect(issue.firstImageUrl, isNull);
      });

      test('firstImageUrl getter returns first URL when available', () {
        final json = {
          'media_urls': ['https://first.jpg', 'https://second.jpg'],
        };

        final issue = IssueResponse.fromJson(json);

        expect(issue.firstImageUrl, 'https://first.jpg');
      });
    });

    group('toJson', () {
      test('produces valid JSON with all fields', () {
        final issue = IssueResponse(
          id: 1,
          title: 'Test Title',
          content: 'Test Content',
          mediaUrls: ['https://example.com/img.jpg'],
          voteCount: 10,
          comments: 3,
          fullContent: 'Full content here',
          status: 'OPEN',
          createdAt: '2024-01-01T00:00:00Z',
          hasUserVoted: true,
          canUserVote: false,
          username: 'user123',
        );

        final json = issue.toJson();

        expect(json['id'], 1);
        expect(json['title'], 'Test Title');
        expect(json['content'], 'Test Content');
        expect(json['media_urls'], ['https://example.com/img.jpg']);
        expect(json['vote_count'], 10);
        expect(json['comments'], 3);
        expect(json['status'], 'OPEN');
        expect(json['has_user_voted'], true);
        expect(json['can_user_vote'], false);
        expect(json['username'], 'user123');
      });
    });
  });

  group('CreateIssueRequest', () {
    test('toJson includes all required fields', () {
      final request = CreateIssueRequest(
        title: 'New Issue',
        content: 'Issue description',
        mediaUrls: ['https://img.jpg'],
        categoryId: 1,
        locationId: 5,
        severityScore: 3,
        urgencyFlag: true,
        issueStatus: 'PENDING',
      );

      final json = request.toJson();

      expect(json['title'], 'New Issue');
      expect(json['content'], 'Issue description');
      expect(json['description'], 'Issue description'); // Mapped from content
      expect(json['media_urls'], ['https://img.jpg']);
      expect(json['categoryId'], 1);
      expect(json['locationId'], 5);
      expect(json['severity_score'], 3);
      expect(json['urgency_flag'], true);
      expect(json['issue_status'], 'PENDING');
    });

    test('toJson omits null optional fields', () {
      final request = CreateIssueRequest(
        title: 'Simple Issue',
        content: 'Description',
      );

      final json = request.toJson();

      expect(json.containsKey('categoryId'), false);
      expect(json.containsKey('locationId'), false);
      expect(json['severity_score'], 1); // Default value
      expect(json['urgency_flag'], false); // Default value
    });
  });

  group('IssueFilterRequest', () {
    test('toJson includes only non-null fields', () {
      final filter = IssueFilterRequest(
        status: 'OPEN',
        category: 'Infrastructure',
      );

      final json = filter.toJson();

      expect(json['status'], 'OPEN');
      expect(json['category'], 'Infrastructure');
      expect(json.containsKey('severity'), false);
    });

    test('toJson returns empty map when all fields null', () {
      final filter = IssueFilterRequest();

      final json = filter.toJson();

      expect(json, isEmpty);
    });
  });

  group('PageIssueSummaryResponse', () {
    test('fromJson parses paginated response correctly', () {
      final json = {
        'content': [
          {
            'id': 1,
            'title': 'Issue 1',
            'content': 'Content 1',
            'media_urls': [],
            'vote_count': 10,
            'status': 'PENDING',
            'created_at': '2024-01-01T00:00:00Z',
            'has_user_voted': false,
            'can_user_vote': true,
          },
          {
            'id': 2,
            'title': 'Issue 2',
            'content': 'Content 2',
            'media_urls': [],
            'vote_count': 5,
            'status': 'OPEN',
            'created_at': '2024-01-02T00:00:00Z',
            'has_user_voted': true,
            'can_user_vote': true,
          },
        ],
        'page': {'totalPages': 5, 'totalElements': 100},
      };

      final response = PageIssueSummaryResponse.fromJson(json);

      expect(response.issues, hasLength(2));
      expect(response.issues[0].id, 1);
      expect(response.issues[0].title, 'Issue 1');
      expect(response.issues[1].id, 2);
      expect(response.totalPages, 5);
      expect(response.totalElements, 100);
    });

    test('fromJson handles missing page object', () {
      final json = {'content': [], 'totalPages': 1, 'totalElements': 0};

      final response = PageIssueSummaryResponse.fromJson(json);

      expect(response.issues, isEmpty);
      expect(response.totalPages, 1);
      expect(response.totalElements, 0);
    });

    test('fromJson handles null content gracefully', () {
      final json = {
        'content': null,
        'page': {'totalPages': 0, 'totalElements': 0},
      };

      final response = PageIssueSummaryResponse.fromJson(json);

      expect(response.issues, isEmpty);
    });
  });

  group('IssueClusterRequest', () {
    test('toJson produces correct output', () {
      final request = IssueClusterRequest(numberOfClusters: 5);

      final json = request.toJson();

      expect(json['numberOfClusters'], 5);
    });
  });
}
