// Unit tests for comment models
// These tests lock in existing JSON parsing behavior before refactoring

import 'package:flutter_test/flutter_test.dart';
import 'package:mudda_frontend/api/models/comment_models.dart';

void main() {
  group('CommentResponse', () {
    group('fromJson', () {
      test('parses complete valid JSON correctly', () {
        final json = {
          'comment_id': 1,
          'issue_id': 123,
          'text': 'This is a test comment',
          'parent_comment_id': null,
          'like_count': 5,
          'reply_count': 2,
          'created_at': '2024-01-15T11:00:00Z',
          'author_id': 42,
          'has_user_liked': false,
        };

        final comment = CommentResponse.fromJson(json);

        expect(comment.id, 1);
        expect(comment.issueId, 123);
        expect(comment.content, 'This is a test comment');
        expect(comment.parentCommentId, isNull);
        expect(comment.likes, 5);
        expect(comment.repliesCount, 2);
        expect(comment.createdAt, '2024-01-15T11:00:00Z');
        expect(comment.authorId, 42);
        expect(comment.hasUserLiked, false);
      });

      test('parses reply with parent_comment_id', () {
        final json = {
          'comment_id': 5,
          'issue_id': 123,
          'text': 'This is a reply',
          'parent_comment_id': 1,
          'like_count': 0,
          'reply_count': 0,
          'created_at': '2024-01-15T12:00:00Z',
          'author_id': 55,
          'has_user_liked': true,
        };

        final comment = CommentResponse.fromJson(json);

        expect(comment.parentCommentId, 1);
        expect(comment.hasUserLiked, true);
      });

      test('handles missing fields with defaults', () {
        final json = <String, dynamic>{};

        final comment = CommentResponse.fromJson(json);

        expect(comment.id, 0);
        expect(comment.issueId, 0);
        expect(comment.content, '');
        expect(comment.parentCommentId, isNull);
        expect(comment.likes, 0);
        expect(comment.repliesCount, 0);
        expect(comment.createdAt, '');
        expect(comment.authorId, 0);
        expect(comment.hasUserLiked, false);
      });
    });

    group('toJson', () {
      test('produces valid JSON with all fields', () {
        final comment = CommentResponse(
          id: 1,
          issueId: 123,
          content: 'Test comment',
          parentCommentId: null,
          likes: 10,
          repliesCount: 3,
          createdAt: '2024-01-01T00:00:00Z',
          authorId: 42,
          hasUserLiked: true,
        );

        final json = comment.toJson();

        expect(json['comment_id'], 1);
        expect(json['issue_id'], 123);
        expect(json['text'], 'Test comment');
        expect(
          json.containsKey('parent_comment_id'),
          false,
        ); // null values excluded
        expect(json['like_count'], 10);
        expect(json['reply_count'], 3);
        expect(json['author_id'], 42);
        expect(json['has_user_liked'], true);
      });

      test('includes parent_comment_id when not null', () {
        final comment = CommentResponse(
          id: 5,
          issueId: 123,
          content: 'Reply',
          parentCommentId: 1,
          likes: 0,
          repliesCount: 0,
          createdAt: '2024-01-01T00:00:00Z',
          authorId: 55,
          hasUserLiked: false,
        );

        final json = comment.toJson();

        expect(json['parent_comment_id'], 1);
      });
    });
  });

  group('CreateCommentRequest', () {
    test('toJson produces correct output', () {
      final request = CreateCommentRequest(content: 'New comment text');

      final json = request.toJson();

      expect(json['text'], 'New comment text');
      expect(json.length, 1);
    });
  });

  group('CommentLikeResponse', () {
    test('fromJson parses correctly', () {
      final json = {'comment_id': 1, 'like_count': 15};

      final response = CommentLikeResponse.fromJson(json);

      expect(response.commentId, 1);
      expect(response.likes, 15);
    });

    test('handles missing fields', () {
      final json = <String, dynamic>{};

      final response = CommentLikeResponse.fromJson(json);

      expect(response.commentId, 0);
      expect(response.likes, 0);
    });
  });

  group('PageCommentDetailResponse', () {
    test('fromJson parses paginated comments correctly', () {
      final json = {
        'content': [
          {
            'comment_id': 1,
            'issue_id': 123,
            'text': 'First comment',
            'like_count': 5,
            'reply_count': 0,
            'created_at': '2024-01-01T00:00:00Z',
            'author_id': 42,
            'has_user_liked': false,
          },
          {
            'comment_id': 2,
            'issue_id': 123,
            'text': 'Second comment',
            'like_count': 3,
            'reply_count': 1,
            'created_at': '2024-01-02T00:00:00Z',
            'author_id': 55,
            'has_user_liked': true,
          },
        ],
        'page': {'totalPages': 2, 'totalElements': 25},
      };

      final response = PageCommentDetailResponse.fromJson(json);

      expect(response.comments, hasLength(2));
      expect(response.comments[0].id, 1);
      expect(response.comments[0].content, 'First comment');
      expect(response.comments[1].id, 2);
      expect(response.totalPages, 2);
      expect(response.totalElements, 25);
    });

    test('handles missing page object', () {
      final json = {'content': [], 'totalPages': 1, 'totalElements': 0};

      final response = PageCommentDetailResponse.fromJson(json);

      expect(response.comments, isEmpty);
      expect(response.totalPages, 1);
      expect(response.totalElements, 0);
    });

    test('handles null content', () {
      final json = {
        'content': null,
        'page': {'totalPages': 0, 'totalElements': 0},
      };

      final response = PageCommentDetailResponse.fromJson(json);

      expect(response.comments, isEmpty);
    });
  });

  group('PageReplyResponse', () {
    test('fromJson parses replies correctly', () {
      final json = {
        'content': [
          {
            'comment_id': 10,
            'issue_id': 123,
            'text': 'A reply',
            'parent_comment_id': 1,
            'like_count': 2,
            'reply_count': 0,
            'created_at': '2024-01-01T00:00:00Z',
            'author_id': 99,
            'has_user_liked': false,
          },
        ],
        'page': {'totalPages': 1, 'totalElements': 1},
      };

      final response = PageReplyResponse.fromJson(json);

      expect(response.replies, hasLength(1));
      expect(response.replies[0].id, 10);
      expect(response.replies[0].parentCommentId, 1);
      expect(response.totalPages, 1);
      expect(response.totalElements, 1);
    });
  });
}
