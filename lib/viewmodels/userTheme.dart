class UsetThemeInfo {
  final int? id;
  final int userId; // 對應 FastAPI 的 user_id (int)
  final String bgType; // 對應 bgType alias
  final String bgValue; // 對應 bgValue alias
  final String avatarPath;
  final String capturedAt; // 對應 capturedAt (String 或 DateTime)
  final String? updatedAt; // 對應 updatedAt alias

  UsetThemeInfo({
    this.id,
    required this.userId,
    required this.bgType,
    required this.bgValue,
    required this.avatarPath,
    required this.capturedAt,
    this.updatedAt,
  });

  // 轉換為 JSON 格式
  factory UsetThemeInfo.fromJson(Map<String, dynamic> json) {
    return UsetThemeInfo(
      id: json['id'],
        userId: json['userId'],
        bgType: json['bgType'] ?? '',
        bgValue: json['bgValue'] ?? '',
        avatarPath: json['avatarPath'] ?? '',
        capturedAt: json['capturedAt'] ?? '',
        updatedAt: json['updatedAt'],
    );

  }

}