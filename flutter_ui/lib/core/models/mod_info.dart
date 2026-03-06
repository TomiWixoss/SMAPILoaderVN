/// Mod information model
class ModInfo {
  final String id;
  final String name;
  final String version;
  final String? author;
  final String? description;
  final bool isEnabled;
  final String? iconPath;
  
  ModInfo({
    required this.id,
    required this.name,
    required this.version,
    this.author,
    this.description,
    required this.isEnabled,
    this.iconPath,
  });
  
  factory ModInfo.fromMap(Map<String, dynamic> map) {
    return ModInfo(
      id: map['id'] as String? ?? '',
      name: map['name'] as String? ?? 'Unknown Mod',
      version: map['version'] as String? ?? '0.0.0',
      author: map['author'] as String?,
      description: map['description'] as String?,
      isEnabled: map['isEnabled'] as bool? ?? true,
      iconPath: map['iconPath'] as String?,
    );
  }
  
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'version': version,
      'author': author,
      'description': description,
      'isEnabled': isEnabled,
      'iconPath': iconPath,
    };
  }
  
  ModInfo copyWith({
    String? id,
    String? name,
    String? version,
    String? author,
    String? description,
    bool? isEnabled,
    String? iconPath,
  }) {
    return ModInfo(
      id: id ?? this.id,
      name: name ?? this.name,
      version: version ?? this.version,
      author: author ?? this.author,
      description: description ?? this.description,
      isEnabled: isEnabled ?? this.isEnabled,
      iconPath: iconPath ?? this.iconPath,
    );
  }
}
