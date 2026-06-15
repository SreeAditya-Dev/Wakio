/// The daily scan-to-stop object challenge.
class Challenge {
  const Challenge({
    required this.objectClass,
    required this.displayName,
    this.points = 10,
  });

  final String objectClass; // e.g. "chair" (matches YOLO/COCO label)
  final String displayName; // e.g. "Chair"
  final int points;

  factory Challenge.fromJson(Map<String, dynamic> json) => Challenge(
        objectClass: json['object_class'] as String,
        displayName: json['display_name'] as String,
        points: (json['points'] as num?)?.toInt() ?? 10,
      );

  /// Deterministic offline fallback when the server is unreachable — mirrors
  /// the backend's seed-by-date logic closely enough for the slice.
  factory Challenge.offlineFor(DateTime day) {
    const objects = [
      'chair', 'bottle', 'cup', 'book', 'laptop', 'clock', 'mouse',
      'keyboard', 'cell phone', 'remote', 'scissors', 'vase', 'backpack',
      'potted plant', 'tv', 'teddy bear', 'toothbrush',
    ];
    final seed = day.year * 10000 + day.month * 100 + day.day;
    final obj = objects[seed % objects.length];
    return Challenge(
      objectClass: obj,
      displayName: obj
          .split(' ')
          .map((w) => w.isEmpty ? w : '${w[0].toUpperCase()}${w.substring(1)}')
          .join(' '),
    );
  }
}
