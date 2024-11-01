class CheckInModel {
  final String userId;
  final double latitude;
  final double longitude;
  final DateTime timestamp;

  CheckInModel({
    required this.userId,
    required this.latitude,
    required this.longitude,
    required this.timestamp,
  });

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'latitude': latitude,
      'longitude': longitude,
      'timestamp': timestamp.toIso8601String(),
    };
  }
}
