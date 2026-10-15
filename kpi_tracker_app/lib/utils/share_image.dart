import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/rendering.dart';
import 'package:path_provider/path_provider.dart';

/// Captures whatever is painted inside the [RepaintBoundary] identified by
/// [key] as a PNG file, at a higher pixel ratio than the on-screen size so
/// the exported image stays sharp for sharing to social apps.
///
/// The boundary must already have been laid out and painted at least once
/// — call this from a button inside the same widget that's currently
/// visible on screen, not before the first frame.
Future<File> captureRepaintBoundary(
  GlobalKey key,
  String fileName, {
  double pixelRatio = 3,
}) async {
  final boundary =
      key.currentContext!.findRenderObject() as RenderRepaintBoundary;
  final image = await boundary.toImage(pixelRatio: pixelRatio);
  final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
  final bytes = byteData!.buffer.asUint8List();
  final dir = await getTemporaryDirectory();
  final file = File('${dir.path}/$fileName');
  await file.writeAsBytes(bytes);
  return file;
}
