/// User entity untuk admin/owner manage karyawan.
///
/// Berbeda dari `AuthResponseModel.user` (logged-in user info) — model ini
/// dipakai untuk list & CRUD karyawan di Manage User page.
class UserModel {
  final int id;
  final String name;
  final String email;
  final String? phone;
  final String roles; // 'owner' | 'admin' | 'kasir'
  final String? avatarUrl;
  final bool isActive;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.roles,
    this.phone,
    this.avatarUrl,
    this.isActive = true,
  });

  factory UserModel.fromMap(Map<String, dynamic> m) {
    return UserModel(
      id: (m['id'] as num?)?.toInt() ?? 0,
      name: (m['name'] as String?) ?? '',
      email: (m['email'] as String?) ?? '',
      phone: m['phone'] as String?,
      roles: (m['roles'] as String?) ?? 'kasir',
      avatarUrl: m['avatar_url'] as String?,
      isActive: (m['is_active'] as bool?) ?? true,
    );
  }

  String get roleLabel {
    switch (roles) {
      case 'owner':
        return 'Pemilik';
      case 'admin':
        return 'Admin';
      case 'kasir':
        return 'Kasir';
      default:
        return roles;
    }
  }
}
