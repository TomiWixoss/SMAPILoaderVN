/// App status model
class AppStatus {
  final String launcherVersion;
  final String? gameVersion;
  final String? smapiVersion;
  final bool isReady;
  
  AppStatus({
    required this.launcherVersion,
    this.gameVersion,
    this.smapiVersion,
    required this.isReady,
  });
  
  factory AppStatus.fromMap(Map<String, dynamic> map) {
    return AppStatus(
      launcherVersion: map['launcherVersion'] as String? ?? 'Unknown',
      gameVersion: map['gameVersion'] as String?,
      smapiVersion: map['smapiVersion'] as String?,
      isReady: map['isReady'] as bool? ?? false,
    );
  }
  
  Map<String, dynamic> toMap() {
    return {
      'launcherVersion': launcherVersion,
      'gameVersion': gameVersion,
      'smapiVersion': smapiVersion,
      'isReady': isReady,
    };
  }
}
