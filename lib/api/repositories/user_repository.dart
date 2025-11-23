import '../models/user_models.dart';
import '../services/user_service.dart';

class UserRepository {
  final UserService service;

  UserRepository({required this.service});

  Future<UserDetailResponse> getUser(int id) => service.getUserById(id);

  Future<UserSummaryResponse> updateUser(int id, UpdateUserRequest request) =>
      service.updateUser(id, request);

  Future<void> deleteUser(int id) => service.deleteUser(id);

  Future<PageUserSummaryResponse> getUsers({
    required UserFilterRequest filterRequest,
    int page = 0,
    int size = 20,
    String sortBy = 'CREATED_AT',
    String sortOrder = 'desc',
  }) =>
      service.getAllUsers(
        filterRequest: filterRequest,
        page: page,
        size: size,
        sortBy: sortBy,
        sortOrder: sortOrder,
      );

  Future<UserDetailResponse> createUser(CreateUserRequest request) =>
      service.createUser(request);
}
