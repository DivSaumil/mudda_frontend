import '../models/role_models.dart';
import '../services/role_service.dart';

class RoleRepository {
  final RoleService service;

  RoleRepository({required this.service});

  Future<List<RoleResponse>> getRoles({String? name}) => service.getAllRoles(name: name);

  Future<RoleResponse> createRole(CreateRoleRequest request) => service.createRole(request);

  Future<RoleResponse> getRole(int id) => service.getRoleById(id);

  Future<void> deleteRole(int id) => service.deleteRole(id);
}
