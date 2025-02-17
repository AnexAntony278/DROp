import 'dart:ui' as ui;
import 'dart:typed_data';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

Future<BitmapDescriptor> createNumberedMarker(int number, Color color) async {
  const int size = 23; // Marker size in pixels
  final ui.PictureRecorder recorder = ui.PictureRecorder();
  final Canvas canvas = Canvas(recorder);

  final Paint paint = Paint()
    ..color = color
    ..style = PaintingStyle.fill;

  // Draw Circle
  canvas.drawCircle(const Offset(size / 2, size / 2), size / 2.2, paint);

  // Draw Number
  final TextPainter textPainter = TextPainter(
    text: TextSpan(
      text: number.toString(),
      style: const TextStyle(
        fontSize: size / 2,
        fontWeight: FontWeight.bold,
        color: ui.Color.fromARGB(255, 1, 40, 53),
      ),
    ),
    textDirection: TextDirection.ltr,
  );
  textPainter.layout();
  textPainter.paint(canvas,
      Offset((size - textPainter.width) / 2, (size - textPainter.height) / 2));

  final ui.Image img = await recorder.endRecording().toImage(size, size);
  final ByteData? byteData =
      await img.toByteData(format: ui.ImageByteFormat.png);
  final Uint8List byteList = byteData!.buffer.asUint8List();

  return BitmapDescriptor.bytes(byteList);
}
