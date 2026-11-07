/// Data model for timing-supported moshaf read from `ayat_timing/reads`.
class TimingReadModel {
  final int id;
  final String name;
  final String rewaya;
  final String folderUrl;
  final int soarCount;

  const TimingReadModel({
    required this.id,
    required this.name,
    required this.rewaya,
    required this.folderUrl,
    required this.soarCount,
  });

  factory TimingReadModel.fromJson(Map<String, dynamic> json) {
    return TimingReadModel(
      id: _parseInt(json['id']),
      name: json['name']?.toString() ?? '',
      rewaya: json['rewaya']?.toString() ?? '',
      folderUrl: json['folder_url']?.toString() ?? '',
      soarCount: _parseInt(json['soar_count']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'rewaya': rewaya,
      'folder_url': folderUrl,
      'soar_count': soarCount,
    };
  }

  static int _parseInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) {
      return int.tryParse(value) ?? 0;
    }
    return 0;
  }
}
