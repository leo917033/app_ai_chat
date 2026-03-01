class UserInfo {
  String token;
  String id;
  String username;

  UserInfo({
    required this.token,
    required this.id,
    required this.username,
  });

  // 轉換為 JSON 格式
  factory UserInfo.fromJson(Map<String, dynamic> json) => UserInfo(
    token: json["token"] ?? "",
    id: json["id"] ?? "",
    username: json["username"] ?? "",
  );

}