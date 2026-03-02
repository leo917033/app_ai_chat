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
  factory UserInfo.fromJson(Map<String, dynamic> json) {
    // 根據 Log，傳入的 json 已經是包含 token 和 userInfo 的層級了
    // 1. 直接取得 userInfo 部分
    final userDetails = json['userInfo'] ?? {};

    return UserInfo(
      // 2. 直接從 json 取 token
      token: json['token']?.toString() ?? "",
      // 3. 從 userDetails 取 id 和 username
      id: userDetails['id']?.toString() ?? "",
      username: userDetails['username']?.toString() ?? "",
    );
  }

}