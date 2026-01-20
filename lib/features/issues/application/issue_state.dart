import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:mudda_frontend/api/models/issue_models.dart';

part 'issue_state.freezed.dart';

@freezed
class IssueState with _$IssueState {
  const factory IssueState.initial() = _Initial;
  const factory IssueState.loading() = _Loading;
  const factory IssueState.loaded(
    List<IssueResponse> issues, {
    @Default(true) bool hasMore,
    @Default('All') String category,
  }) = _Loaded;
  const factory IssueState.error(String message) = _Error;
}
