class CollectionInfo {
  final int? id;
  final int userId; // 對應 FastAPI 的 user_id (int)
  final String targetEn; // 對應 targetEn alias
  final String targetZh; // 對應 targetZh alias
  final String imageUrl; // 對應 imageUrl alias
  final String capturedAt; // 對應 capturedAt (String 或 DateTime)
  final String? updatedAt; // 對應 updatedAt alias

  CollectionInfo({
    this.id,
    required this.userId,
    required this.targetEn,
    required this.targetZh,
    required this.imageUrl,
    required this.capturedAt,
    this.updatedAt,
  });

  // 根據您的 FastAPI CollectionInfoResponse 設計 (populate_by_name=True)
  // 後端回傳的 JSON Key 會是 camelCase (例如 targetEn)
  factory CollectionInfo.fromJson(Map<String, dynamic> json) {
    return CollectionInfo(
      id: json['id'],
      userId: json['userId'],
      // 對應 alias: userId
      targetEn: json['targetEn'] ?? '',
      // 對應 alias: targetEn
      targetZh: json['targetZh'] ?? '',
      // 對應 alias: targetZh
      imageUrl: json['imageUrl'] ?? '',
      // 對應 alias: imageUrl
      capturedAt: json['capturedAt'] ?? '',
      // 對應 alias: capturedAt
      updatedAt: json['updatedAt'], // 對應 alias: updatedAt
    );
  }
/*
  // 如果需要轉換回 JSON (用於某些本地緩存)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'targetEn': targetEn,
      'targetZh': targetZh,
      'imageUrl': imageUrl,
      'capturedAt': capturedAt,
      'updatedAt': updatedAt,
    };
  }
}

// 針對 CollectionResponse (包含一層 collectionInfo) 的封裝
class CollectionResponse {
  final CollectionItem collectionInfo;

  CollectionResponse({required this.collectionInfo});

  factory CollectionResponse.fromJson(Map<String, dynamic> json) {
    return CollectionResponse(
      collectionInfo: CollectionItem.fromJson(json['collectionInfo']),
    );
  }

 */
}

