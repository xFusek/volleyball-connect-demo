class UserModel {
  final String id;
  final String name;
  final String handle;
  final String avatarUrl;

  UserModel({
    required this.id,
    required this.name,
    required this.handle,
    required this.avatarUrl,
  });

  factory UserModel.fromMap(Map<String, dynamic> data, String id) {
    return UserModel(
      id: id,
      name: data['name'] ?? 'Unknown',
      handle: data['handle'] ?? '@unknown',
      avatarUrl:
          data['image'] ??
          'https://firebasestorage.googleapis.com/v0/b/social-appv.appspot.com/o/user_avatar%2Ftemplate.jpg?alt=media&token=2a543c75-eef6-41e6-a1b6-23db552f4099',
    );
  }
}
