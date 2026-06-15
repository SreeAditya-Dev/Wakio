import 'dart:math';

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

  /// All COCO class names that are commonly found around a home / indoors
  /// and that YOLOv11n detects reliably at close range.
  static const List<String> householdObjects = [
    // Furniture & decor
    'chair', 'couch', 'bed', 'dining table', 'potted plant', 'vase', 'clock',
    // Kitchen & dining
    'bottle', 'cup', 'fork', 'knife', 'spoon', 'bowl', 'microwave', 'oven',
    'toaster', 'sink', 'refrigerator',
    // Electronics
    'tv', 'laptop', 'mouse', 'keyboard', 'cell phone', 'remote',
    // Personal items
    'backpack', 'umbrella', 'handbag', 'suitcase',
    // Books & office
    'book', 'scissors',
    // Bathroom & grooming
    'toothbrush', 'hair drier',
    // Fun
    'teddy bear', 'sports ball',
  ];

  factory Challenge.fromJson(Map<String, dynamic> json) => Challenge(
        objectClass: json['object_class'] as String,
        displayName: json['display_name'] as String,
        points: (json['points'] as num?)?.toInt() ?? 10,
      );

  /// Random offline fallback — picks a different household object each time,
  /// seeded by the current date + microseconds so every alarm potentially
  /// gets a unique challenge even on the same day.
  factory Challenge.offlineFor(DateTime day) {
    final seed = day.microsecondsSinceEpoch ^
        (day.year * 10000 + day.month * 100 + day.day);
    final rng = Random(seed);
    final obj = householdObjects[rng.nextInt(householdObjects.length)];
    return Challenge(
      objectClass: obj,
      displayName: _titleCase(obj),
    );
  }

  /// Pick a truly random object (no seed) — useful when scheduling an alarm
  /// and needing a fresh challenge independent of the date.
  factory Challenge.random() {
    final rng = Random();
    final obj = householdObjects[rng.nextInt(householdObjects.length)];
    return Challenge(
      objectClass: obj,
      displayName: _titleCase(obj),
    );
  }

  static String _titleCase(String s) => s
      .split(' ')
      .map((w) => w.isEmpty ? w : '${w[0].toUpperCase()}${w.substring(1)}')
      .join(' ');
}

