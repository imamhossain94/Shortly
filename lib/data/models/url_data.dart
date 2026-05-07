class UrlData {
  final int? id;
  final String? provider;
  final String? originalUrl;
  final String? shortenedUrl;
  final String? expandedUrl;
  final bool? success;
  final int timestamp;

  UrlData({
    this.id,
    this.provider,
    this.originalUrl,
    this.shortenedUrl,
    this.expandedUrl,
    this.success,
    required this.timestamp,
  });

  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{
      'provider': provider,
      'originalUrl': originalUrl,
      'shortenedUrl': shortenedUrl,
      'expandedUrl': expandedUrl,
      'success': success == true ? 1 : 0,
      'timestamp': timestamp,
    };
    if (id != null) {
      map['id'] = id;
    }
    return map;
  }

  factory UrlData.fromMap(Map<String, dynamic> map) {
    return UrlData(
      id: map['id'] as int?,
      provider: map['provider']?.toString(),
      originalUrl: map['originalUrl']?.toString(),
      shortenedUrl: map['shortenedUrl']?.toString(),
      expandedUrl: map['expandedUrl']?.toString(),
      success: map['success'] == 1 || map['success'] == true,
      timestamp: (map['timestamp'] as num?)?.toInt() ?? DateTime.now().millisecondsSinceEpoch,
    );
  }

  UrlData copyWith({
    int? id,
    String? provider,
    String? originalUrl,
    String? shortenedUrl,
    String? expandedUrl,
    bool? success,
    int? timestamp,
  }) {
    return UrlData(
      id: id ?? this.id,
      provider: provider ?? this.provider,
      originalUrl: originalUrl ?? this.originalUrl,
      shortenedUrl: shortenedUrl ?? this.shortenedUrl,
      expandedUrl: expandedUrl ?? this.expandedUrl,
      success: success ?? this.success,
      timestamp: timestamp ?? this.timestamp,
    );
  }
}
