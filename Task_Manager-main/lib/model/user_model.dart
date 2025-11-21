class UserModel {
  final String uid;
  final String name;
  final int points;
  final List<String> groupTokens;

  UserModel({
    required this.uid,
    required this.name,
    required this.points,
    required this.groupTokens,
  });

  factory UserModel.fromMap(Map<String, dynamic> map, String uid) {
    return UserModel(
      uid: uid,
      name: map['nickname'] ?? '', // Using 'nickname' based on screenshot
      points: 0, // Points seem to be in a separate collection or field, initializing to 0 for now, will update logic
      groupTokens: List<String>.from(map['groupTokens'] ?? []),
    );
  }
}
