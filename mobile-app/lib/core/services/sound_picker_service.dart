import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

/// Lets the user pick an audio file from their device and copies it into the
/// app's sandbox so `AlarmService` can hand it to the `alarm` package as a
/// ringtone (which requires a path relative to the Documents directory).
class SoundPickerService {
  static const _dir = 'custom_sounds';
  static const _uuid = Uuid();

  /// Opens the system file picker for an audio file and copies it into
  /// `<Documents>/custom_sounds/`. Returns the path (relative to the
  /// Documents directory) and the original file name for display, or null
  /// if the user cancelled.
  Future<(String path, String name)?> pick() async {
    final result = await FilePicker.pickFiles(type: FileType.audio);
    final file = result?.files.single;
    if (file == null || file.path == null) return null;

    final docs = await getApplicationDocumentsDirectory();
    final dir = Directory(p.join(docs.path, _dir));
    await dir.create(recursive: true);

    final relPath = '$_dir/${_uuid.v4()}${p.extension(file.path!)}';
    await File(file.path!).copy(p.join(docs.path, relPath));
    return (relPath, file.name);
  }

  /// Removes a previously-stored custom sound, if any.
  Future<void> delete(String? relPath) async {
    if (relPath == null) return;
    final docs = await getApplicationDocumentsDirectory();
    final f = File(p.join(docs.path, relPath));
    if (await f.exists()) await f.delete();
  }
}

final soundPickerServiceProvider =
    Provider<SoundPickerService>((ref) => SoundPickerService());
