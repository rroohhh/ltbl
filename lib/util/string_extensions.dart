import 'dart:typed_data';
import 'package:typed_data/typed_buffers.dart';

extension GetBytes on String {
  Uint8Buffer get bytes {
    final buffer = Uint8Buffer();
    buffer.addAll(Uint8List.fromList(codeUnits));
    return buffer;
  }
}
